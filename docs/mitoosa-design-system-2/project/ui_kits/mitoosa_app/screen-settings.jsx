// Settings screen

function SettingsScreen() {
  const [sound, setSound]   = React.useState(true);
  const [music, setMusic]   = React.useState(true);
  const [haptic, setHaptic] = React.useState(true);
  const [notif, setNotif]   = React.useState(true);
  return (
    <div style={{ position:'relative', minHeight:'100%' }}>
      <Atmosphere accent="blue" />
      <AppHeader credits={1250} />

      <div style={{ padding:'4px 16px 140px', position:'relative', zIndex:1, display:'flex', flexDirection:'column', gap:16 }}>

        <h1 style={{ margin:'4px 0 0', fontSize:28, fontWeight:800, letterSpacing:'-0.03em' }}>Settings</h1>

        {/* Profile card */}
        <GlassCard radius={24} padding={18}>
          <div style={{ display:'flex', alignItems:'center', gap:14 }}>
            <div style={{ position:'relative', width:64, height:64 }}>
              <div style={{ position:'absolute', inset:-2, borderRadius:'50%',
                background:'var(--grad-primary)', filter:'blur(2px)' }} />
              <div style={{ position:'relative', width:'100%', height:'100%', borderRadius:'50%',
                overflow:'hidden', border:'2px solid rgba(96,165,250,.6)' }}>
                <img src="../../assets/avatars/avatar_4.png" alt="" style={{ width:'100%', height:'100%', objectFit:'cover' }} />
              </div>
            </div>
            <div style={{ flex:1, minWidth:0 }}>
              <div style={{ fontSize:17, fontWeight:800, letterSpacing:'-0.02em' }}>Pilot_042</div>
              <div style={{ fontSize:11, color:'var(--fg-tertiary)', marginTop:2 }}>
                Level 1 · <span style={{ color:'#facc15' }}>1,250 credits</span>
              </div>
              <div style={{ marginTop:8, display:'flex', gap:6 }}>
                <GhostButton style={{ padding:'5px 10px', fontSize:11 }}>Edit profile</GhostButton>
                <GhostButton style={{ padding:'5px 10px', fontSize:11 }}>Avatar</GhostButton>
              </div>
            </div>
          </div>
        </GlassCard>

        {/* Mastery */}
        <div>
          <div className="eyebrow" style={{ marginBottom:8 }}>Your mastery</div>
          <GlassCard radius={20} padding={16}>
            <div style={{ display:'flex', alignItems:'center', gap:12 }}>
              <div style={{ width:54, height:54, borderRadius:14,
                background:'linear-gradient(135deg, rgba(245,158,11,.2), rgba(180,83,9,.2))',
                border:'1px solid rgba(245,158,11,.4)',
                display:'flex', alignItems:'center', justifyContent:'center',
                boxShadow:'0 0 16px rgba(245,158,11,.25)' }}>
                <img src="../../assets/badges/novice_mind.png" alt="" style={{ width:42, height:42, objectFit:'contain',
                  filter:'sepia(.4) hue-rotate(340deg) saturate(2)' }} />
              </div>
              <div style={{ flex:1 }}>
                <div style={{ fontSize:16, fontWeight:800,
                  background:'linear-gradient(135deg, #fde68a, #f59e0b)',
                  WebkitBackgroundClip:'text', backgroundClip:'text', color:'transparent' }}>Bronze mastery</div>
                <div style={{ fontSize:11, color:'var(--fg-tertiary)', marginTop:2, lineHeight:1.4 }}>
                  Complete 50 levels for Silver.
                </div>
                <div style={{ marginTop:8, display:'flex', alignItems:'center', gap:8 }}>
                  <div style={{ flex:1, height:4, borderRadius:2, background:'rgba(255,255,255,.06)', overflow:'hidden' }}>
                    <div style={{ width:'14%', height:'100%', background:'var(--grad-energy)' }} />
                  </div>
                  <span className="tabular" style={{ fontSize:10, color:'var(--fg-tertiary)', fontWeight:700 }}>7/50</span>
                </div>
              </div>
            </div>
          </GlassCard>
        </div>

        {/* VIP card */}
        <GlassCard radius={22} padding={18} accent="rgba(250,204,21,.18)" style={{
          background:'linear-gradient(135deg, rgba(250,204,21,.06), rgba(168,85,247,.05))',
          border:'1px solid rgba(250,204,21,.25)'
        }}>
          <div style={{ display:'flex', alignItems:'center', gap:14 }}>
            <div style={{ width:48, height:48, borderRadius:14, background:'var(--grad-gold)',
              display:'flex', alignItems:'center', justifyContent:'center',
              boxShadow:'0 4px 16px rgba(250,204,21,.4), inset 0 1px 0 rgba(255,255,255,.4)' }}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="#7c2d12">
                <path d="M2 7l4 11h12l4-11-6 4-4-8-4 8z"/>
              </svg>
            </div>
            <div style={{ flex:1 }}>
              <div style={{ fontSize:15, fontWeight:800, color:'#fde68a' }}>Go VIP</div>
              <div style={{ fontSize:11, color:'rgba(253,230,138,.7)', marginTop:2 }}>
                Ad-free · +10 games/day · 2× XP weekends
              </div>
            </div>
            <button style={{ padding:'8px 14px', border:0, borderRadius:'var(--r-pill)',
              background:'var(--grad-gold)', color:'#451a03', fontWeight:800, fontSize:11,
              letterSpacing:'0.08em', textTransform:'uppercase', cursor:'pointer',
              boxShadow:'0 4px 12px rgba(245,158,11,.4)' }}>
              Upgrade
            </button>
          </div>
        </GlassCard>

        {/* Share */}
        <div>
          <div className="eyebrow" style={{ marginBottom:8 }}>Account</div>
          <GlassCard radius={20} padding={4}>
            <Row icon={<ShareIcon />} title="Invite a friend" sub="+40 sessions per invite" trail={<ChevronR />} tint="#60a5fa" />
            <Divider />
            <Row icon={<BellIcon />} title="Notifications" sub="Daily streak reminder" trail={<Toggle v={notif} onChange={setNotif} />} tint="#a78bfa" />
          </GlassCard>
        </div>

        {/* System */}
        <div>
          <div className="eyebrow" style={{ marginBottom:8 }}>System</div>
          <GlassCard radius={20} padding={4}>
            <Row icon={<SpeakerIcon />} title="Sound effects" trail={<Toggle v={sound} onChange={setSound} />} tint="#60a5fa" />
            <Divider />
            <Row icon={<NoteIcon />} title="Music" sub="Background tracks during play" trail={<Toggle v={music} onChange={setMusic} />} tint="#22d3ee" />
            <Divider />
            <Row icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round"><path d="M4 18v-6a8 8 0 0 1 16 0v6M4 18a2 2 0 0 0 4 0M20 18a2 2 0 0 1-4 0"/></svg>}
              title="Haptics" trail={<Toggle v={haptic} onChange={setHaptic} />} tint="#c084fc" />
          </GlassCard>
        </div>

        {/* Help */}
        <div>
          <div className="eyebrow" style={{ marginBottom:8 }}>Support</div>
          <GlassCard radius={20} padding={4}>
            <Row icon={<HelpIcon />} title="How to play" trail={<ChevronR />} tint="#34d399" />
            <Divider />
            <Row icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>}
              title="Adaptive difficulty" sub="On — adjusts to your level" trail={<ChevronR />} tint="#ec4899" />
            <Divider />
            <Row icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round"><rect x="3" y="11" width="18" height="10" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>}
              title="Privacy" sub="All data stays on this device" trail={<ChevronR />} tint="#facc15" />
          </GlassCard>
        </div>

        <div style={{ textAlign:'center', fontSize:10, color:'var(--fg-muted)', letterSpacing:'0.1em', marginTop:8 }}>
          miToosa · v1.3.0 · made with care
        </div>

      </div>
    </div>
  );
}

function Row({ icon, title, sub, trail, tint='#60a5fa' }) {
  return (
    <div style={{ display:'flex', alignItems:'center', gap:12, padding:'14px 14px' }}>
      <div style={{ width:34, height:34, borderRadius:10,
        background:`${tint}18`, border:`1px solid ${tint}30`,
        display:'flex', alignItems:'center', justifyContent:'center', color: tint, flexShrink:0 }}>
        {icon}
      </div>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ fontSize:14, fontWeight:600, letterSpacing:'-0.01em' }}>{title}</div>
        {sub && <div style={{ fontSize:11, color:'var(--fg-tertiary)', marginTop:2 }}>{sub}</div>}
      </div>
      <div style={{ color:'var(--fg-muted)', display:'flex' }}>{trail}</div>
    </div>
  );
}
function Divider() {
  return <div style={{ height:1, marginLeft:60, background:'rgba(255,255,255,.04)' }} />;
}
function Toggle({ v, onChange }) {
  return (
    <button onClick={() => onChange(!v)} style={{ width:42, height:24, borderRadius:14, border:0,
      padding:2, cursor:'pointer', transition:'background .18s',
      background: v ? 'var(--grad-primary)' : 'rgba(255,255,255,.08)',
      boxShadow: v ? '0 0 10px rgba(96,165,250,.4), inset 0 1px 0 rgba(255,255,255,.2)' : 'inset 0 1px 2px rgba(0,0,0,.3)' }}>
      <div style={{ width:18, height:18, borderRadius:'50%', background:'#fff',
        transform: v ? 'translateX(20px)' : 'translateX(2px)',
        transition:'transform .22s var(--e-snappy)',
        boxShadow:'0 2px 6px rgba(0,0,0,.4)' }} />
    </button>
  );
}

window.SettingsScreen = SettingsScreen;
