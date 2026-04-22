// Shell.jsx — orchestrator + top-app-bar + bottom-nav
// Matches uploads/screen.png: fixed top bar with MITOOSA wordmark + CR pill,
// fixed bottom nav with Tracks / Progress / Leaderboard.

const { useState: useStateSh } = React;

function TopBar() {
  return (
    <header style={{
      position: 'absolute', top: 0, left: 0, right: 0, zIndex: 50,
      height: 56,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 16px',
      background: 'rgba(11,14,20,.65)',
      backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
      borderBottom: '1px solid rgba(255,255,255,.08)',
      boxShadow: '0 4px 20px rgba(0,240,255,.08)',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <img src="../../assets/avatars/avatar_4.png" alt=""
          style={{
            width: 32, height: 32, borderRadius: 'var(--radius-full)', objectFit: 'cover',
            border: '1px solid var(--primary-container)',
          }}/>
        <span className="kinetic-text" style={{
          fontFamily: 'var(--font-display)',
          fontWeight: 900, fontSize: 18, letterSpacing: '0.05em',
        }}>MITOOSA</span>
      </div>
      <CreditPill value="1,250"/>
    </header>
  );
}

function BottomNav({ active, setActive }) {
  const items = [
    { id: 'tracks',   label: 'Tracks',      icon: 'route' },
    { id: 'progress', label: 'Progress',    icon: 'insights' },
    { id: 'board',    label: 'Leaderboard', icon: 'leaderboard' },
    { id: 'settings', label: 'Settings',    icon: 'settings' },
  ];
  return (
    <nav style={{
      position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 50,
      padding: '10px 8px 20px',
      background: 'rgba(11,14,20,.7)',
      backdropFilter: 'blur(24px)', WebkitBackdropFilter: 'blur(24px)',
      borderTop: '1px solid rgba(255,255,255,.08)',
      borderTopLeftRadius: 20, borderTopRightRadius: 20,
      boxShadow: '0 -8px 30px rgba(0,0,0,.5)',
      display: 'flex', justifyContent: 'space-around', alignItems: 'center',
    }}>
      {items.map(it => {
        const on = active === it.id;
        return (
          <button key={it.id} onClick={() => setActive(it.id)}
            style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
              padding: on ? '6px 14px' : '6px 10px',
              borderRadius: 'var(--radius-lg)',
              background: on ? 'rgba(0,240,255,.10)' : 'transparent',
              border: on ? '1px solid rgba(0,240,255,.3)' : '1px solid transparent',
              cursor: 'pointer',
              transform: on ? 'scale(1.05)' : 'scale(1)',
              transition: 'all var(--dur-med) var(--ease-out)',
            }}>
            <MSym name={it.icon} size={20} fill={on ? 1 : 0}
              color={on ? 'var(--primary-container)' : 'var(--outline)'}/>
            <span style={{
              font: 'var(--t-label-sm)', fontSize: 10, letterSpacing: '.1em',
              color: on ? 'var(--primary-container)' : 'var(--outline)',
              textTransform: 'uppercase', fontWeight: 700,
              fontFamily: 'var(--font-body)',
            }}>{it.label}</span>
          </button>
        );
      })}
    </nav>
  );
}

function BackgroundAtmosphere() {
  // Deep obsidian with two distant gradient blooms.
  return (
    <>
      <div style={{
        position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 0,
        background: 'radial-gradient(circle at 20% 10%, rgba(112,0,255,.18) 0%, transparent 50%)',
      }}/>
      <div style={{
        position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 0,
        background: 'radial-gradient(circle at 80% 90%, rgba(0,240,255,.12) 0%, transparent 50%)',
      }}/>
    </>
  );
}

function Shell() {
  const [screen, setScreen] = useStateSh('tracks');
  const [gameTrack, setGameTrack] = useStateSh(null);
  const goToGame = (t) => { setGameTrack(t); setScreen('game'); };
  const goBack   = () => setScreen('tracks');
  const chrome = screen !== 'game';

  return (
    <div style={{
      position: 'relative',
      width: '100%', height: '100%',
      background: 'var(--surface)',
      color: 'var(--on-surface)',
      fontFamily: 'var(--font-body)',
      overflow: 'hidden',
    }}>
      <BackgroundAtmosphere/>
      {chrome && <TopBar/>}
      <div style={{
        position: 'relative', zIndex: 1,
        height: '100%', overflowY: 'auto', overflowX: 'hidden',
        paddingTop:    chrome ? 56 : 0,
        paddingBottom: chrome ? 72 : 0,
      }}>
        {screen === 'tracks'   && <TracksScreen   goToGame={goToGame}/>}
        {screen === 'progress' && <ProgressScreen/>}
        {screen === 'board'    && <LeaderboardScreen/>}
        {screen === 'settings' && <SettingsScreen/>}
        {screen === 'game'     && <GameScreen track={gameTrack} goBack={goBack}/>}
      </div>
      {chrome && <BottomNav active={screen} setActive={setScreen}/>}
    </div>
  );
}

Object.assign(window, { Shell });
