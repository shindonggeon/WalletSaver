import os
from typing import Dict

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from google import genai
from pydantic import BaseModel

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise RuntimeError("GEMINI_API_KEY is not set in .env")

client = genai.Client(api_key=api_key)


class LocationWarningRequest(BaseModel):
    placeName: str
    category: str
    remainingBudget: int
    todayBudget: int
    budgetUsageRate: float
    monthlyGoal: str
    characterType: str
    characterTypeLabel: str
    naggingIntensity: str


class ExpenseFeedbackRequest(BaseModel):
    amount: int
    category: str
    merchant: str
    remainingBudget: int
    todayBudget: int
    budgetUsageRate: float
    monthlyGoal: str
    characterType: str
    characterTypeLabel: str
    naggingIntensity: str


class MonthlyReportRequest(BaseModel):
    age: int
    totalBudget: int
    totalSpent: int
    remainingBudget: int
    budgetUsageRate: float
    categorySpending: Dict[str, int]
    monthlyGoal: str
    characterType: str
    characterTypeLabel: str
    topCategory: str
    topCategoryLabel: str
    personaTitle: str
    personaBaseMessage: str


@app.get("/")
def health_check():
    return {"status": "ok"}


def get_character_guide(character_type: str) -> str:
    if character_type == "lion":
        return """
사용자는 충동형 - 사자 성향이다.
특징:
- 감정과 순간적인 욕구에 따라 소비할 가능성이 높다.
- 쇼핑, 취미, 외식처럼 즉각적인 만족을 주는 소비에 약할 수 있다.
- 너무 강하게 비난하면 거부감이 생길 수 있으므로, 직설적이지만 현실적인 조언이 좋다.
말투:
- 친근하지만 약간 단호하게 말한다.
- "지금 속도라면", "한 번 멈춰보면", "결제 전 10분만 생각하면" 같은 표현이 잘 맞는다.
"""
    if character_type == "ant":
        return """
사용자는 계획형 - 개미 성향이다.
특징:
- 예산과 계획을 중요하게 생각한다.
- 대체로 소비 통제력이 좋지만, 계획이 무너지면 스트레스를 받을 수 있다.
- 데이터와 비교 분석을 제시하면 설득력이 높다.
말투:
- 칭찬을 먼저 하고, 개선점을 차분하게 제안한다.
- "현재 계획은 잘 유지되고 있어요", "다음 달에는 항목을 더 세분화해보세요" 같은 표현이 잘 맞는다.
"""
    if character_type == "turtle":
        return """
사용자는 절약형 - 거북이 성향이다.
특징:
- 불필요한 지출을 줄이는 데 강하다.
- 하지만 필요한 소비나 자기 돌봄 소비까지 지나치게 줄일 수 있다.
- 무조건 아끼라는 조언보다 합리적 소비와 균형을 제안하는 것이 좋다.
말투:
- 안정감 있게 칭찬하고, 필요한 소비는 허용해도 된다고 안내한다.
- "아끼는 습관은 장점이에요", "필요한 곳에는 적당히 써도 괜찮아요" 같은 표현이 잘 맞는다.
"""
    return """
사용자는 일반 소비 성향이다.
특징:
- 특정 성향으로 강하게 분류하기 어렵다.
- 지출 데이터와 목표를 중심으로 균형 있게 조언한다.
말투:
- 친근하고 현실적인 조언을 제공한다.
"""


@app.post("/ai/location-warning")
def generate_location_warning(req: LocationWarningRequest):
    character_guide = get_character_guide(req.characterType)

    prompt = f"""
너는 20대 사용자를 위한 소비 습관 관리 앱 '소리(Sori)'의 AI 금융 비서야.

상황:
사용자가 등록된 위험 지역 근처에 들어왔어.
아직 결제 전이므로 예방 중심의 짧은 경고 문구를 작성해야 해.

사용자 정보:
- 소비 성향: {req.characterTypeLabel}
- 이번 달 목표: {req.monthlyGoal}
- 잔소리 강도: {req.naggingIntensity}

성향별 조언 가이드:
{character_guide}

위험 지역:
- 장소명: {req.placeName}
- 관련 카테고리: {req.category}

예산 상태:
- 남은 예산: {req.remainingBudget}원
- 오늘 사용 가능 예산: {req.todayBudget}원
- 예산 사용률: {req.budgetUsageRate * 100:.1f}%

작성 조건:
- 한국어로 작성
- 2문장 이내
- 숫자 1개 이상 포함
- 사용자를 비난하지 않기
- 앱 푸시 알림처럼 짧고 자연스럽게 작성
- 이번 달 목표와 연결해서 말하기
"""

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
    )

    return {"message": response.text}


@app.post("/ai/expense-feedback")
def generate_expense_feedback(req: ExpenseFeedbackRequest):
    character_guide = get_character_guide(req.characterType)
    after_budget = req.remainingBudget - req.amount

    prompt = f"""
너는 20대 사용자를 위한 소비 습관 관리 앱 '소리(Sori)'의 AI 금융 비서야.

상황:
사용자가 방금 지출했어.
결제 후 피드백을 작성해야 해.

사용자 정보:
- 소비 성향: {req.characterTypeLabel}
- 이번 달 목표: {req.monthlyGoal}
- 잔소리 강도: {req.naggingIntensity}

성향별 조언 가이드:
{character_guide}

지출 정보:
- 가맹점: {req.merchant}
- 카테고리: {req.category}
- 지출 금액: {req.amount}원

예산 상태:
- 결제 전 남은 예산: {req.remainingBudget}원
- 결제 후 예상 남은 예산: {after_budget}원
- 오늘 사용 가능 예산: {req.todayBudget}원
- 예산 사용률: {req.budgetUsageRate * 100:.1f}%

작성 조건:
- 한국어로 작성
- 2~3문장
- 금액을 반드시 포함
- 목표와 충돌하면 직접 언급
- 비난하지 않기
- 잔소리 강도가 strong이어도 욕설이나 모욕 표현 금지
- 성향에 맞는 말투 사용
- 마지막 문장은 다음 행동 조언으로 마무리
"""

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
    )

    return {"message": response.text}


@app.post("/ai/monthly-report")
def generate_monthly_report(req: MonthlyReportRequest):
    character_guide = get_character_guide(req.characterType)

    prompt = f"""
너는 20대 사용자를 위한 소비 습관 분석 AI야.
사용자의 소비 성향, 나이, 월간 지출 데이터를 바탕으로 맞춤형 월간 리포트를 작성해.

중요:
단순히 숫자를 요약하지 말고, 사용자의 소비 습관을 상담하듯 분석해야 해.
사용자가 "내 소비를 진짜 분석해줬다"고 느끼게 작성해.

사용자 정보:
- 나이: {req.age}세
- 소비 성향: {req.characterTypeLabel}
- 최종 소비 유형: {req.personaTitle}
- 성향별 기본 분석 멘트: {req.personaBaseMessage}
- 이번 달 목표: {req.monthlyGoal}

성향별 조언 가이드:
{character_guide}

월간 소비 데이터:
- 총 예산: {req.totalBudget}원
- 총 지출: {req.totalSpent}원
- 남은 예산: {req.remainingBudget}원
- 예산 사용률: {req.budgetUsageRate * 100:.1f}%
- 최다 지출 카테고리: {req.topCategoryLabel}
- 카테고리별 지출: {req.categorySpending}

작성 방식:
1. 첫 문장에 '{req.personaTitle}'을 자연스럽게 언급해.
2. 총 지출, 예산 사용률, 남은 예산을 반드시 포함해.
3. 최다 지출 카테고리와 이번 달 목표 달성 여부를 짧게 평가해.
4. 다음 달 실천 조언은 1개만 제안해.
5. 4문장 이내로 작성해.
6. 모바일 카드 UI에 들어갈 짧은 문장으로 작성해.
7. 친절하지만 간결하게 작성해.

출력 예시:
이번 달 소비 유형은 즉흥적인 쇼퍼에 가깝습니다. 총 지출은 520,000원이고 예산 사용률은 86.7%입니다. 가장 눈에 띄는 카테고리는 쇼핑이며, 남은 예산은 80,000원입니다. 다음 달에는 자주 쓰는 카테고리에 한도를 정하고 결제 전 남은 예산을 확인하는 습관을 추천합니다.

금지:
- 긴 문단 금지
- 5문장 이상 금지
- 감성적인 표현 과다 사용 금지
- 같은 내용 반복 금지
- 목록 형식 금지
"""

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
    )

    return {"report": response.text}