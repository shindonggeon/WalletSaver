import { useState } from 'react';
import { motion } from 'motion/react';
import { Plus, MapPin, Trash2, AlertTriangle, X, Sliders } from 'lucide-react';
import { useBudget } from '../context/BudgetContext';

interface Zone {
  id: number;
  name: string;
  address: string;
  enabled: boolean;
  radius: number;
  emoji: string;
  category: string;
}

const initialZones: Zone[] = [
  { id: 1, name: '스타필드 코엑스', address: '서울 강남구 영동대로 513', enabled: true, radius: 100, emoji: '🏬', category: '쇼핑몰' },
  { id: 2, name: '신세계백화점 강남점', address: '서울 서초구 신반포로 176', enabled: true, radius: 100, emoji: '👔', category: '백화점' },
  { id: 3, name: '롯데백화점 잠실점', address: '서울 송파구 올림픽로 300', enabled: false, radius: 150, emoji: '🛍️', category: '백화점' },
  { id: 4, name: '홍대 거리', address: '서울 마포구 어울마당로', enabled: true, radius: 200, emoji: '🍻', category: '유흥' },
];

const nagLevels = [
  { level: 1, label: '부드럽게', desc: '짧고 친절한 알림', emoji: '🌸' },
  { level: 2, label: '적당히', desc: '데이터 기반 조언', emoji: '⚖️' },
  { level: 3, label: '강하게', desc: '직접적인 경고', emoji: '🔥' },
];

export function DangerZonePage() {
  const [zones, setZones] = useState<Zone[]>(initialZones);
  const [nagLevel, setNagLevel] = useState(2);
  const [showAdd, setShowAdd] = useState(false);
  const [newZoneName, setNewZoneName] = useState('');
  const { theme } = useBudget();

  const toggleZone = (id: number) => {
    setZones(zones.map(z => z.id === id ? { ...z, enabled: !z.enabled } : z));
  };

  const removeZone = (id: number) => {
    setZones(zones.filter(z => z.id !== id));
  };

  const enabledCount = zones.filter(z => z.enabled).length;

  return (
    <div className="pb-6 px-5">
      {/* Header */}
      <div className="flex items-center justify-between mb-4 mt-1">
        <h2 className="text-gray-900" style={{ fontSize: '20px', fontWeight: 800 }}>위험 지역 관리</h2>
        <motion.button
          whileTap={{ scale: 0.94 }}
          onClick={() => setShowAdd(true)}
          className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-white text-sm"
          style={{ background: theme.primary, border: 'none', cursor: 'pointer', fontWeight: 600 }}
        >
          <Plus size={16} /> 추가
        </motion.button>
      </div>

      {/* Status banner */}
      <div
        className="rounded-2xl p-4 mb-5 flex items-center gap-3"
        style={{ background: enabledCount > 0 ? '#F0FDF4' : '#FEF2F2', border: `1.5px solid ${enabledCount > 0 ? '#86EFAC' : '#FCA5A5'}` }}
      >
        <div
          className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
          style={{ background: enabledCount > 0 ? '#DCFCE7' : '#FEE2E2', fontSize: '20px' }}
        >
          {enabledCount > 0 ? '🛡️' : '⚠️'}
        </div>
        <div className="flex-1">
          <p className="text-sm" style={{ fontWeight: 700, color: enabledCount > 0 ? '#15803D' : '#DC2626' }}>
            {enabledCount > 0 ? `${enabledCount}개 지역 감시 중` : '위험 지역 감시 꺼짐'}
          </p>
          <p className="text-xs text-gray-500">GPS 백그라운드 추적이 활성화되어 있어요</p>
        </div>
        <div
          className="w-14 h-7 rounded-full relative cursor-pointer"
          style={{ background: enabledCount > 0 ? '#7C63F5' : '#E5E7EB' }}
          onClick={() => {
            if (enabledCount > 0) setZones(zones.map(z => ({ ...z, enabled: false })));
            else setZones(zones.map(z => ({ ...z, enabled: true })));
          }}
        >
          <div
            className="absolute top-0.5 w-6 h-6 rounded-full bg-white transition-all"
            style={{ left: enabledCount > 0 ? 'calc(100% - 28px)' : '2px', boxShadow: '0 2px 4px rgba(0,0,0,0.2)' }}
          />
        </div>
      </div>

      {/* Mock Map */}
      <div
        className="rounded-3xl mb-5 overflow-hidden relative"
        style={{ height: '160px', background: '#E8F5E9' }}
      >
        {/* Simple map mockup */}
        <div className="w-full h-full relative" style={{
          background: 'linear-gradient(to bottom, #e8f5e9 0%, #c8e6c9 100%)',
        }}>
          {/* Road lines */}
          <div className="absolute inset-0">
            <div className="absolute" style={{ top: '50%', left: 0, right: 0, height: '12px', background: '#B0BEC5', transform: 'translateY(-50%)' }} />
            <div className="absolute" style={{ left: '40%', top: 0, bottom: 0, width: '10px', background: '#B0BEC5', transform: 'translateX(-50%)' }} />
            <div className="absolute" style={{ left: '70%', top: 0, bottom: 0, width: '8px', background: '#CFD8DC', transform: 'translateX(-50%)' }} />
            {/* Road lines */}
            <div className="absolute" style={{ top: '50%', left: 0, right: 0, height: '2px', background: '#FFFFFF50', transform: 'translateY(-50%)' }} />
          </div>
          {/* Danger zone circles */}
          <div className="absolute" style={{ top: '35%', left: '38%', width: '70px', height: '70px', borderRadius: '50%', background: 'rgba(239,68,68,0.15)', border: '2px solid rgba(239,68,68,0.5)', transform: 'translate(-50%,-50%)' }}>
            <div className="absolute inset-0 flex items-center justify-center">
              <span style={{ fontSize: '18px' }}>🏬</span>
            </div>
          </div>
          <div className="absolute" style={{ top: '45%', left: '65%', width: '55px', height: '55px', borderRadius: '50%', background: 'rgba(239,68,68,0.12)', border: '2px solid rgba(239,68,68,0.4)', transform: 'translate(-50%,-50%)' }}>
            <div className="absolute inset-0 flex items-center justify-center">
              <span style={{ fontSize: '16px' }}>👔</span>
            </div>
          </div>
          {/* User location */}
          <div className="absolute" style={{ top: '60%', left: '35%', transform: 'translate(-50%,-50%)' }}>
            <div className="w-4 h-4 rounded-full bg-blue-500 border-2 border-white shadow-lg">
              <div className="absolute inset-0 rounded-full bg-blue-400 animate-ping opacity-75" />
            </div>
          </div>
          {/* Map label */}
          <div className="absolute top-3 right-3 px-2 py-1 rounded-lg text-xs text-gray-600" style={{ background: 'white', fontWeight: 600 }}>
            현재 위치 기반
          </div>
        </div>
      </div>

      {/* Zone list */}
      <div className="mb-5">
        <p className="text-gray-700 text-sm mb-3" style={{ fontWeight: 700 }}>등록된 위험 지역</p>
        <div className="flex flex-col gap-3">
          {zones.map((zone) => (
            <div
              key={zone.id}
              className="rounded-2xl p-4"
              style={{
                background: 'white',
                border: zone.enabled ? '1.5px solid #FCA5A5' : '1.5px solid #F3F4F6',
                boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
              }}
            >
              <div className="flex items-start gap-3">
                <div
                  className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                  style={{ background: zone.enabled ? '#FEF2F2' : '#F9FAFB', fontSize: '20px' }}
                >
                  {zone.emoji}
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-0.5">
                    <p className="text-gray-800 text-sm" style={{ fontWeight: 700 }}>{zone.name}</p>
                    <span
                      className="text-xs px-2 py-0.5 rounded-full"
                      style={{ background: '#F0EEFF', color: '#7C63F5', fontWeight: 600 }}
                    >
                      {zone.category}
                    </span>
                  </div>
                  <p className="text-xs text-gray-400 mb-2">{zone.address}</p>
                  <div className="flex items-center gap-2">
                    <MapPin size={12} color="#9CA3AF" />
                    <span className="text-xs text-gray-400">반경 {zone.radius}m</span>
                  </div>
                </div>
                <div className="flex flex-col items-end gap-2">
                  <div
                    className="w-12 h-6 rounded-full relative cursor-pointer"
                    style={{ background: zone.enabled ? '#7C63F5' : '#E5E7EB' }}
                    onClick={() => toggleZone(zone.id)}
                  >
                    <div
                      className="absolute top-0.5 w-5 h-5 rounded-full bg-white transition-all"
                      style={{ left: zone.enabled ? 'calc(100% - 22px)' : '2px', boxShadow: '0 2px 4px rgba(0,0,0,0.2)' }}
                    />
                  </div>
                  <button
                    onClick={() => removeZone(zone.id)}
                    style={{ background: 'none', border: 'none', cursor: 'pointer' }}
                  >
                    <Trash2 size={14} color="#D1D5DB" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* AI Nag Level */}
      <div
        className="rounded-3xl p-4"
        style={{ background: 'white', boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}
      >
        <div className="flex items-center gap-2 mb-4">
          <Sliders size={18} color="#7C63F5" />
          <p className="text-gray-800 text-sm" style={{ fontWeight: 700 }}>AI 잔소리 강도</p>
        </div>

        <div className="flex gap-3">
          {nagLevels.map((nag) => (
            <button
              key={nag.level}
              onClick={() => setNagLevel(nag.level)}
              className="flex-1 py-3 rounded-2xl flex flex-col items-center gap-1"
              style={{
                background: nagLevel === nag.level ? '#7C63F5' : '#F5F3FF',
                border: nagLevel === nag.level ? 'none' : '1.5px solid #E9E5FF',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
              }}
            >
              <span style={{ fontSize: '20px' }}>{nag.emoji}</span>
              <p className="text-xs" style={{ fontWeight: 700, color: nagLevel === nag.level ? 'white' : '#374151' }}>
                {nag.label}
              </p>
              <p className="text-xs" style={{ color: nagLevel === nag.level ? 'rgba(255,255,255,0.7)' : '#9CA3AF', fontSize: '10px' }}>
                {nag.desc}
              </p>
            </button>
          ))}
        </div>

        {/* Example nag message */}
        <div
          className="mt-4 rounded-2xl p-3"
          style={{ background: '#F5F3FF' }}
        >
          <p className="text-xs text-gray-500 mb-1">미리보기</p>
          <p className="text-sm text-gray-700">
            {nagLevel === 1 && '💜 잠깐! 오늘 예산을 조금 초과할 수 있어요. 확인해보는 건 어떨까요?'}
            {nagLevel === 2 && '⚠️ 스타필드에 입장하셨네요! 현재 예산의 64%를 사용했어요. 오늘 예산 15,300원 남았습니다.'}
            {nagLevel === 3 && '🚨 지금 들어가면 일주일간 삼각김밥만 먹어야 해요!! 이번달 쇼핑 예산 이미 134,000원 썼잖아요!'}
          </p>
        </div>
      </div>

      {/* Add zone modal */}
      {showAdd && (
        <div
          className="fixed inset-0 flex items-end justify-center z-50"
          style={{ background: 'rgba(0,0,0,0.4)' }}
          onClick={() => setShowAdd(false)}
        >
          <div
            className="w-full rounded-t-3xl p-6"
            style={{ background: 'white', maxWidth: '390px' }}
            onClick={e => e.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-gray-900" style={{ fontSize: '17px', fontWeight: 700 }}>위험 지역 추가</h3>
              <button onClick={() => setShowAdd(false)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>
                <X size={22} color="#9CA3AF" />
              </button>
            </div>
            <input
              value={newZoneName}
              onChange={e => setNewZoneName(e.target.value)}
              placeholder="장소명을 입력하세요 (예: 이케아 광명점)"
              className="w-full px-4 py-3.5 rounded-2xl outline-none mb-4"
              style={{ background: '#F9FAFB', border: '1.5px solid #E5E7EB', fontSize: '14px' }}
            />
            <div
              className="rounded-2xl p-3 mb-4 flex gap-2"
              style={{ background: '#FFFBEB', border: '1px solid #FDE68A' }}
            >
              <AlertTriangle size={16} color="#F59E0B" className="shrink-0 mt-0.5" />
              <p className="text-xs text-amber-700">등록된 지역 반경 진입 시 소리가 실시간 알림을 보내드려요</p>
            </div>
            <button
              onClick={() => {
                if (newZoneName) {
                  setZones([...zones, { id: Date.now(), name: newZoneName, address: '위치 검색 중...', enabled: true, radius: 100, emoji: '📍', category: '기타' }]);
                  setNewZoneName('');
                  setShowAdd(false);
                }
              }}
              className="w-full py-4 rounded-2xl text-white"
              style={{ background: 'linear-gradient(135deg, #7C63F5, #A78BFA)', border: 'none', cursor: 'pointer', fontWeight: 600, fontSize: '16px' }}
            >
              추가하기
            </button>
          </div>
        </div>
      )}
    </div>
  );
}