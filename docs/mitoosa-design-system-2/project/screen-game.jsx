// Game screen — Pattern Match in-session (sample interactive)

function GameScreen({ onExit }) {
  const [selected, setSelected] = React.useState(null);
  const [timeLeft, setTimeLeft] = React.useState(12);
  React.useEffect(() => {
    const t = setInterval(() => setTimeLeft(s => s > 0 ? s - 1 : 12), 1000);
    return () => clearInterval(t);
  }, []);

  const target = { shapes: ['T','C','S','T'] };
  const opts = [
    { shapes: ['T','S','C','T'] },
    { shapes: ['T','C','S','T'] }, // correct
    { shapes: ['T','C','C','S'] },
    { shapes: ['S','C','S','T'] },
  ];

  return (
    <div style={{ position:'relative', minHeight:'100%', display:'flex', flexDirection:'column' }}>
      <Atmosphere accent="cyan" />
      {/* top chrome */}
      <div style={{ position:'sticky', top:0, zIndex:5, padding:'14px 18px 10px',
        display:'flex', alignItems:'center', justifyContent:'space-between',
        background:'linear-gradient(180deg, rgba(10,13,23,.9) 0%, transparent 100%)',
        backdropFilter:'blur(8px)' }}>
        <button onClick={onExit} style={{ width:36, height:36, borderRadius:'50%',
          background:'rgba(255,255,255,.06)', border:'1px solid rgba(255,255,255,.1)',
          color:'#fff', cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M15 6l-6 6 6 6"/></svg>
        </button>
        <div style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:2 }}>
          <span className="eyebrow" style={{ color:'#93c5fd' }}>Pattern Match · Lv 7</span>
          <div style={{ display:'flex', gap:3 }}>
            {[1,2,3,4,5].map(i => (
              <div key={i} style={{ width:18, height:3, borderRadius:2,
                background: i <= 3 ? 'var(--grad-primary)' : 'rgba(255,255,255,.1)' }} />
            ))}
          </div>
        </div>
        <div style={{ width:36, height:36, borderRadius:'50%',
          background: timeLeft <= 4 ? 'rgba(236,72,153,.18)' : 'rgba(96,165,250,.12)',
          border: `1px solid ${timeLeft <= 4 ? 'rgba(236,72,153,.5)' : 'rgba(96,165,250,.4)'}`,
          color:'#fff', display:'flex', alignItems:'center', justifyContent:'center',
          fontSize:13, fontWeight:800, fontVariantNumeric:'tabular-nums',
          boxShadow: timeLeft <= 4 ? '0 0 14px rgba(236,72,153,.4)' : 'none',
          animation: timeLeft <= 4 ? 'pulse-glow 1s ease infinite' : 'none' }}>
          {timeLeft}
        </div>
      </div>

      <div style={{ flex:1, padding:'8px 18px 130px', display:'flex', flexDirection:'column', gap:18, position:'relative', zIndex:1 }}>
        <div style={{ textAlign:'center' }}>
          <div className="eyebrow" style={{ color:'#93c5fd' }}>Find the match</div>
          <h2 style={{ margin:'6px 0 0', fontSize:18, fontWeight:700, letterSpacing:'-0.02em', color:'#fff' }}>
            Which pattern matches the target?
          </h2>
        </div>

        {/* target */}
        <GlassCard radius={20} padding={16} style={{ alignSelf:'center', width:'100%' }}>
          <div className="eyebrow" style={{ marginBottom:8, textAlign:'center' }}>Target</div>
          <ShapeRow shapes={target.shapes} large />
        </GlassCard>

        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:10 }}>
          {opts.map((o, i) => {
            const sel = selected === i;
            return (
              <button key={i} onClick={() => setSelected(i)}
                style={{ padding:'18px 14px', borderRadius:18,
                  background: sel ? 'rgba(34,211,238,.12)' : 'rgba(255,255,255,.04)',
                  border:`1px solid ${sel ? 'rgba(34,211,238,.55)' : 'rgba(255,255,255,.08)'}`,
                  boxShadow: sel ? '0 0 18px rgba(34,211,238,.35)' : 'var(--sh-card)',
                  cursor:'pointer', transition:'all .18s' }}>
                <ShapeRow shapes={o.shapes} />
              </button>
            );
          })}
        </div>

        <div style={{ marginTop:'auto', display:'flex', gap:10 }}>
          <GhostButton style={{ flex:'0 0 auto', padding:'14px 18px' }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.5 2.5 0 1 1 4.5 1.5c-1 .8-2 1.2-2 2.5M12 17h.01"/></svg>
            <span style={{ marginLeft:6 }}>Hint</span>
          </GhostButton>
          <PrimaryButton full glow={selected!==null} style={{ opacity: selected===null ? .55 : 1 }}>
            Submit
          </PrimaryButton>
        </div>
      </div>
    </div>
  );
}

function ShapeRow({ shapes, large }) {
  const size = large ? 40 : 32;
  return (
    <div style={{ display:'flex', justifyContent:'center', gap:large ? 12 : 8 }}>
      {shapes.map((s, i) => <Shape key={i} kind={s} size={size} />)}
    </div>
  );
}
function Shape({ kind, size=32 }) {
  const colors = { T:'#60a5fa', C:'#c084fc', S:'#22d3ee' };
  const color = colors[kind];
  return (
    <div style={{ width:size, height:size, display:'flex', alignItems:'center', justifyContent:'center',
      filter: `drop-shadow(0 0 8px ${color}80)` }}>
      <svg width={size} height={size} viewBox="0 0 32 32">
        <defs>
          <linearGradient id={`sh-${kind}`} x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor={color}/>
            <stop offset="100%" stopColor={color} stopOpacity=".5"/>
          </linearGradient>
        </defs>
        {kind === 'T' && <polygon points="16,4 28,28 4,28" fill={`url(#sh-${kind})`} stroke={color} strokeWidth="1"/>}
        {kind === 'C' && <circle cx="16" cy="16" r="12" fill={`url(#sh-${kind})`} stroke={color} strokeWidth="1"/>}
        {kind === 'S' && <rect x="5" y="5" width="22" height="22" rx="3" fill={`url(#sh-${kind})`} stroke={color} strokeWidth="1"/>}
      </svg>
    </div>
  );
}

window.GameScreen = GameScreen;
