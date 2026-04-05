import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronRight, Plus, Trash2, Target } from 'lucide-react';
import { PhoneFrame } from '../components/PhoneFrame';

const fixedExpenseItems = [
  { label: '월세/관리비', placeholder: '350,000', icon: '🏠' },
  { label: '통신비', placeholder: '55,000', icon: '📱' },
  { label: '교통비', placeholder: '60,000', icon: '🚇' },
  { label: '보험료', placeholder: '30,000', icon: '🛡️' },
];

const challengeOptions = [
  { id: 1, text: '이번 달 옷 쇼핑 안 하기', emoji: '👗', active: false },
  { id: 2, text: '카페 주 3회 이하', emoji: '☕', active: true },
  { id: 3, text: '배달앱 주문 줄이기', emoji: '🍕', active: false },
  { id: 4, text: '충동구매 3일 참기', emoji: '🛒', active: false },
];

export function OnboardingSetup() {
  const navigate = useNavigate();
  const [step, setStep] = useState(0); // 0: income/expense, 1: goal setting
  const [income, setIncome] = useState('1,200,000');
  const [fixedExpenses, setFixedExpenses] = useState(['350,000', '55,000', '60,000', '30,000']);
  const [challenges, setChallenges] = useState(challengeOptions);
  const [customChallenge, setCustomChallenge] = useState('');

  const totalFixed = 495000;
  const availableBudget = 1200000 - totalFixed;

  const toggleChallenge = (id: number) => {
    setChallenges(challenges.map(c => c.id === id ? { ...c, active: !c.active } : c));
  };

  return (
    <PhoneFrame bgColor="#F5F3FF">
      <div className="px-6 pb-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-5">
          <button
            onClick={() => step > 0 ? setStep(0) : navigate('/onboarding/mbti')}
            className="text-gray-500 text-sm"
            style={{ background: 'none', border: 'none', cursor: 'pointer' }}
          >
            ← 이전
          </button>
          <div className="flex gap-2">
            <div className="w-8 h-1.5 rounded-full" style={{ background: '#7C63F5' }} />
            <div className="w-8 h-1.5 rounded-full" style={{ background: step >= 1 ? '#7C63F5' : '#E9E5FF' }} />
          </div>
          <div className="w-10" />
        </div>

        {step === 0 ? (
          <>
            <h2 className="text-gray-900 mb-1" style={{ fontSize: '22px', fontWeight: 800 }}>재무 정보를 입력해요</h2>
            <p className="text-gray-500 text-sm mb-6">이 정보로 맞춤형 예산을 계산할게요</p>

            {/* Income */}
            <div
              className="rounded-2xl p-4 mb-4"
              style={{ background: 'white', boxShadow: '0 2px 12px rgba(124,99,245,0.08)' }}
            >
              <label className="text-sm text-gray-500 mb-2 block">💰 월 수입 (세후)</label>
              <div className="flex items-center">
                <input
                  value={income}
                  onChange={e => setIncome(e.target.value)}
                  className="flex-1 outline-none text-gray-900"
                  style={{ fontSize: '22px', fontWeight: 700, background: 'transparent', border: 'none' }}
                />
                <span className="text-gray-500">원</span>
              </div>
            </div>

            {/* Fixed expenses */}
            <div className="mb-4">
              <p className="text-sm text-gray-600 mb-3" style={{ fontWeight: 600 }}>📌 고정 지출</p>
              <div className="flex flex-col gap-2">
                {fixedExpenseItems.map((item, idx) => (
                  <div
                    key={idx}
                    className="flex items-center gap-3 p-3 rounded-2xl"
                    style={{ background: 'white', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
                  >
                    <span style={{ fontSize: '22px' }}>{item.icon}</span>
                    <div className="flex-1">
                      <p className="text-xs text-gray-400">{item.label}</p>
                      <div className="flex items-center">
                        <input
                          value={fixedExpenses[idx]}
                          onChange={e => {
                            const newEx = [...fixedExpenses];
                            newEx[idx] = e.target.value;
                            setFixedExpenses(newEx);
                          }}
                          className="outline-none text-gray-800 w-full"
                          style={{ fontSize: '15px', fontWeight: 600, background: 'transparent', border: 'none' }}
                        />
                        <span className="text-gray-400 text-xs">원</span>
                      </div>
                    </div>
                    <Trash2 size={16} className="text-gray-300" />
                  </div>
                ))}
                <button
                  className="flex items-center gap-2 p-3 rounded-2xl border-dashed border-2 text-gray-400 justify-center"
                  style={{ borderColor: '#DDD8FF', background: 'transparent', cursor: 'pointer' }}
                >
                  <Plus size={16} /> 항목 추가
                </button>
              </div>
            </div>

            {/* Budget preview */}
            <div
              className="rounded-2xl p-4 mb-6"
              style={{ background: 'linear-gradient(135deg, #7C63F5, #A78BFA)', color: 'white' }}
            >
              <p className="text-sm opacity-80 mb-1">이번 달 사용 가능 예산</p>
              <p style={{ fontSize: '28px', fontWeight: 800 }}>
                {availableBudget.toLocaleString()}원
              </p>
              <p className="text-xs opacity-70 mt-1">
                수입 120만원 - 고정지출 {totalFixed.toLocaleString()}원
              </p>
            </div>

            <button
              onClick={() => setStep(1)}
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
              절제 챌린지 설정 <ChevronRight size={18} />
            </button>
          </>
        ) : (
          <>
            <div className="flex items-center gap-3 mb-2">
              <Target size={24} color="#7C63F5" />
              <h2 className="text-gray-900" style={{ fontSize: '22px', fontWeight: 800 }}>절제 챌린지</h2>
            </div>
            <p className="text-gray-500 text-sm mb-6">이번 달 도전할 목표를 선택해요</p>

            <div className="flex flex-col gap-3 mb-5">
              {challenges.map((c) => (
                <button
                  key={c.id}
                  onClick={() => toggleChallenge(c.id)}
                  className="flex items-center gap-3 p-4 rounded-2xl text-left"
                  style={{
                    background: c.active ? '#EDE9FE' : 'white',
                    border: c.active ? '2px solid #7C63F5' : '2px solid #F0EEFF',
                    cursor: 'pointer',
                    transition: 'all 0.2s ease',
                  }}
                >
                  <span style={{ fontSize: '24px' }}>{c.emoji}</span>
                  <span className="flex-1 text-gray-700 text-sm" style={{ fontWeight: 500 }}>{c.text}</span>
                  <div
                    className="w-6 h-6 rounded-full flex items-center justify-center"
                    style={{ background: c.active ? '#7C63F5' : '#F0EEFF' }}
                  >
                    {c.active && <span className="text-white text-xs">✓</span>}
                  </div>
                </button>
              ))}
            </div>

            {/* Custom challenge */}
            <div
              className="flex items-center gap-3 p-3 rounded-2xl mb-6"
              style={{ background: 'white', border: '1.5px solid #E9E5FF' }}
            >
              <span style={{ fontSize: '20px' }}>✏️</span>
              <input
                value={customChallenge}
                onChange={e => setCustomChallenge(e.target.value)}
                placeholder="나만의 챌린지를 입력해요..."
                className="flex-1 outline-none text-gray-700 text-sm"
                style={{ background: 'transparent', border: 'none' }}
              />
            </div>

            <div
              className="rounded-2xl p-4 mb-5 flex gap-3"
              style={{ background: '#FFF7ED' }}
            >
              <span style={{ fontSize: '24px' }}>🎯</span>
              <div>
                <p className="text-sm text-amber-700" style={{ fontWeight: 600 }}>챌린지 달성 시</p>
                <p className="text-xs text-amber-600 leading-relaxed">목표 달성할 때마다 소리가 칭찬해줄게요! 3개 연속 성공 시 캐릭터가 레벨업!</p>
              </div>
            </div>

            <button
              onClick={() => navigate('/home')}
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
              소리 시작하기! 🎉
            </button>
          </>
        )}
      </div>
    </PhoneFrame>
  );
}
