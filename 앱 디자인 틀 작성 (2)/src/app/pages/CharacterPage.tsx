import { motion } from 'motion/react';
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import { AnimatedCharacter } from '../components/AnimatedCharacter';
import { useBudget } from '../context/BudgetContext';

const categoryData = [
  { name: '식비', value: 127000, color: '#F59E0B' },
  { name: '카페', value: 89000, color: '#92400E' },
  { name: '쇼핑', value: 134000, color: '#7C63F5' },
  { name: '교통', value: 45000, color: '#3B82F6' },
  { name: '생활', value: 53000, color: '#10B981' },
  { name: '기타', value: 30000, color: '#9CA3AF' },
];

const monthlyData = [
  { month: '1월', spent: 680000 },
  { month: '2월', spent: 720000 },
  { month: '3월', spent: 810000 },
  { month: '4월', spent: 478000 },
];

const TOTAL_SPENT = categoryData.reduce((a, b) => a + b.value, 0);

export function CharacterPage() {
  const { theme, budgetState } = useBudget();

  return (
    <div className="pb-6 px-5">
      {/* Header */}
      <h2 className="text-gray-900 mb-4 mt-1" style={{ fontSize: '20px', fontWeight: 800 }}>마이 캐릭터</h2>

      {/* Character Card */}
      <motion.div
        className="rounded-3xl p-5 mb-4 text-center"
        animate={{ background: `linear-gradient(135deg, ${theme.gradFrom}, ${theme.gradTo})` }}
        transition={{ duration: 1 }}
        style={{ boxShadow: theme.frameShadow }}
      >
        <div className="flex justify-center mb-3">
          <AnimatedCharacter state={budgetState} size={56} showName={true} ringColor="rgba(255,255,255,0.5)" />
        </div>
        <h3 className="text-white mb-1" style={{ fontSize: '22px', fontWeight: 800 }}>충동적 다람쥐</h3>
        <p className="text-white/70 text-xs mb-3">소소한 지출이 모여 큰 금액이 됩니다</p>
        <div className="flex gap-2 justify-center">
          <span className="px-3 py-1 rounded-full text-xs" style={{ background: 'rgba(255,255,255,0.25)', color: 'white', fontWeight: 600 }}>
            Lv.3 다람쥐
          </span>
          <span className="px-3 py-1 rounded-full text-xs" style={{ background: 'rgba(255,200,50,0.3)', color: '#FDE68A', fontWeight: 600 }}>
            🔥 9일째 기록 중
          </span>
        </div>
      </motion.div>

      {/* Stats row */}
      <div className="flex gap-3 mb-4">
        {[
          { label: '이번달 지출', value: `${TOTAL_SPENT.toLocaleString()}원`, icon: '💸', bg: '#FEF2F2', color: '#EF4444' },
          { label: '목표 달성', value: '1 / 3개', icon: '🎯', bg: '#F0FDF4', color: '#22C55E' },
          { label: '절약 일수', value: '12일', icon: '⭐', bg: '#FFFBEB', color: '#F59E0B' },
        ].map((stat, i) => (
          <div
            key={i}
            className="flex-1 rounded-2xl p-3 text-center"
            style={{ background: stat.bg }}
          >
            <span style={{ fontSize: '20px' }}>{stat.icon}</span>
            <p className="text-xs text-gray-500 mt-1">{stat.label}</p>
            <p className="text-xs mt-0.5" style={{ fontWeight: 700, color: stat.color }}>{stat.value}</p>
          </div>
        ))}
      </div>

      {/* Category pie chart */}
      <div
        className="rounded-3xl p-4 mb-4"
        style={{ background: 'white', boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}
      >
        <p className="text-gray-800 text-sm mb-4" style={{ fontWeight: 700 }}>📊 카테고리 지출 현황</p>
        <div className="flex items-center gap-4">
          <div style={{ width: 130, height: 130 }}>
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={categoryData}
                  cx="50%"
                  cy="50%"
                  innerRadius={38}
                  outerRadius={60}
                  paddingAngle={2}
                  dataKey="value"
                >
                  {categoryData.map((entry, index) => (
                    <Cell key={index} fill={entry.color} />
                  ))}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex-1 flex flex-col gap-1.5">
            {categoryData.map((cat) => (
              <div key={cat.name} className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 rounded-full shrink-0" style={{ background: cat.color }} />
                <span className="text-xs text-gray-500 flex-1">{cat.name}</span>
                <span className="text-xs text-gray-700" style={{ fontWeight: 600 }}>
                  {Math.round(cat.value / TOTAL_SPENT * 100)}%
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Monthly trend chart */}
      <div
        className="rounded-3xl p-4 mb-4"
        style={{ background: 'white', boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}
      >
        <p className="text-gray-800 text-sm mb-4" style={{ fontWeight: 700 }}>📈 월별 지출 추이</p>
        <div style={{ height: 120 }}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={monthlyData} margin={{ top: 0, right: 0, left: -30, bottom: 0 }}>
              <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 10, fill: '#9CA3AF' }} axisLine={false} tickLine={false} tickFormatter={v => `${(v / 10000).toFixed(0)}만`} />
              <Tooltip
                formatter={(v: number) => [`${v.toLocaleString()}원`, '지출']}
                contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)', fontSize: '12px' }}
              />
              <Bar dataKey="spent" radius={[8, 8, 0, 0]}>
                {monthlyData.map((_, index) => (
                  <Cell
                    key={index}
                    fill={index === monthlyData.length - 1 ? '#7C63F5' : '#E9E5FF'}
                  />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* AI Report */}
      <div
        className="rounded-3xl p-4"
        style={{ background: '#1e1b4b', boxShadow: '0 8px 20px rgba(30,27,75,0.3)' }}
      >
        <div className="flex items-center gap-2 mb-3">
          <div
            className="w-8 h-8 rounded-xl flex items-center justify-center"
            style={{ background: 'rgba(124,99,245,0.4)', fontSize: '16px' }}
          >
            🤖
          </div>
          <div>
            <p className="text-white text-xs" style={{ fontWeight: 700 }}>소리의 분석 리포트</p>
            <p className="text-white/40" style={{ fontSize: '10px' }}>AI 생성 · 2026.04.02</p>
          </div>
        </div>
        <p className="text-white/80 text-sm leading-relaxed">
          이번 달 <span className="text-yellow-300 font-semibold">쇼핑(134,000원)</span>이 가장 많은 지출을 차지했어요.
          지난달 대비 카페 지출이 <span className="text-red-300 font-semibold">23% 증가</span>했습니다.
          <br /><br />
          저번주 이 시간에도 스타벅스에 5,500원 쓰셨는데... 혹시 습관이 된 건 아닌가요? 🤔
          이번주 카페는 남은 1회 사용 권장드려요!
        </p>
      </div>
    </div>
  );
}