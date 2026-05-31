# 지갑비서 '소리(WalletSaver)' 프로젝트 컨텍스트

이 문서는 Antigravity IDE 등 새로운 AI 어시스턴트가 프로젝트의 현재 상태와 히스토리를 즉시 파악할 수 있도록 작성된 요약 문서입니다. 새로운 대화를 시작할 때 이 문서를 먼저 읽어보라고 지시하면, 이전 작업 내역을 완벽히 이어서 작업할 수 있습니다.

## 1. 프로젝트 개요
- **목적**: 2030 청년층을 위한 캐릭터(소리) 기반의 소비/목표 관리 가계부 애플리케이션
- **기술 스택**: Flutter, Provider (상태 관리), GoRouter (라우팅), Firebase (Auth, Firestore)
- **디자인 스타일**: 뉴모피즘(Neumorphism) 기반의 입체적이고 깔끔한 UI

## 2. 주요 기능 및 작업 완료 상태
- **온보딩 & 소비 성향(MBTI) 테스트**: 
  - 동물(사자/개미/거북이) × 소비 형태 12가지 매핑 로직 및 임시 이모지 결과 화면 구현 완료 (`test_screen.dart`, `result_screen.dart`)
- **재무 및 챌린지 설정 & DB 연동**: 
  - 월 수입 및 고정 지출 동적 추가 기능 구현. 
  - 선택한 챌린지와 재무 데이터를 취합하여 Firestore `users` 및 `budgets` 컬렉션에 초기 데이터 생성 연동 완료 (`finance_setup_screen.dart`, `challenge_setup_screen.dart`, `user_service.dart`)
- **메인(홈) 화면**: 
  - Firebase 실시간 연동(`budgetStream`, `expenseStream`)으로 월 예산 사용량에 따른 캐릭터(소리) 카드 및 남은 예산 현황 실시간 표시 완료 (`home_screen.dart`, `budget_service.dart`)
- **가계부(Ledger) 화면**: 
  - Firestore와 연동된 실제 수입/지출 내역 리스트 출력 완료

## 3. 핵심 디렉토리 구조 (`test0429` 폴더 기준)
- `lib/models/`: `AppUser`, `Budget`, `Expense` 등 데이터 모델 구조체
- `lib/screens/`: 
  - `onboarding/`: 테스트, 결과, 재무설정, 챌린지 설정 화면
  - `home_screen.dart`, `ledger_screen.dart`, `character_screen.dart` 등 메인 탭 화면
- `lib/services/`: 
  - `budget_service.dart`: 지출 추가/삭제 및 이번 달 예산 자동 재계산 로직
  - `user_service.dart`: 유저 회원가입 시 DB 초기 데이터 셋업 로직
- `lib/widgets/`: 재사용 가능한 커스텀 위젯 (캐릭터 카드, 예산 카드, 챌린지 카드 등)
- `lib/theme/`: 뉴모피즘 기반 전역 테마 및 색상 정의 (`app_theme.dart`)

## 4. 향후 작업 목표 (Next Steps)
- 온보딩 결과 화면의 임시 이모지 이미지를 정식 Lottie 애니메이션(사자, 개미, 거북이)으로 교체
- 지출 절약 및 챌린지 달성도에 따라 메인 화면 캐릭터의 진화 및 감정 변화 로직(상호작용) 고도화
- 가계부 내역 추가 UI 개선 및 카테고리별 통계(Stats) 화면 구현
