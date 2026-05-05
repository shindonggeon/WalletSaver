import { useState } from 'react';
import { motion } from 'motion/react';
import { useNavigate } from 'react-router';
import { Eye, EyeOff } from 'lucide-react';

export function LoginPage() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [isSignup, setIsSignup] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');

  const handleSubmit = () => {
    if (isSignup) {
      navigate('/onboarding/mbti');
    } else {
      navigate('/home');
    }
  };

  return (
    <div
      className="min-h-screen flex items-center justify-center py-6 px-4"
      style={{
        background: 'linear-gradient(135deg, #4F3CC9 0%, #7C63F5 40%, #A78BFA 80%, #C4B5FD 100%)',
      }}
    >
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-20 -right-20 w-72 h-72 bg-white/10 rounded-full blur-3xl" />
        <div className="absolute -bottom-20 -left-20 w-96 h-96 bg-white/5 rounded-full blur-3xl" />
      </div>

      <motion.div
        className="z-10 w-full"
        style={{ maxWidth: '390px' }}
        initial={{ opacity: 0, scale: 0.94, y: 24 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        transition={{ duration: 0.45, ease: [0.25, 0.1, 0.25, 1] }}
      >
        <div
          className="relative shadow-2xl overflow-hidden"
          style={{
            borderRadius: '42px',
            border: '8px solid #1a1a2e',
            background: '#F5F3FF',
          }}
        >
          {/* Notch */}
          <div className="absolute top-0 left-1/2 -translate-x-1/2 z-50"
            style={{ width: '120px', height: '30px', background: '#1a1a2e', borderBottomLeftRadius: '18px', borderBottomRightRadius: '18px' }} />
          {/* Status bar */}
          <div className="flex items-center justify-between px-8 pt-1" style={{ height: '48px' }}>
            <span className="text-xs font-semibold text-gray-700">9:41</span>
          </div>

          <div className="px-7 pb-10">
            {/* Logo */}
            <div className="flex flex-col items-center mb-8 mt-2">
              <div
                className="w-20 h-20 rounded-3xl flex items-center justify-center mb-4 shadow-lg"
                style={{ background: 'linear-gradient(135deg, #7C63F5, #A78BFA)' }}
              >
                <span style={{ fontSize: '38px' }}>🐿️</span>
              </div>
              <h2 className="text-gray-900" style={{ fontSize: '28px', fontWeight: 700, letterSpacing: '-0.5px' }}>소리</h2>
              <p className="text-gray-500 text-sm text-center mt-1">지갑을 지키는 가장 똑똑한 잔소리</p>
            </div>

            {/* Tab */}
            <div className="flex rounded-2xl p-1 mb-6" style={{ background: '#E9E5FF' }}>
              <button
                onClick={() => setIsSignup(false)}
                className="flex-1 py-2.5 rounded-xl text-sm transition-all"
                style={{
                  background: !isSignup ? '#7C63F5' : 'transparent',
                  color: !isSignup ? 'white' : '#6B7280',
                  fontWeight: !isSignup ? 600 : 400,
                  border: 'none',
                  cursor: 'pointer',
                }}
              >
                로그인
              </button>
              <button
                onClick={() => setIsSignup(true)}
                className="flex-1 py-2.5 rounded-xl text-sm transition-all"
                style={{
                  background: isSignup ? '#7C63F5' : 'transparent',
                  color: isSignup ? 'white' : '#6B7280',
                  fontWeight: isSignup ? 600 : 400,
                  border: 'none',
                  cursor: 'pointer',
                }}
              >
                회원가입
              </button>
            </div>

            {/* Form */}
            <div className="flex flex-col gap-3">
              {isSignup && (
                <div>
                  <label className="text-sm text-gray-600 mb-1.5 block">이름</label>
                  <input
                    value={name}
                    onChange={e => setName(e.target.value)}
                    placeholder="홍길동"
                    className="w-full px-4 py-3.5 rounded-2xl outline-none text-gray-800"
                    style={{ background: 'white', border: '1.5px solid #E5E7EB', fontSize: '15px' }}
                  />
                </div>
              )}
              <div>
                <label className="text-sm text-gray-600 mb-1.5 block">이메일</label>
                <input
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  placeholder="example@email.com"
                  className="w-full px-4 py-3.5 rounded-2xl outline-none text-gray-800"
                  style={{ background: 'white', border: '1.5px solid #E5E7EB', fontSize: '15px' }}
                />
              </div>
              <div>
                <label className="text-sm text-gray-600 mb-1.5 block">비밀번호</label>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="w-full px-4 py-3.5 rounded-2xl outline-none text-gray-800 pr-12"
                    style={{ background: 'white', border: '1.5px solid #E5E7EB', fontSize: '15px' }}
                  />
                  <button
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400"
                    style={{ background: 'none', border: 'none', cursor: 'pointer' }}
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              <button
                onClick={handleSubmit}
                className="w-full py-4 rounded-2xl text-white mt-2"
                style={{
                  background: 'linear-gradient(135deg, #7C63F5, #A78BFA)',
                  border: 'none',
                  cursor: 'pointer',
                  fontWeight: 600,
                  fontSize: '16px',
                  boxShadow: '0 8px 20px rgba(124,99,245,0.4)',
                }}
              >
                {isSignup ? '소비 성향 테스트 시작 →' : '로그인'}
              </button>
            </div>

            {/* Divider */}
            <div className="flex items-center gap-3 my-5">
              <div className="flex-1 h-px bg-gray-200" />
              <span className="text-xs text-gray-400">또는</span>
              <div className="flex-1 h-px bg-gray-200" />
            </div>

            {/* Social login */}
            <button
              className="w-full py-3.5 rounded-2xl flex items-center justify-center gap-3"
              style={{ background: '#FEE500', border: 'none', cursor: 'pointer', fontWeight: 600 }}
            >
              <span style={{ fontSize: '20px' }}>💬</span>
              <span className="text-gray-800">카카오로 시작하기</span>
            </button>

            {!isSignup && (
              <p className="text-center text-xs text-gray-400 mt-4">
                계정이 없으신가요?{' '}
                <button
                  onClick={() => setIsSignup(true)}
                  className="text-purple-500 underline"
                  style={{ background: 'none', border: 'none', cursor: 'pointer' }}
                >
                  회원가입
                </button>
              </p>
            )}
          </div>
        </div>
      </motion.div>
    </div>
  );
}