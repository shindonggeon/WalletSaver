import { useLocation, useNavigate } from 'react-router';
import { motion } from 'motion/react';
import { Home, BookOpen, Smile, MapPin } from 'lucide-react';
import { useBudget } from '../context/BudgetContext';

const navItems = [
  { path: '/home', icon: Home, label: '홈' },
  { path: '/ledger', icon: BookOpen, label: '가계부' },
  { path: '/character', icon: Smile, label: '캐릭터' },
  { path: '/danger', icon: MapPin, label: '위험지역' },
];

export function BottomNav() {
  const location = useLocation();
  const navigate = useNavigate();
  const { theme } = useBudget();

  return (
    <motion.div
      className="flex items-center justify-around shrink-0"
      animate={{ background: 'white', borderTopColor: `${theme.primary}30` }}
      style={{
        borderTop: `2px solid ${theme.primary}30`,
        paddingBottom: '16px',
        paddingTop: '10px',
        background: 'white',
        transition: 'border-color 0.8s ease',
      }}
    >
      {navItems.map((item) => {
        const isActive = location.pathname === item.path;
        const Icon = item.icon;
        return (
          <button
            key={item.path}
            onClick={() => navigate(item.path)}
            className="flex flex-col items-center gap-0.5 px-4 py-1 relative"
            style={{ background: 'none', border: 'none', cursor: 'pointer' }}
          >
            {/* Active dot indicator */}
            {isActive && (
              <motion.div
                layoutId="navIndicator"
                className="absolute -top-2 left-1/2 -translate-x-1/2 w-5 h-1 rounded-full"
                style={{ background: theme.primary }}
                transition={{ type: 'spring', stiffness: 400, damping: 30 }}
              />
            )}
            <motion.div
              animate={{ color: isActive ? theme.primary : '#9CA3AF' }}
              transition={{ duration: 0.3 }}
            >
              <Icon size={22} strokeWidth={isActive ? 2.5 : 1.8} />
            </motion.div>
            <motion.span
              className="text-xs"
              animate={{
                color: isActive ? theme.primary : '#9CA3AF',
                fontWeight: isActive ? 700 : 400,
              }}
              transition={{ duration: 0.3 }}
            >
              {item.label}
            </motion.span>
          </button>
        );
      })}
    </motion.div>
  );
}
