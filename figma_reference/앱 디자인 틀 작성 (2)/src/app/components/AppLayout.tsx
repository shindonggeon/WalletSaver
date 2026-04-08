import { Outlet, useLocation } from 'react-router';
import { motion, AnimatePresence } from 'motion/react';
import { BottomNav } from './BottomNav';
import { useBudget } from '../context/BudgetContext';

export function AppLayout() {
  const location = useLocation();
  const { theme, budgetPct } = useBudget();

  return (
    <motion.div
      className="min-h-screen flex items-center justify-center py-6 px-4"
      animate={{ background: theme.outerBg }}
      transition={{ duration: 1.2, ease: 'easeInOut' }}
      style={{ background: theme.outerBg }}
    >
      {/* Ambient glow blobs */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute -top-20 -right-20 w-80 h-80 rounded-full blur-3xl"
          animate={{ background: `${theme.primary}25` }}
          transition={{ duration: 1.2 }}
        />
        <motion.div
          className="absolute -bottom-20 -left-20 w-96 h-96 rounded-full blur-3xl"
          animate={{ background: `${theme.primary}15` }}
          transition={{ duration: 1.2 }}
        />
      </div>

      <div className="flex flex-col items-center gap-4 z-10">
        {/* Branding */}
        <div className="text-center text-white/80 mb-1">
          <p className="text-sm tracking-widest uppercase font-medium opacity-70">지갑비서</p>
          <h1 className="text-3xl tracking-tight text-white">
            소리 <span className="text-white/60 text-xl font-normal">Sori</span>
          </h1>
          <p className="text-xs text-white/50 mt-1">당신의 지갑을 지키는 가장 똑똑한 잔소리</p>
        </div>

        {/* Phone frame */}
        <motion.div
          className="relative flex flex-col overflow-hidden"
          animate={{
            borderColor: theme.frameColor,
            boxShadow: theme.frameShadow,
          }}
          transition={{ duration: 1.2, ease: 'easeInOut' }}
          style={{
            width: '390px',
            maxWidth: '100vw',
            height: '820px',
            borderRadius: '42px',
            border: `8px solid ${theme.frameColor}`,
            boxShadow: theme.frameShadow,
          }}
        >
          {/* Notch */}
          <div
            className="absolute top-0 left-1/2 -translate-x-1/2 z-50"
            style={{
              width: '120px',
              height: '30px',
              background: theme.frameColor,
              borderBottomLeftRadius: '18px',
              borderBottomRightRadius: '18px',
              transition: 'background 1.2s ease',
            }}
          />

          {/* Status bar */}
          <motion.div
            className="flex items-center justify-between px-8 pt-1 shrink-0"
            style={{ height: '48px' }}
            animate={{ background: theme.bg }}
            transition={{ duration: 1.2 }}
          >
            <span className="text-xs font-semibold text-gray-700">9:41</span>
            <div className="flex items-center gap-1">
              {/* Signal */}
              <svg width="16" height="12" viewBox="0 0 16 12" fill="none">
                <rect x="0" y="4" width="3" height="8" rx="1" fill="#374151" />
                <rect x="4" y="2.5" width="3" height="9.5" rx="1" fill="#374151" />
                <rect x="8" y="1" width="3" height="11" rx="1" fill="#374151" />
                <rect x="12" y="0" width="3" height="12" rx="1" fill="#374151" />
              </svg>
              {/* WiFi */}
              <svg width="15" height="12" viewBox="0 0 15 12" fill="none">
                <path d="M7.5 2.5C9.8 2.5 11.8 3.4 13.3 4.9L14.7 3.5C12.8 1.6 10.3 0.5 7.5 0.5C4.7 0.5 2.2 1.6 0.3 3.5L1.7 4.9C3.2 3.4 5.2 2.5 7.5 2.5Z" fill="#374151" />
                <path d="M7.5 5.5C9.0 5.5 10.3 6.1 11.3 7.0L12.7 5.6C11.3 4.3 9.5 3.5 7.5 3.5C5.5 3.5 3.7 4.3 2.3 5.6L3.7 7.0C4.7 6.1 6.0 5.5 7.5 5.5Z" fill="#374151" />
                <circle cx="7.5" cy="10" r="2" fill="#374151" />
              </svg>
              {/* Battery */}
              <div className="w-5 h-2.5 rounded-sm border border-gray-600 relative">
                <div className="absolute inset-0.5 bg-gray-700 rounded-sm" style={{ width: '70%' }} />
              </div>
            </div>
          </motion.div>

          {/* Critical pulse overlay when budget < 20% */}
          <AnimatePresence>
            {budgetPct < 20 && (
              <motion.div
                className="absolute inset-0 pointer-events-none z-40 rounded-[34px]"
                initial={{ opacity: 0 }}
                animate={{ opacity: [0, 0.12, 0] }}
                exit={{ opacity: 0 }}
                transition={{ duration: 1, repeat: Infinity, repeatType: 'loop' }}
                style={{ background: '#EF4444', borderRadius: '34px' }}
              />
            )}
          </AnimatePresence>

          {/* Page content with transitions */}
          <motion.div
            className="flex-1 overflow-y-auto"
            animate={{ background: theme.bg }}
            transition={{ duration: 1.2 }}
          >
            <AnimatePresence mode="wait">
              <motion.div
                key={location.pathname}
                initial={{ opacity: 0, x: 24 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -24 }}
                transition={{ duration: 0.22, ease: [0.25, 0.1, 0.25, 1] }}
                style={{ minHeight: '100%' }}
              >
                <Outlet />
              </motion.div>
            </AnimatePresence>
          </motion.div>

          {/* Bottom navigation */}
          <BottomNav />
        </motion.div>
      </div>
    </motion.div>
  );
}
