// Tracks screen — Daily Spark hero + featured track + categories grid

const TRACKS = [
  { id:'pattern_match',  name:'Pattern Match',   sub:'Match identical patterns',   levels:50, accent:'#60a5fa', skill:'Pattern' },
  { id:'shape_counter',  name:'Shape Counter',   sub:'Count and calculate',         levels:30, accent:'#34d399', skill:'Reasoning' },
  { id:'logic_gates',    name:'Logic Gates',     sub:'Wire the circuit',            levels:25, accent:'#c084fc', skill:'Logic' },
  { id:'memory',         name:'Memory Lab',      sub:'Hold the sequence',           levels:40, accent:'#22d3ee', skill:'Memory' },
  { id:'number_crunch',  name:'Number Crunch',   sub:'Solve before the timer',      levels:35, accent:'#fb923c', skill:'Speed' },
  { id:'sequence',       name:'Sequence',        sub:'What comes next',             levels:30, accent:'#ec4899', skill:'Pattern' },
  { id:'color_code',     name:'Color Code',      sub:'Decode the chromatic key',    levels:20, accent:'#facc15', skill:'Focus' },
  { id:'spatial',        name:'Spatial',         sub:'Rotate to fit',               levels:25, accent:'#a78bfa', skill:'Spatial' },
];

function TracksScreen({ onPlay, motion }) {
  const [filter, setFilter] = React.useState('all');
  const filters = ['all','memory','logic','speed','spatial'];
  const dailyProgress = 0;
  const dailyTotal = 5;

  return (
    <div style={{ position:'relative', minHeight:'100%' }}>
      <Atmosphere accent="blue" />

      <AppHeader credits={1250} />

      <div style={{ padding:'4px 16px 140px', position:'relative', zIndex:1, display:'flex', flexDirection:'column', gap:16 }}>

        {/* Daily Spark hero */}
        <GlassCard radius={28} padding={20} accent="rgba(59,130,246,.18)">
          <div style={{ display:'flex', alignItems:'flex-start', justifyContent:'space-between', gap:12 }}>
            <div style={{ flex:1 }}>
              <div className="eyebrow" style={{ color:'#93c5fd', marginBottom:8 }}>Daily spark · resets in 6h 12m</div>
              <h1 style={{ margin:0, fontSize:28, fontWeight:800, letterSpacing:'-0.03em', lineHeight:1.05 }}>
                Today&rsquo;s session
              </h1>
              <p style={{ margin:'8px 0 0', fontSize:13, color:'var(--fg-tertiary)', lineHeight:1.45, maxWidth:200 }}>
                5 puzzles across 3 skills. Earn <span style={{ color:'#facc15', fontWeight:600 }}>+200 XP</span> and a streak.
              </p>
            </div>
            <ProgressRing value={(dailyProgress/dailyTotal)*100} size={96} stroke={8}
              label={`${dailyProgress}/${dailyTotal}`} sublabel="games" />
          </div>

          {/* dot row showing the planned sequence */}
          <div style={{ display:'flex', gap:6, margin:'18px 0 14px' }}>
            {['Pattern','Logic','Memory','Speed','Spatial'].map((s,i) => (
              <div key={i} style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', gap:6 }}>
                <div style={{ width:'100%', height:4, borderRadius:2,
                  background: i < dailyProgress ? 'var(--grad-primary)' : 'rgba(255,255,255,.08)',
                  boxShadow: i < dailyProgress ? '0 0 8px rgba(96,165,250,.6)' : 'none' }} />
                <span style={{ fontSize:9, color: i === dailyProgress ? '#bfdbfe' : 'var(--fg-muted)',
                  fontWeight: i === dailyProgress ? 700 : 500, letterSpacing:'0.04em' }}>{s}</span>
              </div>
            ))}
          </div>

          <PrimaryButton full onClick={() => onPlay && onPlay('pattern_match')}>
            <PlayIcon /> <span>Start session</span>
          </PrimaryButton>
        </GlassCard>

        {/* Stat strip */}
        <div style={{ display:'flex', gap:8, overflowX:'auto' }} className="no-scrollbar">
          <StatPill icon={<Flame size={14}/>} label="0 day streak" tint="orange" />
          <StatPill icon={<Bolt size={14}/>}  label="25/25 energy" tint="amber" glow />
          <StatPill icon={<Star size={14}/>}  label="35 stars"     tint="purple" />
          <StatPill icon={<Diamond size={14}/>} label="80 XP"      tint="blue" />
        </div>

        {/* Filter pills */}
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginTop:4 }}>
          <h2 style={{ margin:0, fontSize:18, fontWeight:700, letterSpacing:'-0.02em' }}>Training tracks</h2>
          <span style={{ fontSize:11, color:'var(--fg-muted)', letterSpacing:'0.08em', textTransform:'uppercase' }}>23 total</span>
        </div>
        <div style={{ display:'flex', gap:6, overflowX:'auto', margin:'-4px -16px 0', padding:'4px 16px' }} className="no-scrollbar">
          {filters.map(f => {
            const active = filter === f;
            return (
              <button key={f} onClick={() => setFilter(f)}
                style={{ flex:'0 0 auto', padding:'7px 14px', borderRadius:'var(--r-pill)',
                  border:`1px solid ${active ? 'rgba(96,165,250,.55)' : 'rgba(255,255,255,.10)'}`,
                  background: active ? 'rgba(59,130,246,.18)' : 'rgba(255,255,255,.04)',
                  color: active ? '#dbeafe' : 'var(--fg-tertiary)',
                  fontSize:12, fontWeight:600, letterSpacing:'0.02em', cursor:'pointer',
                  textTransform:'capitalize',
                  boxShadow: active ? '0 0 14px rgba(59,130,246,.3)' : 'none' }}>
                {f}
              </button>
            );
          })}
        </div>

        {/* Featured track — full-width tile */}
        <FeaturedTrack track={TRACKS[0]} onPlay={onPlay} />

        {/* Track grid */}
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
          {TRACKS.slice(1).map(t => <TrackTile key={t.id} track={t} onPlay={onPlay} />)}
        </div>

      </div>
    </div>
  );
}

function FeaturedTrack({ track, onPlay }) {
  return (
    <button onClick={() => onPlay && onPlay(track.id)}
      style={{ position:'relative', textAlign:'left', padding:18, borderRadius:28,
        background:'rgba(255,255,255,.06)', backdropFilter:'blur(24px)',
        border:`1px solid ${track.accent}55`,
        boxShadow:`0 12px 36px rgba(0,0,0,.4), 0 0 24px ${track.accent}30, inset 0 1px 0 rgba(255,255,255,.08)`,
        cursor:'pointer', overflow:'hidden', display:'flex', alignItems:'center', gap:14 }}>
      <span aria-hidden style={{ position:'absolute', top:-40, right:-40, width:200, height:200, borderRadius:'50%',
        background:`radial-gradient(circle, ${track.accent}55 0%, transparent 60%)`, filter:'blur(20px)' }} />
      <div style={{ position:'relative', width:88, height:88, borderRadius:18,
        background:'rgba(255,255,255,.05)', border:'1px solid rgba(255,255,255,.08)',
        display:'flex', alignItems:'center', justifyContent:'center', overflow:'hidden', flexShrink:0 }}>
        <img src={ICONS[track.id]} alt="" style={{ width:'92%', height:'92%', objectFit:'contain',
          filter:`drop-shadow(0 4px 12px ${track.accent}80)`,
          animation:'float-y 4s var(--e-smooth) infinite' }} />
      </div>
      <div style={{ flex:1, minWidth:0, position:'relative' }}>
        <div className="eyebrow" style={{ color: track.accent, marginBottom:4 }}>Recommended for you</div>
        <div style={{ fontSize:20, fontWeight:800, letterSpacing:'-0.02em', lineHeight:1.1 }}>{track.name}</div>
        <div style={{ fontSize:12, color:'var(--fg-tertiary)', marginTop:3 }}>{track.sub}</div>
        <div style={{ display:'flex', alignItems:'center', gap:10, marginTop:10 }}>
          <div style={{ flex:1, height:6, borderRadius:3, background:'rgba(255,255,255,.06)', overflow:'hidden' }}>
            <div style={{ width:'14%', height:'100%', borderRadius:3,
              background:`linear-gradient(90deg, ${track.accent}, #a855f7)`,
              boxShadow:`0 0 10px ${track.accent}` }} />
          </div>
          <span className="tabular" style={{ fontSize:11, color:'var(--fg-secondary)', fontWeight:600 }}>7/{track.levels}</span>
        </div>
      </div>
      <div style={{ position:'relative', width:44, height:44, borderRadius:'50%',
        background:'var(--grad-primary)', display:'flex', alignItems:'center', justifyContent:'center',
        boxShadow:'0 6px 18px rgba(59,130,246,.5), inset 0 1px 0 rgba(255,255,255,.3)' }}>
        <PlayIcon />
      </div>
    </button>
  );
}

function TrackTile({ track, onPlay }) {
  return (
    <button onClick={() => onPlay && onPlay(track.id)}
      style={{ position:'relative', textAlign:'left', padding:14, borderRadius:22,
        background:'rgba(255,255,255,.05)', backdropFilter:'blur(20px)',
        border:'1px solid rgba(255,255,255,.08)', cursor:'pointer', overflow:'hidden',
        boxShadow:'var(--sh-card)' }}>
      <span aria-hidden style={{ position:'absolute', top:-20, right:-30, width:120, height:120, borderRadius:'50%',
        background:`radial-gradient(circle, ${track.accent}30 0%, transparent 60%)`, filter:'blur(14px)' }} />
      <div style={{ position:'relative', width:'100%', aspectRatio:'1/1', borderRadius:14,
        background:'rgba(255,255,255,.03)', border:'1px solid rgba(255,255,255,.05)',
        display:'flex', alignItems:'center', justifyContent:'center', marginBottom:10, overflow:'hidden' }}>
        <img src={ICONS[track.id]} alt="" style={{ width:'78%', height:'78%', objectFit:'contain',
          filter:`drop-shadow(0 6px 14px ${track.accent}70)` }}
          onError={e => { e.target.style.display='none'; }} />
      </div>
      <div style={{ fontSize:13, fontWeight:700, letterSpacing:'-0.01em', lineHeight:1.15 }}>{track.name}</div>
      <div style={{ fontSize:10, color:'var(--fg-muted)', letterSpacing:'0.1em', textTransform:'uppercase', fontWeight:600, marginTop:3 }}>
        {track.skill} · {track.levels} lv
      </div>
    </button>
  );
}

window.TracksScreen = TracksScreen;
