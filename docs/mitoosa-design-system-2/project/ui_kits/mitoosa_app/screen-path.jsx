// Path screen — vertical orbital constellation of levels (replaces the sad zigzag)

function PathScreen() {
  const currentLevel = 7;
  const totalLevels = 30;
  const levels = Array.from({ length: totalLevels }, (_, i) => ({
    n: i + 1,
    state: i < currentLevel - 1 ? 'done' : i === currentLevel - 1 ? 'current' : 'locked',
    type: i % 5 === 4 ? 'boss' : i % 3 === 2 ? 'bonus' : 'regular',
  }));

  return (
    <div style={{ position:'relative', minHeight:'100%' }}>
      <Atmosphere accent="blue" />
      <AppHeader credits={1250} />

      <div style={{ padding:'4px 16px 0', position:'relative', zIndex:1 }}>
        {/* hero band */}
        <GlassCard radius={24} padding={18}>
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', gap:12 }}>
            <div>
              <div className="eyebrow" style={{ color:'#93c5fd' }}>Pattern Match · path</div>
              <div style={{ fontSize:24, fontWeight:800, letterSpacing:'-0.03em', marginTop:4 }}>
                Level <span className="kinetic">{currentLevel}</span> <span style={{ color:'var(--fg-muted)' }}>of {totalLevels}</span>
              </div>
              <div style={{ fontSize:12, color:'var(--fg-tertiary)', marginTop:4 }}>
                3 more to unlock <span style={{ color:'#facc15' }}>Bronze tier</span>
              </div>
            </div>
            <div style={{ position:'relative', width:64, height:64, borderRadius:14,
              background:'rgba(255,255,255,.04)', border:'1px solid rgba(255,255,255,.08)',
              display:'flex', alignItems:'center', justifyContent:'center', overflow:'hidden' }}>
              <img src={ICONS.pattern_match} alt="" style={{ width:'86%', height:'86%', objectFit:'contain',
                filter:'drop-shadow(0 4px 8px rgba(96,165,250,.6))' }} />
            </div>
          </div>
          <div style={{ display:'flex', gap:6, marginTop:14 }}>
            <div style={{ flex:1, height:6, borderRadius:3, background:'rgba(255,255,255,.06)', overflow:'hidden' }}>
              <div style={{ width: `${(currentLevel/totalLevels)*100}%`, height:'100%',
                background:'var(--grad-primary)', boxShadow:'0 0 10px rgba(96,165,250,.6)' }} />
            </div>
            <span className="tabular" style={{ fontSize:11, color:'var(--fg-secondary)', fontWeight:600, minWidth:46, textAlign:'right' }}>{currentLevel}/{totalLevels}</span>
          </div>
        </GlassCard>

        <div style={{ display:'flex', gap:6, justifyContent:'center', margin:'14px 0 10px' }}>
          <PathLegend dot="#34d399" label="Cleared" />
          <PathLegend dot="#60a5fa" label="Current" glow />
          <PathLegend dot="rgba(255,255,255,.18)" label="Locked" />
          <PathLegend dot="#facc15" label="Boss" />
        </div>
      </div>

      {/* Constellation */}
      <div style={{ position:'relative', padding:'4px 16px 140px', zIndex:1 }}>
        <PathConstellation levels={levels} />
      </div>
    </div>
  );
}

function PathLegend({ dot, label, glow }) {
  return (
    <div style={{ display:'inline-flex', alignItems:'center', gap:5, padding:'4px 10px',
      borderRadius:'var(--r-pill)', background:'rgba(255,255,255,.04)',
      border:'1px solid rgba(255,255,255,.06)' }}>
      <span style={{ width:7, height:7, borderRadius:'50%', background:dot,
        boxShadow: glow ? `0 0 6px ${dot}` : 'none' }} />
      <span style={{ fontSize:10, color:'var(--fg-tertiary)', fontWeight:600, letterSpacing:'0.05em' }}>{label}</span>
    </div>
  );
}

function PathConstellation({ levels }) {
  // Build a meandering S-curve path of points across a vertical canvas
  const w = 320;
  const rowH = 84;
  const cols = 3; // alternating left/center/right
  const positions = levels.map((lv, i) => {
    const row = i;
    const phase = Math.sin(i * 0.7) * 0.5 + 0.5; // 0..1
    const x = 36 + phase * (w - 72);
    const y = row * rowH + 40;
    return { ...lv, x, y };
  });
  const h = positions.length * rowH + 40;

  return (
    <div style={{ position:'relative', width:'100%', maxWidth:w, margin:'0 auto', height:h }}>
      {/* svg connections */}
      <svg width={w} height={h} style={{ position:'absolute', inset:0, pointerEvents:'none' }}>
        <defs>
          <linearGradient id="path-line" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#34d399"/>
            <stop offset="50%" stopColor="#60a5fa"/>
            <stop offset="100%" stopColor="rgba(255,255,255,.08)"/>
          </linearGradient>
        </defs>
        <path d={positions.map((p,i) => `${i===0?'M':'L'}${p.x},${p.y}`).join(' ')}
          fill="none" stroke="url(#path-line)" strokeWidth="2"
          strokeDasharray="2 6" strokeLinecap="round" opacity=".5" />
        <path d={positions.slice(0, 7).map((p,i) => `${i===0?'M':'L'}${p.x},${p.y}`).join(' ')}
          fill="none" stroke="url(#path-line)" strokeWidth="2.5"
          strokeLinecap="round" style={{ filter:'drop-shadow(0 0 6px rgba(96,165,250,.5))' }} />
      </svg>

      {/* nodes */}
      {positions.map((p, i) => (
        <PathNode key={i} {...p} />
      ))}
    </div>
  );
}

function PathNode({ n, x, y, state, type }) {
  const isBoss = type === 'boss';
  const size = isBoss ? 60 : 48;
  const bg = state === 'current' ? 'var(--grad-primary)'
           : state === 'done' ? 'linear-gradient(135deg, #10b981, #34d399)'
           : isBoss ? 'linear-gradient(135deg, #f59e0b, #fb923c)'
           : 'rgba(255,255,255,.05)';
  const border = state === 'current' ? 'rgba(96,165,250,.8)'
               : state === 'done' ? 'rgba(52,211,153,.5)'
               : isBoss ? 'rgba(250,204,21,.5)'
               : 'rgba(255,255,255,.10)';
  const glow = state === 'current' ? '0 0 24px rgba(96,165,250,.7)'
             : state === 'done' ? '0 0 14px rgba(52,211,153,.3)'
             : isBoss && state==='locked' ? '0 0 16px rgba(250,204,21,.25)'
             : 'none';
  return (
    <div style={{ position:'absolute', left: x - size/2, top: y - size/2, width:size, height:size }}>
      {state === 'current' && (
        <span aria-hidden style={{ position:'absolute', inset:-8, borderRadius:'50%',
          border:'1.5px solid rgba(96,165,250,.4)', animation:'pulse-glow 2s var(--e-smooth) infinite' }} />
      )}
      <div style={{ width:'100%', height:'100%', borderRadius:'50%',
        background: bg, border:`1.5px solid ${border}`, boxShadow: glow,
        display:'flex', alignItems:'center', justifyContent:'center',
        color: state === 'locked' ? 'var(--fg-muted)' : '#fff',
        fontSize: isBoss ? 18 : 15, fontWeight: 800, letterSpacing:'-0.02em',
        position:'relative', overflow:'hidden' }}>
        {state === 'locked' ? <LockIcon /> :
         state === 'done' ? <CheckIcon /> :
         <span className="tabular">{n}</span>}
        {isBoss && state === 'locked' && (
          <span style={{ position:'absolute', top:-2, right:-2, fontSize:9 }}>👑</span>
        )}
      </div>
      {state === 'current' && (
        <div style={{ position:'absolute', top:'100%', left:'50%', transform:'translate(-50%, 8px)',
          padding:'4px 10px', borderRadius:'var(--r-pill)', background:'rgba(8,11,20,.9)',
          border:'1px solid rgba(96,165,250,.4)', whiteSpace:'nowrap',
          fontSize:10, fontWeight:700, color:'#bfdbfe', letterSpacing:'0.08em', textTransform:'uppercase',
          boxShadow:'0 0 12px rgba(96,165,250,.3)' }}>
          You are here
        </div>
      )}
      {isBoss && state !== 'current' && (
        <div style={{ position:'absolute', top:'100%', left:'50%', transform:'translateX(-50%)',
          marginTop:6, fontSize:9, color: state==='done'? '#86efac' : '#fde68a', fontWeight:700,
          letterSpacing:'0.1em', textTransform:'uppercase', whiteSpace:'nowrap' }}>
          {state==='done' ? 'Cleared' : 'Boss'}
        </div>
      )}
    </div>
  );
}

window.PathScreen = PathScreen;
