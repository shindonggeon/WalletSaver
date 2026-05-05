import { ReactNode } from 'react';

interface PhoneFrameProps {
  children: ReactNode;
  bgColor?: string;
}

export function PhoneFrame({ children, bgColor = '#F0EEFF' }: PhoneFrameProps) {
  return (
    <div
      className="min-h-screen flex items-center justify-center py-6 px-4"
      style={{
        background: 'linear-gradient(135deg, #4F3CC9 0%, #7C63F5 40%, #A78BFA 80%, #C4B5FD 100%)',
      }}
    >
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-20 -right-20 w-72 h-72 bg-white/10 rounded-full blur-3xl" />
        <div className="absolute -bottom-20 -left-20 w-96 h-96 bg-white/5 rounded-full blur-3xl" />
      </div>

      <div className="flex flex-col items-center gap-4 z-10">
        {/* App branding */}
        <div className="text-center text-white/80 mb-1">
          <p className="text-sm tracking-widest uppercase font-medium opacity-70">지갑비서</p>
          <h1 className="text-3xl tracking-tight text-white">소리 <span className="text-white/60 text-xl font-normal">Sori</span></h1>
          <p className="text-xs text-white/50 mt-1">당신의 지갑을 지키는 가장 똑똑한 잔소리</p>
        </div>

        {/* Phone frame */}
        <div
          className="relative overflow-hidden shadow-2xl"
          style={{
            width: '390px',
            maxWidth: '100vw',
            minHeight: '780px',
            borderRadius: '42px',
            border: '8px solid #1a1a2e',
            background: bgColor,
          }}
        >
          {/* Notch */}
          <div
            className="absolute top-0 left-1/2 -translate-x-1/2 z-50"
            style={{
              width: '120px',
              height: '30px',
              background: '#1a1a2e',
              borderBottomLeftRadius: '18px',
              borderBottomRightRadius: '18px',
            }}
          />
          {/* Status bar */}
          <div
            className="flex items-center justify-between px-8 pt-1"
            style={{ height: '48px', background: 'transparent' }}
          >
            <span className="text-xs font-semibold text-gray-700">9:41</span>
            <div className="flex items-center gap-1">
              <svg width="16" height="12" viewBox="0 0 16 12" fill="none">
                <rect x="0" y="4" width="3" height="8" rx="1" fill="#374151" />
                <rect x="4" y="2.5" width="3" height="9.5" rx="1" fill="#374151" />
                <rect x="8" y="1" width="3" height="11" rx="1" fill="#374151" />
                <rect x="12" y="0" width="3" height="12" rx="1" fill="#374151" />
              </svg>
              <svg width="15" height="12" viewBox="0 0 15 12" fill="none">
                <path d="M7.5 2.5C9.8 2.5 11.8 3.4 13.3 4.9L14.7 3.5C12.8 1.6 10.3 0.5 7.5 0.5C4.7 0.5 2.2 1.6 0.3 3.5L1.7 4.9C3.2 3.4 5.2 2.5 7.5 2.5Z" fill="#374151" />
                <path d="M7.5 5.5C9.0 5.5 10.3 6.1 11.3 7.0L12.7 5.6C11.3 4.3 9.5 3.5 7.5 3.5C5.5 3.5 3.7 4.3 2.3 5.6L3.7 7.0C4.7 6.1 6.0 5.5 7.5 5.5Z" fill="#374151" />
                <circle cx="7.5" cy="10" r="2" fill="#374151" />
              </svg>
              <div className="flex items-center gap-0.5">
                <div className="w-5 h-2.5 rounded-sm border border-gray-600 relative">
                  <div className="absolute inset-0.5 left-0.5 right-1 bg-gray-700 rounded-sm" style={{ width: '70%' }} />
                </div>
              </div>
            </div>
          </div>

          {/* Page content */}
          <div className="overflow-auto" style={{ maxHeight: 'calc(780px - 48px)' }}>
            {children}
          </div>
        </div>
      </div>
    </div>
  );
}
