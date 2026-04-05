import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronRight, ChevronLeft } from 'lucide-react';
import { PhoneFrame } from '../components/PhoneFrame';

const questions = [
  {
    q: '친구들과 쇼핑을 가면 나는?',
    a: ['계획한 것만 딱 사고 나와요', '마음에 들면 일단 지르고 봐요'],
    score: [0, 1],
  },
  {
    q: '월급/알바비가 들어오면 나는?',
    a: ['먼저 저축하고 남은 돈으로 생활해요', '일단 쓰다보면 자연스럽게 저축해요'],
    score: [0, 1],
  },
  {
    q: '할인 행사나 세일을 보면 나는?',
    a: ['꼭 필요한 물건만 필터링해서 사요', '일단 담아놓고 결제해버려요'],
    score: [0, 1],
  },
  {
    q: '갑자기 예상치 못한 지출이 생기면?',
    a: ['미리 만들어둔 비상금을 써요', '일단 어떻게든 해결하고 봐요'],
    score: [0, 1],
  },
  {
    q: '카페에서 메뉴를 고를 때 나는?',
    a: ['가성비 메뉴를 항상 선택해요', '그날 기분에 따라 마시고 싶은 걸 시켜요'],
    score: [0, 1],
  },
  {
    q: '새로운 옷이나 물건을 살 때 나는?',
    a: ['충분히 고민하고 정말 필요한지 따져요', '마음에 들면 바로 구매해요'],
    score: [0, 1],
  },
];

const characters = [
  {
    emoji: '🐜',
    name: '계획적인 개미',
    type: 'THRIFTY',
    color: '#22C55E',
    bgColor: '#F0FDF4',
    desc: '짠테크의 달인! 계획적이고 꼼꼼한 소비 패턴을 가지고 있어요. 저축도 잘하고 지출 관리도 철저해요.',
    advice: '가끔은 나 자신에게 작은 선물을 줘도 괜찮아요. 소비 다이어트는 꾸준히!',
  },
  {
    emoji: '🦁',
    name: '기분파 사자',
    type: 'IMPULSIVE',
    color: '#F59E0B',
    bgColor: '#FFFBEB',
    desc: '충동적인 소비 성향! 기분에 따라 지출이 크게 달라져요. 특히 의류/외식 카테고리에 약해요.',
    advice: '구매 전 "24시간 룰"을 적용해보세요. 하루 지나도 사고 싶으면 그때 사요!',
  },
  {
    emoji: '🐿️',
    name: '충동적 다람쥐',
    type: 'SCATTERED',
    color: '#EF4444',
    bgColor: '#FEF2F2',
    desc: '저축이 부족한 패턴! 소소한 지출이 모여 큰 금액이 되는 경향이 있어요. 편의점·카페 지출에 주의!',
    advice: '하루 가용 예산을 정해두고 그 이상은 절대 안 쓰는 연습이 필요해요!',
  },
  {
    emoji: '🦊',
    name: '현명한 여우',
    type: 'BALANCED',
    color: '#7C63F5',
    bgColor: '#F5F3FF',
    desc: '균형잡힌 소비 패턴! 지출과 저축 모두 잘 관리하는 편이에요. 조금만 더 노력하면 완벽해요.',
    advice: '지금 이 좋은 습관을 유지하면서 투자까지 도전해봐요!',
  },
];

export function OnboardingMBTI() {
  const navigate = useNavigate();
  const [step, setStep] = useState(0); // 0~5: questions, 6: result
  const [answers, setAnswers] = useState<number[]>([]);
  const [selected, setSelected] = useState<number | null>(null);

  const totalSteps = questions.length;
  const progress = (step / totalSteps) * 100;

  const handleAnswer = (scoreIdx: number) => {
    setSelected(scoreIdx);
    setTimeout(() => {
      const newAnswers = [...answers, scoreIdx];
      setAnswers(newAnswers);
      setSelected(null);
      if (step + 1 >= totalSteps) {
        setStep(totalSteps); // show result
      } else {
        setStep(step + 1);
      }
    }, 400);
  };

  const getCharacter = () => {
    const total = answers.reduce((a, b) => a + b, 0);
    if (total <= 1) return characters[0]; // thrifty ant
    if (total <= 3) return characters[3]; // balanced fox
    if (total <= 4) return characters[1]; // impulsive lion
    return characters[2]; // scattered squirrel
  };

  const character = step >= totalSteps ? getCharacter() : null;

  return (
    <PhoneFrame bgColor="#F5F3FF">
      <div className="px-6 pb-8">
        {step < totalSteps ? (
          <>
            {/* Header */}
            <div className="flex items-center justify-between mb-6">
              <button
                onClick={() => step > 0 && setStep(step - 1)}
                className="w-9 h-9 rounded-xl flex items-center justify-center"
                style={{ background: step > 0 ? '#E9E5FF' : 'transparent', border: 'none', cursor: 'pointer' }}
              >
                {step > 0 && <ChevronLeft size={20} color="#7C63F5" />}
              </button>
              <div className="text-center">
                <p className="text-xs text-gray-400 mb-0.5">소비 성향 테스트</p>
                <p className="text-sm text-gray-700" style={{ fontWeight: 600 }}>{step + 1} / {totalSteps}</p>
              </div>
              <div className="w-9" />
            </div>

            {/* Progress bar */}
            <div className="h-2 bg-gray-200 rounded-full mb-8 overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-500"
                style={{ width: `${progress}%`, background: 'linear-gradient(90deg, #7C63F5, #A78BFA)' }}
              />
            </div>

            {/* Character mascot */}
            <div className="flex justify-center mb-6">
              <div
                className="w-20 h-20 rounded-3xl flex items-center justify-center"
                style={{ background: 'linear-gradient(135deg, #7C63F5, #A78BFA)' }}
              >
                <span style={{ fontSize: '40px' }}>🐿️</span>
              </div>
            </div>

            {/* Question */}
            <div
              className="rounded-3xl p-6 mb-6 text-center"
              style={{ background: 'white', boxShadow: '0 4px 20px rgba(124,99,245,0.1)' }}
            >
              <p className="text-gray-800" style={{ fontSize: '18px', fontWeight: 700, lineHeight: '1.5' }}>
                {questions[step].q}
              </p>
            </div>

            {/* Answer choices */}
            <div className="flex flex-col gap-3">
              {questions[step].a.map((answer, idx) => (
                <button
                  key={idx}
                  onClick={() => handleAnswer(idx)}
                  className="w-full p-4 rounded-2xl text-left transition-all"
                  style={{
                    background: selected === idx ? '#7C63F5' : 'white',
                    color: selected === idx ? 'white' : '#374151',
                    border: selected === idx ? 'none' : '2px solid #E9E5FF',
                    cursor: 'pointer',
                    fontWeight: 500,
                    fontSize: '15px',
                    boxShadow: selected === idx ? '0 6px 16px rgba(124,99,245,0.3)' : 'none',
                    transform: selected === idx ? 'scale(0.98)' : 'scale(1)',
                    transition: 'all 0.3s ease',
                  }}
                >
                  <div className="flex items-center gap-3">
                    <div
                      className="w-7 h-7 rounded-full flex items-center justify-center shrink-0"
                      style={{
                        background: selected === idx ? 'rgba(255,255,255,0.3)' : '#F0EEFF',
                        color: selected === idx ? 'white' : '#7C63F5',
                        fontWeight: 700,
                        fontSize: '13px',
                      }}
                    >
                      {String.fromCharCode(65 + idx)}
                    </div>
                    {answer}
                  </div>
                </button>
              ))}
            </div>
          </>
        ) : (
          /* Result Screen */
          <div className="flex flex-col items-center">
            <p className="text-gray-500 text-sm mt-2 mb-4">분석 완료! 당신의 소비 유형은...</p>

            <div
              className="w-full rounded-3xl p-6 mb-6 text-center"
              style={{ background: character!.bgColor }}
            >
              <div
                className="w-24 h-24 rounded-3xl flex items-center justify-center mx-auto mb-4"
                style={{ background: character!.color + '20', fontSize: '56px' }}
              >
                {character!.emoji}
              </div>
              <div
                className="inline-block px-4 py-1.5 rounded-full text-sm mb-3"
                style={{ background: character!.color, color: 'white', fontWeight: 600 }}
              >
                소비 유형
              </div>
              <h2 className="text-gray-900 mb-2" style={{ fontSize: '24px', fontWeight: 800 }}>{character!.name}</h2>
              <p className="text-gray-600 text-sm leading-relaxed">{character!.desc}</p>
            </div>

            {/* AI advice */}
            <div
              className="w-full rounded-2xl p-4 mb-6 flex gap-3"
              style={{ background: '#EDE9FE' }}
            >
              <div className="text-2xl">🤖</div>
              <div>
                <p className="text-xs text-purple-600 mb-1" style={{ fontWeight: 600 }}>소리의 한마디</p>
                <p className="text-sm text-gray-700 leading-relaxed">{character!.advice}</p>
              </div>
            </div>

            <button
              onClick={() => navigate('/onboarding/setup')}
              className="w-full py-4 rounded-2xl text-white flex items-center justify-center gap-2"
              style={{
                background: 'linear-gradient(135deg, #7C63F5, #A78BFA)',
                border: 'none',
                cursor: 'pointer',
                fontWeight: 600,
                fontSize: '16px',
                boxShadow: '0 8px 20px rgba(124,99,245,0.4)',
              }}
            >
              재무 정보 설정하기 <ChevronRight size={18} />
            </button>
          </div>
        )}
      </div>
    </PhoneFrame>
  );
}
