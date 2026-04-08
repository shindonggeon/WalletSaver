import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Bell, ChevronRight, SlidersHorizontal } from 'lucide-react';
import { AnimatedCharacter } from '../components/AnimatedCharacter';
import { useBudget } from '../context/BudgetContext';

const MONTHLY_BUDGET = 750000;
const DAYS_REMAINING = 28;

const recentTransactions = [
  { id: 1, name: '스타벅스', amount: -5500, category: '카페', icon: '☕', time: '오늘 11:30' },
  { id: 2, name: '편의점 CU', amount: -3200, category: '생활', icon: '🏪', time: '오늘 09:15' },
  { id: 3, name: '치킨마루', amount: -19000, category: '식비', icon: '🍗', time: '어제 20:00' },
  { id: 4, name: '쿠팡', amount: -34000, category: '쇼핑', icon: '📦', time: '어제 14:22' },
];

const nagMessages: Record<string, string> = {
  safe: '잘 하고 있어요! 이 페이스 유지하면 이번 달 목표 달성할 수 있어요 🎉',
  ok: '스타필드 코엑스 반경 100m입니다! 들어가기 전에 예산 확인해요 💜',
  caution: '⚠️ 예산의 60%를 썼어요. 이번주는 배달 주문 줄여보는 건 어때요?',
  danger: '🚨 위험! 예산의 80%를 사용했어요. 지금 당장 지출을 멈춰야 해요!',
  critical: '💀 예산 초과 직전이에요!! 제발요... 지갑 닫고 집에 가세요!!!',
};

export function DashboardPage() {
  const { budgetPct, setBudgetPct, theme, budgetState } = useBudget();
  const [showNag, setShowNag] = useState(true);
  const [showSimulator, setShowSimulator] = useState(false);

  const remaining = Math.round(MONTHLY_BUDGET * budgetPct / 100);
  const spent = MONTHLY_BUDGET - remaining;
  const dailyBudget = Math.max(0, Math.round(remaining / DAYS_REMAINING));

  return (
    <div className="pb-4 px-5">
      {/* Header */}
      <div className="flex items-center justify-between mb-5 mt-1">
        <div>
          <p className="text-xs text-gray-400">2026년 4월 2일 목요일</p>
          <motion.h2
            className="text-gray-900"
            style={{ fontSize: '18px', fontWeight: 700 }}
          >
            안녕하세요, 소리님 👋
          </motion.h2>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => setShowSimulator(!showSimulator)}
            className="w-10 h-10 rounded-xl flex items-center justify-center"
            style={{ background: showSimulator ? theme.cardBg : 'white', border: 'none', cursor: 'pointer', boxShadow: '0 2px 8px rgba(0,0,0,0.08)' }}
          >
            <SlidersHorizontal size={18} color={showSimulator ? theme.primary : '#374151'} />
          </button>
          <div className="relative">
            <button
              className="w-10 h-10 rounded-xl flex items-center justify-center"
              style={{ background: 'white', border: 'none', cursor: 'pointer', boxShadow: '0 2px 8px rgba(0,0,0,0.08)' }}
            >
              <Bell size={20} color="#374151" />
            </button>
            <div className="absolute -top-1 -right-1 w-4 h-4 rounded-full flex items-center justify-center" style={{ background: '#EF4444' }}>
              <span className="text-white" style={{ fontSize: '9px', fontWeight: 700 }}>2</span>
            </div>
          </div>
        </div>
      </div>

      {/* Demo Simulator */}
      <AnimatePresence>
        {showSimulator && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3, ease: 'easeInOut' }}
            className="overflow-hidden mb-4"
          >
            <div
              className="rounded-2xl p-4"
              style={{ background: '#1e1b4b', border: '1px solid rgba(255,255,255,0.1)' }}
            >
              <div className="flex items-center gap-2 mb-3">
                <span style={{ fontSize: '16px' }}>🎮</span>
                <p className="text-white text-sm" style={{ fontWeight: 700 }}>데모 시뮬레이터</p>
                <span
                  className="ml-auto px-2 py-0.5 rounded-full text-xs"
                  style={{ background: `${theme.primary}40`, color: theme.ring }}
                >
                  {theme.label} {theme.emoji}
                </span>
              </div>
              <p className="text-white/50 text-xs mb-3">슬라이더로 예산 상태를 바꿔보세요</p>

              <div className="flex items-center gap-3">
                <span className="text-xs text-white/40">0%</span>
                <input
                  type="range"
                  min={0}
                  max={100}
                  value={budgetPct}
                  onChange={e => setBudgetPct(Number(e.target.value))}
                  className="flex-1 h-2 rounded-full cursor-pointer"
                  style={{ accentColor: theme.primary }}
                />
                <span className="text-xs text-white/40">100%</span>
              </div>

              <div className="flex justify-between mt-2">
                {[
                  { pct: 5, label: '😱 초과' },
                  { pct: 30, label: '😰 위험' },
                  { pct: 50, label: '😐 주의' },
                  { pct: 70, label: '😌 보통' },
                  { pct: 90, label: '😊 여유' },
                ].map(({ pct, label }) => (
                  <button
                    key={pct}
                    onClick={() => setBudgetPct(pct)}
                    className="text-xs px-1.5 py-1 rounded-lg"
                    style={{
                      background: budgetPct === pct ? theme.primary : 'rgba(255,255,255,0.1)',
                      color: budgetPct === pct ? 'white' : 'rgba(255,255,255,0.5)',
                      border: 'none', cursor: 'pointer',
                    }}
                  >
                    {label}
                  </button>
                ))}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* AI Nag Alert */}
      <AnimatePresence>
        {showNag && (
          <motion.div
            initial={{ opacity: 0, y: -10, scale: 0.96 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, height: 0, marginBottom: 0, y: -10 }}
            transition={{ duration: 0.3 }}
            className="rounded-2xl p-4 mb-5 flex gap-3 items-start relative"
            style={{
              background: theme.cardBg,
              border: `1.5px solid ${theme.ring}80`,
            }}
          >
            <motion.span
              style={{ fontSize: '22px' }}
              animate={{ rotate: [-5, 5, -5, 5, 0] }}
              transition={{ duration: 0.5, delay: 0.5 }}
            >
              🤖
            </motion.span>
            <div className="flex-1">
              <p className="text-xs mb-0.5" style={{ fontWeight: 700, color: theme.primary }}>
                소리의 잔소리
              </p>
              <AnimatePresence mode="wait">
                <motion.p
                  key={budgetState}
                  className="text-sm leading-relaxed text-gray-700"
                  initial={{ opacity: 0, y: 4 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -4 }}
                  transition={{ duration: 0.25 }}
                >
                  {nagMessages[budgetState]}
                </motion.p>
              </AnimatePresence>
            </div>
            <button
              onClick={() => setShowNag(false)}
              className="text-gray-300 shrink-0"
              style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: '16px' }}
            >
              ✕
            </button>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Character Card */}
      <motion.div
        className="rounded-3xl p-5 mb-4 flex items-center gap-4"
        animate={{
          background: theme.cardBg,
          borderColor: `${theme.ring}60`,
        }}
        transition={{ duration: 0.8 }}
        style={{ border: `2px solid ${theme.ring}60` }}
      >
        <div className="shrink-0">
          <AnimatedCharacter
            state={budgetState}
            size={48}
            ringColor={theme.ring}
            showName={false}
          />
        </div>
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <motion.span
              className="px-2.5 py-0.5 rounded-full text-xs text-white"
              animate={{ background: theme.primary }}
              transition={{ duration: 0.8 }}
              style={{ fontWeight: 600 }}
            >
              🐿️ 충동적 다람쥐
            </motion.span>
          </div>
          <AnimatePresence mode="wait">
            <motion.p
              key={budgetState}
              className="text-gray-700 text-sm mb-1"
              style={{ fontWeight: 700 }}
              initial={{ opacity: 0, x: 10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -10 }}
              transition={{ duration: 0.25 }}
            >
              {theme.label}
            </motion.p>
          </AnimatePresence>
          <p className="text-xs text-gray-500">예산 {budgetPct}% 남음</p>

          {/* Budget bar */}
          <div className="mt-2 h-2 rounded-full overflow-hidden" style={{ background: '#E5E7EB' }}>
            <motion.div
              className="h-full rounded-full"
              animate={{ width: `${budgetPct}%`, background: theme.primary }}
              transition={{ duration: 0.8, ease: 'easeOut' }}
            />
          </div>
        </div>
      </motion.div>

      {/* Today's budget big card */}
      <motion.div
        className="rounded-3xl p-5 mb-4"
        animate={{
          background: `linear-gradient(135deg, ${theme.gradFrom}, ${theme.gradTo})`,
          boxShadow: `0 8px 24px ${theme.primary}50`,
        }}
        transition={{ duration: 0.8 }}
      >
        <p className="text-white/70 text-sm mb-1">오늘 쓸 수 있는 돈</p>
        <AnimatePresence mode="wait">
          <motion.p
            key={dailyBudget}
            className="text-white mb-3"
            style={{ fontSize: '34px', fontWeight: 800, letterSpacing: '-1px' }}
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            transition={{ duration: 0.3 }}
          >
            {dailyBudget.toLocaleString()}원
          </motion.p>
        </AnimatePresence>

        <div className="flex gap-3">
          {[
            { label: '이번달 예산', value: MONTHLY_BUDGET },
            { label: '지출', value: spent },
            { label: '잔여', value: remaining },
          ].map((item, i) => (
            <div
              key={i}
              className="flex-1 rounded-2xl p-3 text-center"
              style={{ background: 'rgba(255,255,255,0.18)' }}
            >
              <p className="text-white/70" style={{ fontSize: '10px' }}>{item.label}</p>
              <motion.p
                className="text-white"
                style={{ fontSize: '13px', fontWeight: 700 }}
                key={item.value}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ duration: 0.4, delay: i * 0.05 }}
              >
                {(item.value / 10000).toFixed(1)}만원
              </motion.p>
            </div>
          ))}
        </div>
      </motion.div>

      {/* Challenge card */}
      <motion.div
        className="rounded-2xl p-4 mb-4 flex items-center justify-between"
        style={{ background: 'white', boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.15 }}
      >
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#FFF7ED', fontSize: '22px' }}>
            🎯
          </div>
          <div>
            <p className="text-gray-800 text-sm" style={{ fontWeight: 600 }}>카페 주 3회 이하</p>
            <p className="text-xs text-gray-400">이번주 2회 / 목표 3회</p>
          </div>
        </div>
        <div className="px-3 py-1.5 rounded-xl text-xs" style={{ background: '#F0FDF4', color: '#22C55E', fontWeight: 600 }}>
          달성 중 ✓
        </div>
      </motion.div>

      {/* Recent Transactions */}
      <motion.div
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
      >
        <div className="flex items-center justify-between mb-3">
          <p className="text-gray-800 text-sm" style={{ fontWeight: 700 }}>최근 지출</p>
          <button className="text-xs flex items-center gap-0.5" style={{ background: 'none', border: 'none', cursor: 'pointer', color: theme.primary }}>
            전체보기 <ChevronRight size={14} />
          </button>
        </div>

        <div className="rounded-2xl overflow-hidden" style={{ background: 'white', boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
          {recentTransactions.map((tx, i) => (
            <motion.div
              key={tx.id}
              className="flex items-center gap-3 px-4 py-3"
              style={{ borderBottom: i < recentTransactions.length - 1 ? '1px solid #F3F4F6' : 'none' }}
              initial={{ opacity: 0, x: 16 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.25 + i * 0.06 }}
            >
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                style={{ background: theme.cardBg, fontSize: '20px' }}
              >
                {tx.icon}
              </div>
              <div className="flex-1">
                <p className="text-gray-800 text-sm" style={{ fontWeight: 600 }}>{tx.name}</p>
                <p className="text-xs text-gray-400">{tx.time} · {tx.category}</p>
              </div>
              <p className="text-sm" style={{ fontWeight: 700, color: '#EF4444' }}>
                {tx.amount.toLocaleString()}원
              </p>
            </motion.div>
          ))}
        </div>
      </motion.div>
    </div>
  );
}
