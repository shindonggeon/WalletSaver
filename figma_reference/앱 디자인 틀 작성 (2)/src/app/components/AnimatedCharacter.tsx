import { motion, AnimatePresence } from 'motion/react';
import { BudgetState } from '../context/BudgetContext';

const characterData: Record<BudgetState, { emoji: string; name: string; color: string }> = {
  safe:     { emoji: '😊', name: '행복한 다람쥐', color: '#16A34A' },
  ok:       { emoji: '😌', name: '편안한 다람쥐', color: '#7C63F5' },
  caution:  { emoji: '😐', name: '걱정되는 다람쥐', color: '#D97706' },
  danger:   { emoji: '😰', name: '불안한 다람쥐', color: '#DC2626' },
  critical: { emoji: '😱', name: '패닉 다람쥐', color: '#B91C1C' },
};

// Per-state animation configs
const stateAnimations: Record<BudgetState, object> = {
  safe: {
    y: [0, -12, 0],
    transition: { duration: 1.8, repeat: Infinity, ease: 'easeInOut' },
  },
  ok: {
    y: [0, -6, 0],
    transition: { duration: 2.4, repeat: Infinity, ease: 'easeInOut' },
  },
  caution: {
    rotate: [0, -4, 4, -4, 0],
    transition: { duration: 2, repeat: Infinity, ease: 'easeInOut' },
  },
  danger: {
    x: [-5, 5, -5, 5, -3, 3, 0],
    transition: { duration: 0.6, repeat: Infinity },
  },
  critical: {
    x: [-7, 7, -7, 7, 0],
    rotate: [-10, 10, -10, 10, 0],
    scale: [1, 1.08, 1, 1.08, 1],
    transition: { duration: 0.35, repeat: Infinity },
  },
};

interface Props {
  state: BudgetState;
  size?: number;
  ringColor?: string;
  showName?: boolean;
}

export function AnimatedCharacter({ state, size = 56, ringColor, showName = false }: Props) {
  const { emoji, name, color } = characterData[state];
  const rColor = ringColor || color;

  return (
    <div className="flex flex-col items-center gap-2">
      <div className="relative flex items-center justify-center" style={{ width: size * 1.8, height: size * 1.8 }}>
        {/* Outer glow ring */}
        <motion.div
          className="absolute rounded-full"
          style={{
            width: size * 1.7,
            height: size * 1.7,
            border: `2px solid ${rColor}50`,
          }}
          animate={{ scale: [1, 1.15, 1], opacity: [0.5, 0.15, 0.5] }}
          transition={{ duration: 2.5, repeat: Infinity, ease: 'easeInOut' }}
        />
        {/* Inner ring */}
        <motion.div
          className="absolute rounded-full"
          style={{
            width: size * 1.3,
            height: size * 1.3,
            border: `3px solid ${rColor}80`,
            background: `${rColor}10`,
          }}
          animate={{ scale: [1, 1.08, 1], opacity: [0.8, 0.4, 0.8] }}
          transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut', delay: 0.3 }}
        />

        {/* Character emoji */}
        <AnimatePresence mode="wait">
          <motion.span
            key={state}
            style={{ fontSize: size, display: 'block', lineHeight: 1 }}
            initial={{ scale: 0.5, opacity: 0, rotate: -20 }}
            animate={{
              scale: 1,
              opacity: 1,
              rotate: 0,
              ...stateAnimations[state],
            }}
            exit={{ scale: 0.5, opacity: 0, rotate: 20 }}
            transition={{ type: 'spring', stiffness: 300, damping: 20 }}
          >
            {emoji}
          </motion.span>
        </AnimatePresence>
      </div>

      {showName && (
        <motion.p
          key={name}
          className="text-xs"
          style={{ color, fontWeight: 700 }}
          initial={{ opacity: 0, y: 6 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
        >
          {name}
        </motion.p>
      )}
    </div>
  );
}
