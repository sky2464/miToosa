// Shared components for miToosa redesign

const ICONS = {
  pattern_match:   'assets/icons/track_pattern_match.png',
  shape_counter:   'assets/icons/track_shape_counter.png',
  logic_gates:     'assets/icons/track_logic_gates.png',
  memory:          'assets/icons/track_memory.png',
  number_crunch:   'assets/icons/track_number_crunch.png',
  sequence:        'assets/icons/track_sequence.png',
  color_code:      'assets/icons/track_color_code.png',
  spatial:         'assets/icons/track_spatial.png',
};

// ── Atmosphere: hero glow blobs that read through glass ──────────────────────
function Atmosphere({ accent }) {
  const a = accent || 'blue';
  const top   = a === 'cyan' ? 'rgba(34,211,238,0.42)'
              : a === 'pink' ? 'rgba(236,72,153,0.42)'
              : 'rgba(59,130,246,0.42)';
  const bot   = a === 'cyan' ? 'rgba(59,130,246,0.32)'
              : a === 'pink' ? 'rgba(168,85,247,0.32)'
              : 'rgba(168,85,247,0.32)';
  return (
    <div aria-hidden style={{ position:'absolute', inset:0, overflow:'hidden', pointerEvents:'none' }}>
      <div style={{ position:'absolute', top:-120, left:'50%', width:520, height:520,
        transform:'translateX(-50%)', borderRadius:'50%',
        background:`radial-gradient(circle, ${top} 0%, transparent 60%)`,
        filter:'blur(8px)', animation:'drift 16s var(--e-smooth) infinite' }} />
      <div style={{ position:'absolute', bottom:-100, right:-80, width:360, height:360, borderRadius:'50%',
        background:`radial-gradient(circle, ${bot} 0%, transparent 65%)`,
        filter:'blur(8px)', animation:'drift 22s var(--e-smooth) infinite reverse' }} />
      <div style={{ position:'absolute', top:'40%', left:-120, width:280, height:280, borderRadius:'50%',
        background:'radial-gradient(circle, rgba(96,165,250,0.18) 0%, transparent 60%)',
        filter:'blur(12px)', animation:'drift 28s var(--e-smooth) infinite' }} />
      {/* faint star field */}
      <svg width="100%" height="100%" style={{ position:'absolute', inset:0, opacity:.5, mixBlendMode:'screen' }}>
        <defs>
          <radialGradient id="star"><stop offset="0%" stopColor="#fff"/><stop offset="100%" stopColor="#fff" stopOpacity="0"/></radialGradient>
        </defs>
        {Array.from({length: 28}).map((_,i) => {
          const seed = i*37 % 100;
          return <circle key={i} cx={`${(seed*7)%100}%`} cy={`${(seed*13)%100}%`} r={(seed%3)*0.4+0.4} fill="url(#star)" opacity={0.3 + (seed%5)*0.1}/>;
        })}
      </svg>
    </div>
  );
}

// ── App header (avatar + logo + credits) ─────────────────────────────────────
function AppHeader({ credits, onAvatar }) {
  return (
    <div style={{ position:'sticky', top:0, zIndex:5, padding:'14px 18px 10px',
      display:'flex', alignItems:'center', justifyContent:'space-between',
      background:'linear-gradient(180deg, rgba(10,13,23,.85) 0%, rgba(10,13,23,.55) 70%, transparent 100%)',
      backdropFilter:'blur(8px)' }}>
      <div style={{ display:'flex', alignItems:'center', gap:10 }}>
        <button onClick={onAvatar} style={{ width:36, height:36, padding:0, borderRadius:'50%', border:'1.5px solid transparent',
          background:'linear-gradient(var(--bg-1),var(--bg-1)) padding-box, var(--grad-primary) border-box',
          cursor:'pointer', overflow:'hidden', boxShadow:'0 0 12px rgba(96,165,250,.4)' }}>
          <img src="assets/avatars/avatar_4.png" alt="" style={{ width:'100%', height:'100%', objectFit:'cover' }} />
        </button>
        <div style={{ display:'flex', flexDirection:'column', lineHeight:1 }}>
          <span style={{ fontSize:15, fontWeight:800, letterSpacing:'-0.02em',
            background:'var(--grad-primary)', WebkitBackgroundClip:'text', backgroundClip:'text', color:'transparent' }}>
            miToosa
          </span>
          <span style={{ fontSize:9, letterSpacing:'0.18em', color:'var(--fg-muted)', textTransform:'uppercase', marginTop:3 }}>
            Pilot · Lv 1
          </span>
        </div>
      </div>
      <div style={{ display:'flex', alignItems:'center', gap:6, padding:'6px 12px 6px 8px',
        borderRadius:'var(--r-pill)', background:'rgba(255,255,255,.05)',
        border:'1px solid rgba(96,165,250,.25)', boxShadow:'inset 0 0 12px rgba(59,130,246,.15)' }}>
        <Diamond size={14} />
        <span className="tabular" style={{ fontSize:13, fontWeight:700, letterSpacing:'-0.01em' }}>{credits.toLocaleString()}</span>
        <span style={{ fontSize:9, color:'var(--fg-tertiary)', letterSpacing:'0.12em', fontWeight:600 }}>CR</span>
      </div>
    </div>
  );
}

// ── Bottom nav ───────────────────────────────────────────────────────────────
function BottomNav({ value, onChange }) {
  const tabs = [
    { id:'tracks',   label:'Tracks',   icon: <GridIcon /> },
    { id:'path',     label:'Path',     icon: <PathIcon /> },
    { id:'progress', label:'Progress', icon: <PulseIcon /> },
    { id:'leaders',  label:'Leaders',  icon: <TrophyIcon /> },
    { id:'settings', label:'Settings', icon: <GearIcon /> },
  ];
  return (
    <div style={{ position:'absolute', left:12, right:12, bottom:14, zIndex:10,
      padding:'8px', borderRadius:24,
      background:'rgba(8,11,20,.78)', backdropFilter:'blur(24px) saturate(140%)',
      WebkitBackdropFilter:'blur(24px) saturate(140%)',
      border:'1px solid rgba(255,255,255,.10)',
      boxShadow:'0 14px 40px rgba(0,0,0,.55), inset 0 1px 0 rgba(255,255,255,.06)' }}>
      <div style={{ display:'grid', gridTemplateColumns:'repeat(5,1fr)', gap:4 }}>
        {tabs.map(t => {
          const active = value === t.id;
          return (
            <button key={t.id} onClick={() => onChange(t.id)}
              style={{ position:'relative', padding:'8px 4px 7px', border:0, cursor:'pointer',
                borderRadius:18, background: active ? 'rgba(59,130,246,.14)' : 'transparent',
                color: active ? '#bfdbfe' : 'var(--fg-tertiary)',
                display:'flex', flexDirection:'column', alignItems:'center', gap:4,
                transition:'background .18s, color .18s' }}>
              {active && (
                <span aria-hidden style={{ position:'absolute', top:-9, left:'50%', transform:'translateX(-50%)',
                  width:24, height:2.5, borderRadius:3, background:'var(--blue-400)',
                  boxShadow:'0 0 10px var(--blue-400)' }} />
              )}
              <span style={{ display:'flex', filter: active ? 'drop-shadow(0 0 6px rgba(96,165,250,.6))' : 'none' }}>
                {t.icon}
              </span>
              <span style={{ fontSize:9.5, fontWeight: active ? 700 : 600, letterSpacing:'0.04em' }}>
                {t.label}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ── Glass card ───────────────────────────────────────────────────────────────
function GlassCard({ children, style, padding=20, radius=24, accent, onClick }) {
  return (
    <div onClick={onClick} style={{ position:'relative', padding, borderRadius: radius,
      background:'var(--glass-fill)',
      backdropFilter:'var(--glass-blur)', WebkitBackdropFilter:'var(--glass-blur)',
      border:'1px solid var(--glass-border)',
      boxShadow: accent
        ? `var(--sh-card), 0 0 22px ${accent}`
        : 'var(--sh-card)',
      overflow:'hidden',
      ...style }}>
      <span aria-hidden style={{ position:'absolute', top:0, left:0, right:0, height:1,
        background:'linear-gradient(90deg, transparent, rgba(255,255,255,.18), transparent)' }} />
      {children}
    </div>
  );
}

// ── Stat pill ────────────────────────────────────────────────────────────────
function StatPill({ icon, label, tint='blue', glow=false }) {
  const tintMap = {
    orange: { c:'#fb923c', bg:'rgba(251,146,60,.10)', bd:'rgba(251,146,60,.30)' },
    blue:   { c:'#60a5fa', bg:'rgba(96,165,250,.10)', bd:'rgba(96,165,250,.30)' },
    purple: { c:'#c084fc', bg:'rgba(192,132,252,.10)', bd:'rgba(192,132,252,.30)' },
    amber:  { c:'#facc15', bg:'rgba(250,204,21,.10)', bd:'rgba(250,204,21,.30)' },
    cyan:   { c:'#22d3ee', bg:'rgba(34,211,238,.10)', bd:'rgba(34,211,238,.30)' },
    pink:   { c:'#ec4899', bg:'rgba(236,72,153,.10)', bd:'rgba(236,72,153,.30)' },
  };
  const t = tintMap[tint] || tintMap.blue;
  return (
    <div style={{ display:'inline-flex', alignItems:'center', gap:6, padding:'6px 12px 6px 8px',
      borderRadius:'var(--r-pill)', background: t.bg,
      border:`1px solid ${t.bd}`, color: t.c, fontSize:12, fontWeight:600,
      boxShadow: glow ? `0 0 14px ${t.bd}` : 'none', whiteSpace:'nowrap' }}>
      {icon && <span style={{ display:'flex', filter:`drop-shadow(0 0 4px ${t.c})` }}>{icon}</span>}
      <span className="tabular">{label}</span>
    </div>
  );
}

// ── Progress ring ────────────────────────────────────────────────────────────
function ProgressRing({ value=0, size=180, stroke=12, label, sublabel, color='url(#grad-blue-purple)', track='rgba(255,255,255,.08)' }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const off = c * (1 - value / 100);
  return (
    <div style={{ position:'relative', width:size, height:size }}>
      <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ transform:'rotate(-90deg)' }}>
        <defs>
          <linearGradient id="grad-blue-purple" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#3b82f6" />
            <stop offset="100%" stopColor="#a855f7" />
          </linearGradient>
          <linearGradient id="grad-energy" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#fb923c" />
            <stop offset="100%" stopColor="#facc15" />
          </linearGradient>
        </defs>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={track} strokeWidth={stroke} />
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={color} strokeWidth={stroke}
          strokeLinecap="round" strokeDasharray={c} strokeDashoffset={off}
          style={{ transition:'stroke-dashoffset 1.2s var(--e-out)',
            filter:'drop-shadow(0 0 10px rgba(96,165,250,.6))' }} />
      </svg>
      <div style={{ position:'absolute', inset:0, display:'flex', flexDirection:'column',
        alignItems:'center', justifyContent:'center', gap:2 }}>
        <span className="tabular" style={{ fontSize: size>140 ? 44 : 28, fontWeight:800,
          background:'var(--grad-primary)', WebkitBackgroundClip:'text', color:'transparent',
          letterSpacing:'-0.03em', lineHeight:1 }}>{label}</span>
        {sublabel && <span style={{ fontSize:10, letterSpacing:'0.16em', color:'var(--fg-tertiary)',
          textTransform:'uppercase', fontWeight:600 }}>{sublabel}</span>}
      </div>
    </div>
  );
}

// ── Primary CTA ──────────────────────────────────────────────────────────────
function PrimaryButton({ children, onClick, full, glow=true, style }) {
  return (
    <button onClick={onClick} style={{ position:'relative', display:'inline-flex',
      alignItems:'center', justifyContent:'center', gap:8,
      padding: '14px 22px', border:0, cursor:'pointer',
      borderRadius:'var(--r-pill)', color:'#fff', fontWeight:700, fontSize:14, letterSpacing:'0.02em',
      width: full ? '100%' : 'auto',
      background:'var(--grad-primary)',
      boxShadow: glow ? '0 8px 22px rgba(59,130,246,.45), inset 0 1px 0 rgba(255,255,255,.25)' : 'inset 0 1px 0 rgba(255,255,255,.25)',
      transition:'transform .15s var(--e-out)',
      ...style }}
      onPointerDown={e => e.currentTarget.style.transform='scale(.97)'}
      onPointerUp={e => e.currentTarget.style.transform='scale(1)'}
      onPointerLeave={e => e.currentTarget.style.transform='scale(1)'}>
      <span aria-hidden style={{ position:'absolute', inset:0, borderRadius:'var(--r-pill)',
        background:'linear-gradient(180deg, rgba(255,255,255,.18), transparent 50%)', pointerEvents:'none' }} />
      {children}
    </button>
  );
}
function GhostButton({ children, onClick, full, style }) {
  return (
    <button onClick={onClick} style={{ display:'inline-flex', alignItems:'center', justifyContent:'center',
      gap:8, padding:'12px 18px', border:'1px solid var(--glass-border-strong)', cursor:'pointer',
      borderRadius:'var(--r-pill)', color:'var(--fg-secondary)', fontWeight:600, fontSize:13,
      background:'rgba(255,255,255,.04)', width: full ? '100%' : 'auto', ...style }}>
      {children}
    </button>
  );
}

// ── Icons (Lucide-style, stroke 1.75) ────────────────────────────────────────
const SI = (props) => ({ width:18, height:18, fill:'none', stroke:'currentColor', strokeWidth:1.75, strokeLinecap:'round', strokeLinejoin:'round', ...props });
function GridIcon(p)   { return <svg {...SI(p)}><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></svg>; }
function PathIcon(p)   { return <svg {...SI(p)}><path d="M5 5c4 0 4 6 0 6s-4 8 0 8h14"/><circle cx="5" cy="5" r="1.5"/><circle cx="19" cy="19" r="1.5"/></svg>; }
function PulseIcon(p)  { return <svg {...SI(p)}><path d="M3 12h4l3-8 4 16 3-8h4"/></svg>; }
function TrophyIcon(p) { return <svg {...SI(p)}><path d="M8 21h8M12 17v4M7 4h10v4a5 5 0 0 1-10 0V4z"/><path d="M17 6h3v2a3 3 0 0 1-3 3M7 6H4v2a3 3 0 0 0 3 3"/></svg>; }
function GearIcon(p)   { return <svg {...SI(p)}><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1A1.7 1.7 0 0 0 9 19.4a1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1A1.7 1.7 0 0 0 4.6 9a1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1A1.7 1.7 0 0 0 15 4.6a1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/></svg>; }
function PlayIcon(p)   { return <svg {...SI(p)}><polygon points="6,4 20,12 6,20" fill="currentColor" stroke="none"/></svg>; }
function ChevronR(p)   { return <svg {...SI(p)}><polyline points="9,6 15,12 9,18"/></svg>; }
function Diamond(p)    { return <svg viewBox="0 0 24 24" width={p.size||16} height={p.size||16}><defs><linearGradient id="d-grad"><stop offset="0%" stopColor="#60a5fa"/><stop offset="100%" stopColor="#a855f7"/></linearGradient></defs><path d="M12 3 L20 10 L12 21 L4 10 Z" fill="url(#d-grad)" stroke="#fff" strokeWidth=".5" opacity=".95"/></svg>; }
function Flame(p)      { return <svg viewBox="0 0 24 24" width={p.size||16} height={p.size||16}><defs><linearGradient id="f-grad" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="#facc15"/><stop offset="100%" stopColor="#fb923c"/></linearGradient></defs><path fill="url(#f-grad)" d="M12 2c1 3 4 5 4 9a4 4 0 0 1-8 0c0-2 1-3 2-4-1 4 2 4 2 2 0-3-2-4 0-7z"/></svg>; }
function Star(p)       { return <svg viewBox="0 0 24 24" width={p.size||16} height={p.size||16}><defs><linearGradient id="s-grad"><stop offset="0%" stopColor="#c084fc"/><stop offset="100%" stopColor="#ec4899"/></linearGradient></defs><path fill="url(#s-grad)" d="M12 2l2.9 6.5L22 9.4l-5.2 5 1.3 7.1L12 17.9 5.9 21.5l1.3-7.1L2 9.4l7.1-.9z"/></svg>; }
function Bolt(p)       { return <svg viewBox="0 0 24 24" width={p.size||16} height={p.size||16}><defs><linearGradient id="b-grad"><stop offset="0%" stopColor="#facc15"/><stop offset="100%" stopColor="#fb923c"/></linearGradient></defs><path fill="url(#b-grad)" d="M13 2 4 14h6l-1 8 9-12h-6z"/></svg>; }
function ShareIcon(p)  { return <svg {...SI(p)}><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="m8.6 13.5 6.8 4M15.4 6.5l-6.8 4"/></svg>; }
function CrownIcon(p)  { return <svg {...SI(p)}><path d="M3 8l4 6 5-8 5 8 4-6-2 11H5z" fill="#facc15" stroke="#92400e" strokeWidth="1"/></svg>; }
function LockIcon(p)   { return <svg {...SI(p)}><rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/></svg>; }
function VipIcon(p)    { return <svg {...SI(p)}><path d="M4 8l4 8 4-12 4 12 4-8" /></svg>; }
function SpeakerIcon(p){ return <svg {...SI(p)}><path d="M11 5 6 9H3v6h3l5 4z"/><path d="M16 9a4 4 0 0 1 0 6"/></svg>; }
function NoteIcon(p)   { return <svg {...SI(p)}><path d="M9 18V6l10-2v12"/><circle cx="6" cy="18" r="3"/><circle cx="16" cy="16" r="3"/></svg>; }
function BellIcon(p)   { return <svg {...SI(p)}><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10 21a2 2 0 0 0 4 0"/></svg>; }
function HelpIcon(p)   { return <svg {...SI(p)}><circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.5 2.5 0 1 1 4.5 1.5c-1 .8-2 1.2-2 2.5M12 17h.01"/></svg>; }
function CheckIcon(p)  { return <svg {...SI(p)}><polyline points="4,12 10,18 20,6"/></svg>; }
function FireIcon(p)   { return <svg {...SI(p)}><path d="M12 2c0 4 5 5 5 11a5 5 0 0 1-10 0c0-2 1-4 3-5-1 3 2 4 2 1 0-2-1-3 0-7z"/></svg>; }
function LightIcon(p)  { return <svg {...SI(p)}><path d="m13 2-9 12h6l-1 8 9-12h-6z"/></svg>; }
function CompassIcon(p){ return <svg {...SI(p)}><circle cx="12" cy="12" r="9"/><polygon points="10,8 16,10 14,16 8,14" fill="currentColor" stroke="none"/></svg>; }

// expose
Object.assign(window, {
  ICONS, Atmosphere, AppHeader, BottomNav, GlassCard, StatPill, ProgressRing,
  PrimaryButton, GhostButton,
  GridIcon, PathIcon, PulseIcon, TrophyIcon, GearIcon, PlayIcon, ChevronR,
  Diamond, Flame, Star, Bolt, ShareIcon, CrownIcon, LockIcon, VipIcon,
  SpeakerIcon, NoteIcon, BellIcon, HelpIcon, CheckIcon, FireIcon, LightIcon, CompassIcon
});
