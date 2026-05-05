import { createContext, useContext, useState, ReactNode } from 'react';

export type BudgetState = 'safe' | 'ok' | 'caution' | 'danger' | 'critical';

export interface ThemeColors {
  primary: string;
  gradFrom: string;
  gradTo: string;
  ring: string;
  bg: string;
  cardBg: string;
  label: string;
  emoji: string;
  frameColor: string;
  frameShadow: string;
  outerBg: string;
}

export const themeMap: Record<BudgetState, ThemeColors> = {
  safe: {
    primary: '#16A34A',
    gradFrom: '#14532D',
    gradTo: '#4ADE80',
    ring: '#86EFAC',
    bg: '#F0FDF4',
    cardBg: '#DCFCE7',
    label: '여유로워요!',
    emoji: '😊',
    frameColor: '#14532D',
    frameShadow: '0 0 60px rgba(34,197,94,0.4), 0 24px 48px rgba(0,0,0,0.3)',
    outerBg: 'linear-gradient(135deg, #14532D 0%, #16A34A 50%, #4ADE80 100%)',
  },
  ok: {
    primary: '#7C63F5',
    gradFrom: '#4F3CC9',
    gradTo: '#A78BFA',
    ring: '#A78BFA',
    bg: '#F5F3FF',
    cardBg: '#EDE9FE',
    label: '보통이에요',
    emoji: '😌',
    frameColor: '#1a1a2e',
    frameShadow: '0 0 60px rgba(124,99,245,0.3), 0 24px 48px rgba(0,0,0,0.3)',
    outerBg: 'linear-gradient(135deg, #4F3CC9 0%, #7C63F5 50%, #A78BFA 100%)',
  },
  caution: {
    primary: '#D97706',
    gradFrom: '#78350F',
    gradTo: '#FCD34D',
    ring: '#FCD34D',
    bg: '#FFFBEB',
    cardBg: '#FEF3C7',
    label: '조심하세요!',
    emoji: '😐',
    frameColor: '#78350F',
    frameShadow: '0 0 60px rgba(245,158,11,0.5), 0 24px 48px rgba(0,0,0,0.3)',
    outerBg: 'linear-gradient(135deg, #78350F 0%, #D97706 50%, #FCD34D 100%)',
  },
  danger: {
    primary: '#DC2626',
    gradFrom: '#7F1D1D',
    gradTo: '#F87171',
    ring: '#FCA5A5',
    bg: '#FEF2F2',
    cardBg: '#FEE2E2',
    label: '위험해요!',
    emoji: '😰',
    frameColor: '#7F1D1D',
    frameShadow: '0 0 60px rgba(239,68,68,0.6), 0 24px 48px rgba(0,0,0,0.3)',
    outerBg: 'linear-gradient(135deg, #7F1D1D 0%, #DC2626 50%, #F87171 100%)',
  },
  critical: {
    primary: '#B91C1C',
    gradFrom: '#450A0A',
    gradTo: '#EF4444',
    ring: '#EF4444',
    bg: '#FFF1F2',
    cardBg: '#FFE4E6',
    label: '초과 위험!!',
    emoji: '😱',
    frameColor: '#450A0A',
    frameShadow: '0 0 80px rgba(239,68,68,0.8), 0 24px 48px rgba(0,0,0,0.4)',
    outerBg: 'linear-gradient(135deg, #450A0A 0%, #B91C1C 50%, #EF4444 100%)',
  },
};

export const getBudgetState = (pct: number): BudgetState => {
  if (pct >= 80) return 'safe';
  if (pct >= 60) return 'ok';
  if (pct >= 40) return 'caution';
  if (pct >= 20) return 'danger';
  return 'critical';
};

interface BudgetContextType {
  budgetPct: number;
  setBudgetPct: (v: number) => void;
  budgetState: BudgetState;
  theme: ThemeColors;
}

const BudgetContext = createContext<BudgetContextType>({
  budgetPct: 36,
  setBudgetPct: () => {},
  budgetState: 'danger',
  theme: themeMap.danger,
});

export function BudgetProvider({ children }: { children: ReactNode }) {
  const [budgetPct, setBudgetPct] = useState(36);
  const budgetState = getBudgetState(budgetPct);
  const theme = themeMap[budgetState];

  return (
    <BudgetContext.Provider value={{ budgetPct, setBudgetPct, budgetState, theme }}>
      {children}
    </BudgetContext.Provider>
  );
}

export const useBudget = () => useContext(BudgetContext);
