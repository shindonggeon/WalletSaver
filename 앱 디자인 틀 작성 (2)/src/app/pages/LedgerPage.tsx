import { useState } from 'react';
import { Plus, X, ChevronDown } from 'lucide-react';

const allTransactions = [
  { id: 1, name: '스타벅스', amount: -5500, category: '카페', icon: '☕', date: '04/02', type: 'expense' },
  { id: 2, name: '편의점 CU', amount: -3200, category: '생활', icon: '🏪', date: '04/02', type: 'expense' },
  { id: 3, name: '알바비 입금', amount: 600000, category: '수입', icon: '💰', date: '04/01', type: 'income' },
  { id: 4, name: '치킨마루', amount: -19000, category: '식비', icon: '🍗', date: '04/01', type: 'expense' },
  { id: 5, name: '쿠팡 주문', amount: -34000, category: '쇼핑', icon: '📦', date: '03/30', type: 'expense' },
  { id: 6, name: '지하철', amount: -1500, category: '교통', icon: '🚇', date: '03/30', type: 'expense' },
  { id: 7, name: '올리브영', amount: -28000, category: '뷰티', icon: '💄', date: '03/29', type: 'expense' },
  { id: 8, name: '넷플릭스', amount: -17000, category: '구독', icon: '🎬', date: '03/28', type: 'expense' },
  { id: 9, name: '맥도날드', amount: -12000, category: '식비', icon: '🍔', date: '03/28', type: 'expense' },
  { id: 10, name: '카카오페이 이체', amount: -50000, category: '이체', icon: '💸', date: '03/27', type: 'expense' },
];

const categories = ['식비', '카페', '쇼핑', '교통', '생활', '뷰티', '구독', '기타'];
const categoryColors: Record<string, string> = {
  식비: '#F59E0B', 카페: '#92400E', 쇼핑: '#7C63F5', 교통: '#3B82F6',
  생활: '#10B981', 뷰티: '#EC4899', 구독: '#6366F1', 기타: '#9CA3AF',
};

export function LedgerPage() {
  const [tab, setTab] = useState<'all' | 'expense' | 'income'>('all');
  const [showModal, setShowModal] = useState(false);
  const [newName, setNewName] = useState('');
  const [newAmount, setNewAmount] = useState('');
  const [newCategory, setNewCategory] = useState('식비');
  const [isIncome, setIsIncome] = useState(false);

  const filtered = allTransactions.filter(tx => {
    if (tab === 'expense') return tx.type === 'expense';
    if (tab === 'income') return tx.type === 'income';
    return true;
  });

  const totalExpense = allTransactions.filter(t => t.type === 'expense').reduce((a, t) => a + Math.abs(t.amount), 0);
  const totalIncome = allTransactions.filter(t => t.type === 'income').reduce((a, t) => a + t.amount, 0);

  // Group by date
  const grouped: Record<string, typeof allTransactions> = {};
  filtered.forEach(tx => {
    if (!grouped[tx.date]) grouped[tx.date] = [];
    grouped[tx.date].push(tx);
  });

  return (
    <div className="pb-6 px-5">
      {/* Header */}
      <div className="flex items-center justify-between mb-4 mt-1">
        <h2 className="text-gray-900" style={{ fontSize: '20px', fontWeight: 800 }}>가계부</h2>
        <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl" style={{ background: 'white', boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
          <span className="text-xs text-gray-500">2026년 4월</span>
          <ChevronDown size={14} color="#9CA3AF" />
        </div>
      </div>

      {/* Monthly summary */}
      <div className="rounded-3xl p-5 mb-4" style={{ background: 'linear-gradient(135deg, #1e1b4b, #312e81)', color: 'white' }}>
        <p className="text-white/60 text-xs mb-3">4월 요약</p>
        <div className="flex gap-4">
          <div>
            <p className="text-xs text-white/50 mb-0.5">수입</p>
            <p style={{ fontSize: '18px', fontWeight: 700, color: '#86EFAC' }}>+{totalIncome.toLocaleString()}원</p>
          </div>
          <div className="w-px bg-white/20" />
          <div>
            <p className="text-xs text-white/50 mb-0.5">지출</p>
            <p style={{ fontSize: '18px', fontWeight: 700, color: '#FCA5A5' }}>-{totalExpense.toLocaleString()}원</p>
          </div>
          <div className="w-px bg-white/20" />
          <div>
            <p className="text-xs text-white/50 mb-0.5">순이익</p>
            <p style={{ fontSize: '18px', fontWeight: 700 }}>{(totalIncome - totalExpense).toLocaleString()}원</p>
          </div>
        </div>
      </div>

      {/* Category chips */}
      <div className="flex gap-2 mb-4 overflow-x-auto pb-1">
        {Object.entries(categoryColors).map(([cat, color]) => {
          const count = allTransactions.filter(t => t.category === cat).length;
          if (!count) return null;
          return (
            <div
              key={cat}
              className="shrink-0 px-3 py-1.5 rounded-full text-xs flex items-center gap-1.5"
              style={{ background: color + '18', color: color, border: `1px solid ${color}30` }}
            >
              <div className="w-2 h-2 rounded-full" style={{ background: color }} />
              {cat}
            </div>
          );
        })}
      </div>

      {/* Tab */}
      <div className="flex rounded-2xl p-1 mb-5" style={{ background: '#E9E5FF' }}>
        {(['all', 'expense', 'income'] as const).map((t) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className="flex-1 py-2 rounded-xl text-sm transition-all"
            style={{
              background: tab === t ? '#7C63F5' : 'transparent',
              color: tab === t ? 'white' : '#6B7280',
              fontWeight: tab === t ? 600 : 400,
              border: 'none',
              cursor: 'pointer',
            }}
          >
            {t === 'all' ? '전체' : t === 'expense' ? '지출' : '수입'}
          </button>
        ))}
      </div>

      {/* Transactions grouped by date */}
      <div className="flex flex-col gap-4">
        {Object.entries(grouped).map(([date, txs]) => (
          <div key={date}>
            <p className="text-xs text-gray-400 mb-2 px-1" style={{ fontWeight: 600 }}>{date}</p>
            <div className="rounded-2xl overflow-hidden" style={{ background: 'white', boxShadow: '0 2px 12px rgba(0,0,0,0.05)' }}>
              {txs.map((tx, i) => (
                <div
                  key={tx.id}
                  className="flex items-center gap-3 px-4 py-3"
                  style={{ borderBottom: i < txs.length - 1 ? '1px solid #F9FAFB' : 'none' }}
                >
                  <div
                    className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                    style={{
                      background: tx.type === 'income' ? '#F0FDF4' : '#F5F3FF',
                      fontSize: '20px',
                    }}
                  >
                    {tx.icon}
                  </div>
                  <div className="flex-1">
                    <p className="text-gray-800 text-sm" style={{ fontWeight: 600 }}>{tx.name}</p>
                    <div className="flex items-center gap-1.5">
                      <span
                        className="text-xs px-2 py-0.5 rounded-full"
                        style={{
                          background: (categoryColors[tx.category] || '#9CA3AF') + '15',
                          color: categoryColors[tx.category] || '#9CA3AF',
                          fontWeight: 600,
                        }}
                      >
                        {tx.category}
                      </span>
                    </div>
                  </div>
                  <p
                    className="text-sm"
                    style={{ fontWeight: 700, color: tx.amount < 0 ? '#EF4444' : '#22C55E' }}
                  >
                    {tx.amount > 0 ? '+' : ''}{tx.amount.toLocaleString()}원
                  </p>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      {/* Floating Add Button */}
      <button
        onClick={() => setShowModal(true)}
        className="flex items-center justify-center gap-2 rounded-2xl text-white mt-6 mx-auto"
        style={{
          background: 'linear-gradient(135deg, #7C63F5, #A78BFA)',
          border: 'none',
          cursor: 'pointer',
          fontWeight: 600,
          padding: '14px 32px',
          boxShadow: '0 8px 24px rgba(124,99,245,0.5)',
          display: 'flex',
          width: '100%',
        }}
      >
        <Plus size={20} />
        지출 추가하기
      </button>

      {/* Add Modal */}
      {showModal && (
        <div
          className="fixed inset-0 flex items-end justify-center z-50"
          style={{ background: 'rgba(0,0,0,0.4)' }}
          onClick={() => setShowModal(false)}
        >
          <div
            className="w-full rounded-t-3xl p-6"
            style={{ background: 'white', maxWidth: '390px' }}
            onClick={e => e.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-5">
              <h3 className="text-gray-900" style={{ fontSize: '18px', fontWeight: 700 }}>지출 추가</h3>
              <button onClick={() => setShowModal(false)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>
                <X size={22} color="#9CA3AF" />
              </button>
            </div>

            <div className="flex rounded-xl p-1 mb-4" style={{ background: '#F3F4F6' }}>
              <button
                onClick={() => setIsIncome(false)}
                className="flex-1 py-2 rounded-lg text-sm"
                style={{ background: !isIncome ? '#EF4444' : 'transparent', color: !isIncome ? 'white' : '#6B7280', border: 'none', cursor: 'pointer', fontWeight: !isIncome ? 600 : 400 }}
              >지출</button>
              <button
                onClick={() => setIsIncome(true)}
                className="flex-1 py-2 rounded-lg text-sm"
                style={{ background: isIncome ? '#22C55E' : 'transparent', color: isIncome ? 'white' : '#6B7280', border: 'none', cursor: 'pointer', fontWeight: isIncome ? 600 : 400 }}
              >수입</button>
            </div>

            <div className="flex flex-col gap-3 mb-5">
              <input
                value={newName}
                onChange={e => setNewName(e.target.value)}
                placeholder="어디서 쓰셨나요?"
                className="px-4 py-3.5 rounded-2xl outline-none"
                style={{ background: '#F9FAFB', border: '1.5px solid #E5E7EB', fontSize: '15px' }}
              />
              <input
                value={newAmount}
                onChange={e => setNewAmount(e.target.value)}
                placeholder="금액 (원)"
                type="number"
                className="px-4 py-3.5 rounded-2xl outline-none"
                style={{ background: '#F9FAFB', border: '1.5px solid #E5E7EB', fontSize: '15px' }}
              />
              <div className="flex gap-2 flex-wrap">
                {categories.map(cat => (
                  <button
                    key={cat}
                    onClick={() => setNewCategory(cat)}
                    className="px-3 py-1.5 rounded-xl text-xs"
                    style={{
                      background: newCategory === cat ? '#7C63F5' : '#F0EEFF',
                      color: newCategory === cat ? 'white' : '#7C63F5',
                      border: 'none', cursor: 'pointer', fontWeight: 600,
                    }}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>

            <button
              onClick={() => setShowModal(false)}
              className="w-full py-4 rounded-2xl text-white"
              style={{
                background: 'linear-gradient(135deg, #7C63F5, #A78BFA)',
                border: 'none', cursor: 'pointer', fontWeight: 600, fontSize: '16px',
                boxShadow: '0 8px 20px rgba(124,99,245,0.4)',
              }}
            >
              추가하기
            </button>
          </div>
        </div>
      )}
    </div>
  );
}