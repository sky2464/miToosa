// Progress screen — XP hero ring, cognitive radar, achievements

const SKILLS = [
  { name:'Pattern Recognition', value:60, color:'#60a5fa' },
  { name:'Working Memory',      value:68, color:'#22d3ee' },
  { name:'Logical Reasoning',   value:76, color:'#c084fc' },
  { name:'Reaction Speed',      value:84, color:'#fb923c' },
  { name:'Spatial Sense',       value:52, color:'#34d399' },
  { name:'Focus',               value:71, color:'#ec4899' },
];

const ACHIEVEMENTS = [
  { id:'novice_mind',   name:'Novice mind',   sub:'Complete your first puzzle', unlocked:true,  img:'../../assets/badges/novice_mind.png' },
  { id:'focus_master',  name:'Focus master',  sub:'15 perfect runs',            unlocked:false, img:'../../assets/badges/focus_master.png',  progress:5,  total:15 },
  { id:'memory_marvel', name:'Memory marvel', sub:'Beat Memory Lab level 25',   unlocked:false, img:'../../assets/badges/memory_marvel.png', progress:7,  total:25 },
  { id:'logic_legend',  name:'Logic legend',  sub:'30 logic puzzles, no hints', unlocked:false, img:'../../assets/badges/logic_legend.png',  progress:12, total:30 },
  { id:'daily_spark',   name:'Daily spark',   sub:'7-day streak',               unlocked:false, img:'../../assets/badges/daily_spark.png',   progress:0,  total:7 },
  { id:'ultimate_brain',name:'Ultimate brain',sub:'All tracks at level 20+',    unlocked:false, img:'../../assets/badges/ultimate_brain.png',progress:1,  total:23 },
];

function ProgressScreen() {
  return (
    <div style={{ position:'relative', minHeight:'100%' }}>
      <Atmosphere accent="blue" />
      <AppHeader credits={1250} />

      <div style={{ padding:'4px 16px 140px', position:'relative', zIndex:1, display:'flex', flexDirection:'column', gap:16 }}>

        {/* XP hero */}
        <GlassCard radius={28} padding={22} accent="rgba(168,85,247,.18)">
          <div style={{ display:'flex', alignItems:'center', gap:18 }}>
            <ProgressRing value={8} size={132} stroke={10} label="80" sublabel="Total XP" />
            <div style={{ flex:1, minWidth:0 }}>
              <div className="eyebrow">Pilot rank</div>
              <div style={{ fontSize:22, fontWeight:800, letterSpacing:'-0.03em', marginTop:2 }}>
                Lv <span className="kinetic">1</span>
              </div>
              <div style={{ fontSize:11, color:'var(--fg-tertiary)', marginTop:2 }}>920 XP to level 2</div>
              <div style={{ marginTop:10, height:5, borderRadius:3, background:'rgba(255,255,255,.06)', overflow:'hidden' }}>
                <div style={{ width:'8%', height:'100%', background:'var(--grad-primary)', boxShadow:'0 0 8px rgba(96,165,250,.6)' }} />
              </div>
              <div style={{ display:'flex', gap:6, marginTop:12, flexWrap:'wrap' }}>
                <StatPill icon={<Flame size={12}/>} label="0 day" tint="orange" />
                <StatPill icon={<Star size={12}/>}  label="35"    tint="purple" />
                <StatPill icon={<Bolt size={12}/>}  label="25"    tint="amber" />
              </div>
            </div>
          </div>
        </GlassCard>

        {/* Cognitive radar */}
        <GlassCard radius={24} padding={20}>
          <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between', marginBottom:14 }}>
            <h2 style={{ margin:0, fontSize:16, fontWeight:700, letterSpacing:'-0.02em' }}>Cognitive map</h2>
            <span className="eyebrow">7-day delta</span>
          </div>
          <div style={{ display:'flex', alignItems:'center', gap:16 }}>
            <SkillRadar skills={SKILLS} />
            <div style={{ flex:1, display:'flex', flexDirection:'column', gap:8 }}>
              {SKILLS.map(s => (
                <div key={s.name} style={{ display:'flex', alignItems:'center', gap:8 }}>
                  <span style={{ width:8, height:8, borderRadius:2, background:s.color,
                    boxShadow:`0 0 6px ${s.color}` }} />
                  <span style={{ fontSize:10.5, color:'var(--fg-secondary)', flex:1, lineHeight:1.2 }}>{s.name}</span>
                  <span className="tabular" style={{ fontSize:11, fontWeight:700, color:s.color }}>{s.value}</span>
                </div>
              ))}
            </div>
          </div>
        </GlassCard>

        {/* Weekly activity */}
        <GlassCard radius={24} padding={20}>
          <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between', marginBottom:12 }}>
            <h2 style={{ margin:0, fontSize:16, fontWeight:700, letterSpacing:'-0.02em' }}>This week</h2>
            <span style={{ fontSize:11, color:'var(--fg-tertiary)' }}>
              <span style={{ color:'#facc15', fontWeight:700 }}>80</span> XP earned
            </span>
          </div>
          <WeeklyBars />
        </GlassCard>

        {/* Achievements */}
        <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between', marginTop:4 }}>
          <h2 style={{ margin:0, fontSize:18, fontWeight:700, letterSpacing:'-0.02em' }}>Milestones</h2>
          <span style={{ fontSize:11, color:'var(--fg-muted)' }}>1 of 6 unlocked</span>
        </div>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:10 }}>
          {ACHIEVEMENTS.map(a => <AchievementCard key={a.id} a={a} />)}
        </div>

      </div>
    </div>
  );
}

function SkillRadar({ skills }) {
  const size = 140;
  const cx = size/2, cy = size/2;
  const maxR = size/2 - 8;
  const n = skills.length;
  const pts = skills.map((s,i) => {
    const a = (i / n) * Math.PI * 2 - Math.PI/2;
    const r = (s.value/100) * maxR;
    return { x: cx + Math.cos(a)*r, y: cy + Math.sin(a)*r, color: s.color };
  });
  const rings = [0.25, 0.5, 0.75, 1];

  return (
    <svg width={size} height={size}>
      <defs>
        <linearGradient id="radar-fill" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#3b82f6" stopOpacity=".4" />
          <stop offset="100%" stopColor="#a855f7" stopOpacity=".4" />
        </linearGradient>
      </defs>
      {rings.map((r,i) => (
        <circle key={i} cx={cx} cy={cy} r={maxR*r} fill="none"
          stroke="rgba(255,255,255,.06)" strokeWidth="1" />
      ))}
      {skills.map((_,i) => {
        const a = (i / n) * Math.PI * 2 - Math.PI/2;
        return <line key={i} x1={cx} y1={cy} x2={cx + Math.cos(a)*maxR} y2={cy + Math.sin(a)*maxR}
          stroke="rgba(255,255,255,.05)" strokeWidth="1" />;
      })}
      <polygon points={pts.map(p => `${p.x},${p.y}`).join(' ')}
        fill="url(#radar-fill)" stroke="#60a5fa" strokeWidth="1.5"
        style={{ filter:'drop-shadow(0 0 8px rgba(96,165,250,.5))' }} />
      {pts.map((p,i) => (
        <circle key={i} cx={p.x} cy={p.y} r="3" fill={p.color}
          style={{ filter:`drop-shadow(0 0 4px ${p.color})` }} />
      ))}
    </svg>
  );
}

function WeeklyBars() {
  const data = [3, 0, 8, 12, 0, 15, 2]; // XP per day
  const max = Math.max(...data, 1);
  const days = ['M','T','W','T','F','S','S'];
  return (
    <div style={{ display:'flex', alignItems:'flex-end', justifyContent:'space-between', gap:6, height:64 }}>
      {data.map((v,i) => {
        const h = (v/max) * 100;
        const today = i === 6;
        return (
          <div key={i} style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', gap:6, height:'100%' }}>
            <div style={{ flex:1, width:'100%', display:'flex', alignItems:'flex-end' }}>
              <div style={{ width:'100%', height:`${Math.max(h, 4)}%`, borderRadius:'6px 6px 2px 2px',
                background: v===0 ? 'rgba(255,255,255,.06)'
                  : today ? 'var(--grad-primary)'
                  : 'linear-gradient(180deg, rgba(96,165,250,.7), rgba(168,85,247,.4))',
                boxShadow: today ? '0 0 10px rgba(96,165,250,.5)' : 'none',
                transition:'height .6s var(--e-out)' }} />
            </div>
            <span style={{ fontSize:10, color: today ? '#bfdbfe' : 'var(--fg-muted)',
              fontWeight: today ? 700 : 500 }}>{days[i]}</span>
          </div>
        );
      })}
    </div>
  );
}

function AchievementCard({ a }) {
  const pct = a.unlocked ? 100 : Math.round((a.progress/a.total)*100);
  return (
    <div style={{ position:'relative', padding:14, borderRadius:20,
      background: a.unlocked ? 'rgba(96,165,250,.06)' : 'rgba(255,255,255,.04)',
      border: a.unlocked ? '1px solid rgba(96,165,250,.3)' : '1px solid rgba(255,255,255,.07)',
      boxShadow: a.unlocked ? '0 0 18px rgba(96,165,250,.18)' : 'none', overflow:'hidden' }}>
      <div style={{ position:'relative', width:60, height:60, margin:'0 auto 8px',
        opacity: a.unlocked ? 1 : 0.5,
        filter: a.unlocked ? 'drop-shadow(0 4px 10px rgba(96,165,250,.5))' : 'grayscale(.6) brightness(.7)' }}>
        <img src={a.img} alt="" style={{ width:'100%', height:'100%', objectFit:'contain' }} />
        {!a.unlocked && (
          <div style={{ position:'absolute', bottom:-2, right:-2, width:20, height:20, borderRadius:'50%',
            background:'rgba(8,11,20,.95)', border:'1px solid rgba(255,255,255,.1)',
            display:'flex', alignItems:'center', justifyContent:'center', color:'var(--fg-muted)' }}>
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>
            </svg>
          </div>
        )}
      </div>
      <div style={{ textAlign:'center', fontSize:11, fontWeight:700, letterSpacing:'-0.01em',
        color: a.unlocked ? '#fff' : 'var(--fg-secondary)' }}>{a.name}</div>
      <div style={{ textAlign:'center', fontSize:9.5, color:'var(--fg-muted)', marginTop:2, lineHeight:1.3, minHeight:24 }}>
        {a.sub}
      </div>
      {!a.unlocked && (
        <div style={{ display:'flex', alignItems:'center', gap:6, marginTop:8 }}>
          <div style={{ flex:1, height:3, borderRadius:2, background:'rgba(255,255,255,.06)', overflow:'hidden' }}>
            <div style={{ width:`${pct}%`, height:'100%', background:'var(--grad-primary)' }} />
          </div>
          <span className="tabular" style={{ fontSize:9, color:'var(--fg-tertiary)', fontWeight:700 }}>
            {a.progress}/{a.total}
          </span>
        </div>
      )}
      {a.unlocked && (
        <div style={{ marginTop:8, textAlign:'center', fontSize:9, color:'#93c5fd',
          letterSpacing:'0.12em', textTransform:'uppercase', fontWeight:700 }}>
          Unlocked
        </div>
      )}
    </div>
  );
}

window.ProgressScreen = ProgressScreen;
