// GameScreen.jsx — Kinetic Obsidian in-puzzle screen (Pattern Match demo)
const { useState: useStateG, useEffect: useEffectG } = React;

function GameScreen({ track, goBack }) {
  const [time, setTime] = useStateG(22);
  const [selected, setSelected] = useStateG(null);
  useEffectG(() => {
    if (time <= 0) return;
    const t = setTimeout(() => setTime(time - 1), 1000);
    return () => clearTimeout(t);
  }, [time]);

  const shapes = ['triangle', 'square', 'circle', 'hex'];
  const target = 'hex';

  const shapeEl = (kind, size = 44, active = false, correct = false) => {
    const baseFill = active
      ? (correct ? 'var(--primary-container)' : 'var(--error)')
      : 'var(--primary)';
    return (
      <svg width={size} height={size} viewBox="0 0 44 44"
        style={{ filter: active ? `drop-shadow(0 0 10px ${correct ? 'rgba(0,240,255,.8)' : 'rgba(255,180,171,.6)'})` : 'none' }}>
        {kind === 'triangle' && <path d="M22 4l18 34H4z" fill={baseFill}/>}
        {kind === 'square'   && <rect x="6" y="6" width="32" height="32" rx="2" fill={baseFill}/>}
        {kind === 'circle'   && <circle cx="22" cy="22" r="16" fill={baseFill}/>}
        {kind === 'hex'      && <path d="M22 4l16 9v18l-16 9-16-9V13z" fill={baseFill}/>}
      </svg>
    );
  };

  return (
    <div style={{
      minHeight: '100%', padding: '56px 24px 40px',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* Top bar: back / timer / credits */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 24 }}>
        <button onClick={goBack} style={{
          width: 40, height: 40,
          borderRadius: 'var(--radius-lg)',
          background: 'rgba(29,32,38,.5)',
          backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)',
          border: '1px solid var(--outline-variant)',
          color: 'var(--on-surface)', cursor: 'pointer',
          display: 'grid', placeItems: 'center',
        }}><MSym name="arrow_back" size={22}/></button>

        <div style={{
          display: 'inline-flex', alignItems: 'center', gap: 8,
          padding: '6px 14px', borderRadius: 'var(--radius-full)',
          background: 'rgba(29,32,38,.5)',
          backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)',
          border: '1px solid rgba(0,240,255,.25)',
          boxShadow: '0 0 16px rgba(0,240,255,.15)',
        }}>
          <MSym name="timer" size={16} color="var(--primary-container)"/>
          <span style={{
            font: 'var(--t-label-lg)', letterSpacing: 'var(--ls-label-lg)',
            color: 'var(--primary-container)', fontFeatureSettings: '"tnum"',
          }}>0:{String(time).padStart(2,'0')}</span>
        </div>

        <CreditPill value="250"/>
      </div>

      {/* Level segmented progress */}
      <div style={{ display: 'flex', gap: 4, marginBottom: 36 }}>
        {[1,2,3,4,5].map(n => (
          <div key={n} style={{
            flex: 1, height: 3, borderRadius: 'var(--radius-full)',
            background: n <= 2 ? 'var(--grad-kinetic)' : 'var(--surface-container-high)',
            boxShadow: n <= 2 ? '0 0 8px rgba(0,240,255,.5)' : 'none',
          }}/>
        ))}
      </div>

      {/* Prompt */}
      <div style={{
        textAlign: 'center', marginBottom: 10,
        font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
        color: 'var(--primary-container)', textTransform: 'uppercase',
      }}>{track?.name || 'Pattern Match'} · Level 03</div>
      <h2 style={{
        margin: '0 0 32px 0',
        font: 'var(--t-h2)', letterSpacing: 'var(--ls-h2)',
        color: 'var(--on-surface)', textAlign: 'center',
      }}>Identify the matching shape</h2>

      {/* Target */}
      <Glass padding={28} radius={12} style={{
        aspectRatio: '1/1', maxWidth: 220, margin: '0 auto 24px',
        display: 'grid', placeItems: 'center',
        border: '1px solid rgba(0,240,255,.2)',
      }}>
        <div style={{ transform: 'scale(1.8)' }}>{shapeEl(target, 60)}</div>
      </Glass>

      {/* Answer grid */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 20 }}>
        {shapes.map(s => {
          const isActive = selected === s;
          const correct = s === target;
          return (
            <div key={s} onClick={() => setSelected(s)}
              className="glass-panel"
              style={{
                borderRadius: 'var(--radius-lg)', padding: 20,
                display: 'grid', placeItems: 'center',
                cursor: 'pointer',
                background: isActive
                  ? (correct ? 'rgba(0,240,255,.14)' : 'rgba(255,180,171,.14)')
                  : 'var(--glass-fill)',
                border: `1px solid ${
                  isActive
                    ? (correct ? 'rgba(0,240,255,.6)' : 'rgba(255,180,171,.55)')
                    : 'var(--outline-variant)'
                }`,
                transform: isActive ? 'scale(0.97)' : 'scale(1)',
                transition: 'all 160ms var(--ease-snappy)',
              }}>
              {shapeEl(s, 44, isActive, correct)}
            </div>
          );
        })}
      </div>

      {/* Actions */}
      <div style={{ marginTop: 'auto', display: 'flex', gap: 10 }}>
        <GhostButton style={{ flex: 1 }}>
          <MSym name="help_outline" size={18} style={{ marginRight: 6, verticalAlign: '-4px' }}/>
          Hint
        </GhostButton>
        <PrimaryButton style={{ flex: 1 }}>Submit</PrimaryButton>
      </div>
    </div>
  );
}

Object.assign(window, { GameScreen });
