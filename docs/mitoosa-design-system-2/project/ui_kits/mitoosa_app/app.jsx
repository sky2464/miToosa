// App orchestrator

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "accent": "blue-purple",
  "density": "comfortable",
  "atmosphere": "lively",
  "glass": "standard"
}/*EDITMODE-END*/;

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const [tab, setTab] = React.useState('tracks');
  const [inGame, setInGame] = React.useState(false);

  const screen = inGame ? (
    <GameScreen onExit={() => setInGame(false)} />
  ) : tab === 'tracks'   ? <TracksScreen onPlay={() => setInGame(true)} />
    : tab === 'path'     ? <PathScreen />
    : tab === 'progress' ? <ProgressScreen />
    : tab === 'leaders'  ? <LeaderboardScreen />
                         : <SettingsScreen />;

  // Apply accent tweak by overriding root CSS variables
  React.useEffect(() => {
    const root = document.documentElement;
    const palettes = {
      'blue-purple': { grad:'linear-gradient(135deg, #3b82f6 0%, #a855f7 100%)', accent:'#60a5fa' },
      'cyan-magenta': { grad:'linear-gradient(135deg, #22d3ee 0%, #ec4899 100%)', accent:'#22d3ee' },
      'amber-pink':  { grad:'linear-gradient(135deg, #facc15 0%, #ec4899 100%)', accent:'#facc15' },
    };
    const p = palettes[t.accent] || palettes['blue-purple'];
    root.style.setProperty('--grad-primary', p.grad);
  }, [t.accent]);

  return (
    <>
      <IOSDevice dark={true}>
        <div style={{ position:'relative', width:'100%', height:'100%',
          background:'linear-gradient(180deg, #0a0d17 0%, #060810 100%)',
          overflow:'hidden' }}>
          <div className="app-scroll" style={{ position:'absolute', inset:0, overflowY:'auto', overflowX:'hidden' }}>
          <div key={tab + (inGame?'-game':'')} className="screen-in">
            {screen}
          </div>
          </div>
          {!inGame && <BottomNav value={tab} onChange={setTab} />}
        </div>
      </IOSDevice>

      <TweaksPanel>
        <TweakSection label="Visuals" />
        <TweakColor label="Accent palette"
          value={t.accent === 'blue-purple' ? ['#3b82f6','#a855f7']
               : t.accent === 'cyan-magenta' ? ['#22d3ee','#ec4899']
               : ['#facc15','#ec4899']}
          options={[['#3b82f6','#a855f7'], ['#22d3ee','#ec4899'], ['#facc15','#ec4899']]}
          onChange={(v) => {
            const name = v[0] === '#3b82f6' ? 'blue-purple' : v[0] === '#22d3ee' ? 'cyan-magenta' : 'amber-pink';
            setTweak('accent', name);
          }} />
        <TweakRadio label="Atmosphere" value={t.atmosphere}
          options={['calm','lively']} onChange={(v) => setTweak('atmosphere', v)} />
        <TweakRadio label="Glass" value={t.glass}
          options={['subtle','standard','heavy']} onChange={(v) => setTweak('glass', v)} />
        <TweakRadio label="Density" value={t.density}
          options={['compact','comfortable']} onChange={(v) => setTweak('density', v)} />
        <TweakSection label="Quick jump" />
        <TweakButton onClick={() => { setInGame(false); setTab('tracks'); }}>Tracks</TweakButton>
        <TweakButton onClick={() => { setInGame(false); setTab('path'); }}>Path</TweakButton>
        <TweakButton onClick={() => { setInGame(false); setTab('progress'); }}>Progress</TweakButton>
        <TweakButton onClick={() => { setInGame(false); setTab('leaders'); }}>Leaderboard</TweakButton>
        <TweakButton onClick={() => { setInGame(false); setTab('settings'); }}>Settings</TweakButton>
        <TweakButton onClick={() => setInGame(true)}>Open game screen</TweakButton>
      </TweaksPanel>

      <style>{`
        @keyframes screen-in {
          from { opacity: 0; transform: translateY(8px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .screen-in { animation: screen-in .35s var(--e-out) both; }
        /* Glass tweak */
        ${t.glass === 'subtle' ? `.glass, [class*="GlassCard"] { backdrop-filter: blur(12px) !important; -webkit-backdrop-filter: blur(12px) !important; }` : ''}
        ${t.glass === 'heavy'  ? `.glass, [class*="GlassCard"] { backdrop-filter: blur(36px) saturate(140%) !important; -webkit-backdrop-filter: blur(36px) saturate(140%) !important; }` : ''}
        ${t.atmosphere === 'calm' ? `[aria-hidden] { animation: none !important; }` : ''}
      `}</style>
    </>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
