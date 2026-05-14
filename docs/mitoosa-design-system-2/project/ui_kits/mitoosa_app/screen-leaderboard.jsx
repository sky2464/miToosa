// Leaderboard screen

const PEOPLE = [
  { rank:1, name:'Mira K.',   xp:24820, avatar:'avatar_1.png', frame:'gold' },
  { rank:2, name:'Diego R.',  xp:22110, avatar:'avatar_2.png', frame:'silver' },
  { rank:3, name:'Aiko T.',   xp:19500, avatar:'avatar_3.png', frame:'bronze' },
  { rank:4, name:'Pilot_042', xp:80,    avatar:'avatar_4.png', you:true },
  { rank:5, name:'Priya S.',  xp:11230, avatar:'avatar_5.png' },
  { rank:6, name:'Jordan L.', xp:10870, avatar:'avatar_6.png' },
  { rank:7, name:'Kenji M.',  xp:9420,  avatar:'avatar_7.png' },
  { rank:8, name:'Sasha B.',  xp:8120,  avatar:'avatar_8.png' },
];

function LeaderboardScreen() {
  const [scope, setScope] = React.useState('global');

  return (
    <div style={{ position:'relative', minHeight:'100%' }}>
      <Atmosphere accent="pink" />
      <AppHeader credits={1250} />

      <div style={{ padding:'4px 16px 140px', position:'relative', zIndex:1, display:'flex', flexDirection:'column', gap:14 }}>
        <div>
          <div className="eyebrow" style={{ color:'#c084fc' }}>Weekly · resets Sun 23:59</div>
          <h1 style={{ margin:'4px 0 0', fontSize:32, fontWeight:800, letterSpacing:'-0.04em',
            background:'linear-gradient(135deg, #60a5fa, #c084fc 50%, #ec4899)',
            WebkitBackgroundClip:'text', backgroundClip:'text', color:'transparent', lineHeight:1 }}>
            Leaderboard
          </h1>
          <div style={{ fontSize:12, color:'var(--fg-tertiary)', marginTop:6 }}>
            You&rsquo;re ranked <span style={{ color:'#fff', fontWeight:700 }}>#4</span> · 19,420 XP to top 3
          </div>
        </div>

        {/* Segmented control */}
        <div style={{ position:'relative', display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:0,
          padding:4, borderRadius:'var(--r-pill)', background:'rgba(255,255,255,.04)',
          border:'1px solid rgba(255,255,255,.08)' }}>
          {['global','friends','local'].map(s => {
            const active = scope === s;
            return (
              <button key={s} onClick={() => setScope(s)}
                style={{ position:'relative', padding:'9px 0', border:0, cursor:'pointer',
                  borderRadius:'var(--r-pill)', color: active ? '#fff' : 'var(--fg-tertiary)',
                  background: active ? 'var(--grad-primary)' : 'transparent',
                  fontSize:12, fontWeight:700, letterSpacing:'0.06em', textTransform:'uppercase',
                  boxShadow: active ? '0 4px 14px rgba(59,130,246,.4)' : 'none',
                  transition:'all .2s' }}>
                {s}
              </button>
            );
          })}
        </div>

        {/* Podium */}
        <div style={{ position:'relative', height:170, marginTop:4 }}>
          <Podium people={PEOPLE.slice(0,3)} />
        </div>

        {/* You row pinned */}
        {(() => {
          const me = PEOPLE.find(p => p.you);
          return <LeaderRow p={me} pinned />;
        })()}

        {/* The rest of the list */}
        <div style={{ display:'flex', flexDirection:'column', gap:8 }}>
          {PEOPLE.filter(p => !p.you && p.rank > 3).map(p => <LeaderRow key={p.rank} p={p} />)}
        </div>
      </div>
    </div>
  );
}

function Podium({ people }) {
  // arrange 2, 1, 3
  const order = [people[1], people[0], people[2]];
  const heights = [70, 100, 56];
  const colors = ['rgba(192,191,200,.22)', 'rgba(250,204,21,.28)', 'rgba(176,121,71,.25)'];
  const borders = ['rgba(203,213,225,.5)', 'rgba(250,204,21,.7)', 'rgba(176,121,71,.55)'];
  return (
    <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr', alignItems:'flex-end', gap:10, height:'100%' }}>
      {order.map((p, i) => {
        const isFirst = p.rank === 1;
        return (
          <div key={p.rank} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:6 }}>
            {isFirst && <span style={{ fontSize:20, animation:'float-y 3s var(--e-smooth) infinite' }}>👑</span>}
            <div style={{ position:'relative', width: isFirst ? 64 : 52, height: isFirst ? 64 : 52 }}>
              <div style={{ position:'absolute', inset:-3, borderRadius:'50%',
                background: p.rank === 1 ? 'var(--grad-gold)'
                  : p.rank === 2 ? 'linear-gradient(135deg, #e2e8f0, #94a3b8)'
                  : 'linear-gradient(135deg, #f59e0b, #b45309)',
                filter:'blur(2px)' }} />
              <div style={{ position:'relative', width:'100%', height:'100%', borderRadius:'50%',
                background:'#0a0d17', overflow:'hidden',
                border:`2px solid ${borders[i]}` }}>
                <img src={`../../assets/avatars/${p.avatar}`} alt="" style={{ width:'100%', height:'100%', objectFit:'cover' }} />
              </div>
            </div>
            <div style={{ fontSize:11, fontWeight:700, color:'#fff', maxWidth:'100%', overflow:'hidden',
              textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{p.name}</div>
            <div className="tabular" style={{ fontSize:10, color:'var(--fg-tertiary)', fontWeight:600, marginTop:-2 }}>
              {p.xp.toLocaleString()} XP
            </div>
            <div style={{ width:'100%', height: heights[i], borderRadius:'12px 12px 4px 4px',
              background: colors[i], border:`1px solid ${borders[i]}55`,
              display:'flex', alignItems:'center', justifyContent:'center',
              fontSize:24, fontWeight:900, color:'#fff', letterSpacing:'-0.02em',
              boxShadow:`inset 0 1px 0 rgba(255,255,255,.1), 0 0 18px ${colors[i]}` }}>
              {p.rank}
            </div>
          </div>
        );
      })}
    </div>
  );
}

function LeaderRow({ p, pinned }) {
  const isYou = p.you;
  return (
    <div style={{ position:'relative', display:'flex', alignItems:'center', gap:12, padding:'12px 14px',
      borderRadius:18,
      background: isYou ? 'rgba(96,165,250,.10)' : 'rgba(255,255,255,.04)',
      border: isYou ? '1px solid rgba(96,165,250,.45)' : '1px solid rgba(255,255,255,.06)',
      boxShadow: isYou ? '0 0 18px rgba(96,165,250,.25), inset 0 1px 0 rgba(255,255,255,.05)'
                       : 'inset 0 1px 0 rgba(255,255,255,.03)' }}>
      <div style={{ width:28, textAlign:'center' }} className="tabular">
        <span style={{ fontSize:14, fontWeight:800, color: isYou ? '#bfdbfe' : 'var(--fg-tertiary)' }}>
          {p.rank}
        </span>
      </div>
      <div style={{ position:'relative', width:36, height:36, borderRadius:'50%',
        background:'#0a0d17', overflow:'hidden',
        border:`1.5px solid ${isYou ? 'rgba(96,165,250,.6)' : 'rgba(255,255,255,.1)'}` }}>
        <img src={`../../assets/avatars/${p.avatar}`} alt="" style={{ width:'100%', height:'100%', objectFit:'cover' }} />
      </div>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ display:'flex', alignItems:'center', gap:6 }}>
          <span style={{ fontSize:13, fontWeight:700, color:'#fff' }}>{p.name}</span>
          {isYou && <span style={{ fontSize:9, padding:'2px 6px', borderRadius:6,
            background:'rgba(96,165,250,.2)', color:'#bfdbfe', fontWeight:700, letterSpacing:'0.1em' }}>YOU</span>}
        </div>
        <div className="tabular" style={{ fontSize:11, color:'var(--fg-tertiary)', marginTop:2 }}>
          {p.xp.toLocaleString()} XP
        </div>
      </div>
      <div style={{ width:32, height:32, borderRadius:'50%',
        background: isYou ? 'rgba(96,165,250,.15)' : 'rgba(255,255,255,.04)',
        display:'flex', alignItems:'center', justifyContent:'center', color: isYou ? '#60a5fa' : 'var(--fg-muted)' }}>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
          <path d="M3 13l4 4 4-7 4 5 6-9"/>
        </svg>
      </div>
    </div>
  );
}

window.LeaderboardScreen = LeaderboardScreen;
