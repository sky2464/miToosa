// Primitives.jsx — Kinetic Obsidian UI kit primitives
const { useState } = React;

// ─── Material Symbols icon — thin wrapper for the icon font ──────────
function MSym({ name, size = 24, fill = 0, color = 'currentColor', style = {} }) {
  return (
    <span className="material-symbols-outlined" style={{
      fontSize: size, color, fontVariationSettings: `'FILL' ${fill}`, ...style,
    }}>{name}</span>
  );
}

// ─── Glass panel — 50% neutral fill, 16px blur, top/left white edge ──
function Glass({ children, style = {}, padding = 24, radius = 12, glow = false, onClick, hover = false }) {
  const [h, setH] = useState(false);
  return (
    <div onClick={onClick}
      onMouseEnter={() => setH(true)} onMouseLeave={() => setH(false)}
      className="glass-panel"
      style={{
        borderRadius: radius,
        padding,
        boxShadow: glow ? 'var(--shadow-neon-soft)' : 'none',
        cursor: onClick ? 'pointer' : 'default',
        position: 'relative',
        transition: `border-color var(--dur-med) var(--ease-out), box-shadow var(--dur-med) var(--ease-out)`,
        ...(hover && h ? { boxShadow: 'var(--shadow-neon-med)' } : {}),
        ...style,
      }}>
      {children}
    </div>
  );
}

// ─── Primary button — kinetic gradient fill, pill ─────────────────────
function PrimaryButton({ children, onClick, style = {}, full = false }) {
  const [p, setP] = useState(false);
  return (
    <button onClick={onClick}
      onMouseDown={() => setP(true)} onMouseUp={() => setP(false)} onMouseLeave={() => setP(false)}
      style={{
        font: 'var(--t-label-lg)', letterSpacing: 'var(--ls-label-lg)',
        textTransform: 'uppercase',
        color: 'var(--on-primary, #00363a)',
        border: 'none', cursor: 'pointer',
        padding: '12px 24px',
        borderRadius: 'var(--radius-full)',
        background: 'var(--grad-kinetic)',
        boxShadow: 'var(--shadow-neon-soft)',
        transform: p ? 'scale(0.97)' : 'scale(1)',
        transition: 'transform 120ms var(--ease-snappy), box-shadow var(--dur-med)',
        width: full ? '100%' : 'auto',
        fontFamily: 'var(--font-body)', fontWeight: 700,
        ...style,
      }}>{children}</button>
  );
}

// ─── Ghost button — 1px primary stroke, glass fill ────────────────────
function GhostButton({ children, onClick, style = {} }) {
  return (
    <button onClick={onClick} style={{
      font: 'var(--t-label-lg)', letterSpacing: 'var(--ls-label-lg)',
      textTransform: 'uppercase',
      color: 'var(--primary-container)',
      padding: '10px 20px',
      borderRadius: 'var(--radius-full)',
      background: 'rgba(29,32,38,.4)',
      backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)',
      border: '1px solid rgba(0, 240, 255, 0.35)',
      cursor: 'pointer',
      fontFamily: 'var(--font-body)', fontWeight: 500,
      ...style,
    }}>{children}</button>
  );
}

// ─── Chip — secondary-purple fill @ 20%, high-tracking Exo 2 ──────────
function Chip({ children, tone = 'primary', style = {} }) {
  const t = tone === 'primary'
    ? { bg: 'rgba(0,240,255,.12)',   fg: 'var(--primary-container)',   bd: 'rgba(0,240,255,.30)' }
    : tone === 'purple'
    ? { bg: 'rgba(112,0,255,.18)',   fg: 'var(--secondary-fixed-dim)', bd: 'rgba(112,0,255,.40)' }
    : { bg: 'rgba(255,255,255,.05)', fg: 'var(--on-surface-variant)',  bd: 'var(--outline-variant)' };
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '4px 10px',
      background: t.bg, color: t.fg,
      border: `1px solid ${t.bd}`,
      borderRadius: 'var(--radius-full)',
      font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
      textTransform: 'uppercase', fontWeight: 500,
      ...style,
    }}>{children}</span>
  );
}

// ─── Progress bar — thin, kinetic gradient fill + underglow ───────────
function ProgressBar({ pct = 50, label, value, height = 4, glow = true }) {
  return (
    <div style={{ width: '100%' }}>
      {(label || value) && (
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
          <span style={{
            font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
            color: 'var(--on-surface-variant)',
          }}>{label}</span>
          {value && <span style={{
            font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
            color: 'var(--primary-container)',
          }}>{value}</span>}
        </div>
      )}
      <div style={{
        width: '100%', height,
        background: 'var(--surface-container-high)',
        borderRadius: 'var(--radius-full)', overflow: 'hidden',
      }}>
        <div style={{
          height: '100%', width: `${pct}%`,
          background: 'var(--grad-kinetic)',
          borderRadius: 'var(--radius-full)',
          boxShadow: glow ? '0 0 10px rgba(0,240,255,.5)' : 'none',
          transition: 'width 600ms var(--ease-out)',
        }}/>
      </div>
    </div>
  );
}

// ─── Progress ring — hero daily goal widget ───────────────────────────
function ProgressRing({ pct = 75, size = 160, stroke = 8, children }) {
  const r = (size - stroke) / 2 - 2;
  const c = 2 * Math.PI * r;
  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <defs>
          <linearGradient id={`ring-${size}`} x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#7000ff"/>
            <stop offset="100%" stopColor="#00f0ff"/>
          </linearGradient>
        </defs>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="var(--surface-container-high)" strokeWidth={stroke}/>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={`url(#ring-${size})`}
          strokeWidth={stroke} strokeLinecap="round"
          strokeDasharray={c} strokeDashoffset={c * (1 - pct / 100)}
          style={{ filter: 'drop-shadow(0 0 8px rgba(0,240,255,.8))' }}/>
      </svg>
      <div style={{
        position: 'absolute', inset: 0,
        display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
      }}>{children}</div>
    </div>
  );
}

// ─── Credit pill — top-bar status pill (1,250 CR) ─────────────────────
function CreditPill({ value }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '4px 12px',
      background: 'var(--surface-container)',
      border: '1px solid var(--outline-variant)',
      borderRadius: 'var(--radius-full)',
    }}>
      <MSym name="stars" size={16} fill={1} color="var(--primary-container)"/>
      <span style={{
        font: 'var(--t-label-lg)', letterSpacing: 'var(--ls-label-lg)',
        color: 'var(--primary-container)', fontWeight: 500,
      }}>{value} CR</span>
    </div>
  );
}

// ─── Input — dark recessed, primary underline on focus ────────────────
function Input({ placeholder, icon }) {
  const [f, setF] = useState(false);
  return (
    <label style={{
      display: 'flex', alignItems: 'center', gap: 10,
      padding: '10px 14px',
      background: 'var(--surface-container-lowest)',
      borderRadius: 'var(--radius-lg)',
      borderBottom: `1px solid ${f ? 'var(--primary-container)' : 'var(--outline-variant)'}`,
      boxShadow: f ? '0 2px 12px -4px rgba(0,240,255,.5)' : 'none',
      transition: 'all var(--dur-med)',
    }}>
      {icon && <MSym name={icon} size={18} color="var(--on-surface-variant)"/>}
      <input type="text" placeholder={placeholder}
        onFocus={() => setF(true)} onBlur={() => setF(false)}
        style={{
          flex: 1, background: 'transparent', border: 'none', outline: 'none',
          color: 'var(--on-surface)',
          font: 'var(--t-body-md)', letterSpacing: 'var(--ls-body)',
        }}/>
    </label>
  );
}

Object.assign(window, { Glass, PrimaryButton, GhostButton, Chip, ProgressBar, ProgressRing, CreditPill, MSym, Input });
