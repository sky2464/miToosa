// TracksScreen.jsx — Kinetic Obsidian "Daily Training" dashboard
// Matches uploads/screen.png: vertical stack with hero, small track cards,
// stats module, bottom nav. No horizontal scroll.

// Small icon-tile inside each track card — recessed surface with an inset shadow.
function TrackIconTile({ symbol, color = 'var(--secondary)', fill = 1 }) {
  return (
    <div style={{
      width: 48, height: 48,
      borderRadius: 'var(--radius-lg)',
      background: 'var(--surface-container-high)',
      border: '1px solid var(--outline-variant)',
      boxShadow: 'inset 0 2px 10px rgba(0,0,0,0.5)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0,
    }}>
      <MSym name={symbol} size={26} fill={fill} color={color}/>
    </div>
  );
}

// One compact track card. Icon-left, title, copy, level + Play on bottom row.
// Corner flair (faint Material icon in the top-right) echoes the reference.
function TrackCard({ track, onPlay }) {
  return (
    <Glass padding={20} radius={12} hover style={{ position: 'relative', overflow: 'hidden' }}>
      {/* corner accent */}
      <div style={{ position: 'absolute', top: 12, right: 14, opacity: 0.75 }}>
        <MSym name={track.accent} size={22} fill={1} color={track.accentColor}/>
      </div>

      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 14, marginBottom: 14 }}>
        <TrackIconTile symbol={track.tileSym} color={track.tileColor} fill={track.tileFill ?? 1}/>
      </div>

      <h3 style={{
        margin: 0,
        font: 'var(--t-h2)', letterSpacing: 'var(--ls-h2)',
        color: 'var(--on-surface)',
      }}>{track.name}</h3>
      <p style={{
        margin: '6px 0 16px 0',
        font: 'var(--t-body-md)', letterSpacing: 'var(--ls-body)',
        color: 'var(--on-surface-variant)',
      }}>{track.desc}</p>

      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        paddingTop: 12, borderTop: '1px solid rgba(255,255,255,.05)',
      }}>
        <span style={{
          font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
          color: 'var(--primary-container)', textTransform: 'uppercase', fontWeight: 500,
        }}>Level {track.level}</span>
        <button onClick={onPlay} style={{
          font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
          color: 'var(--on-surface)', textTransform: 'none', fontWeight: 500,
          background: 'rgba(255,255,255,.05)',
          border: '1px solid rgba(255,255,255,.10)',
          borderRadius: 'var(--radius)',
          padding: '6px 14px', cursor: 'pointer',
          fontFamily: 'var(--font-body)',
          transition: 'background var(--dur-fast)',
        }}>Play</button>
      </div>

      {/* animated underline — appears on hover via the parent Glass hover prop */}
    </Glass>
  );
}

// Statistics module — two labeled thin progress bars
function StatsCard() {
  return (
    <Glass padding={20} radius={12}>
      <h3 style={{
        margin: '0 0 18px 0',
        font: 'var(--t-h2)', letterSpacing: 'var(--ls-h2)',
        color: 'var(--on-surface)',
        display: 'flex', alignItems: 'center', gap: 8,
      }}>
        <MSym name="monitoring" size={22} color="var(--primary-container)"/>
        Stats
      </h3>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
        <ProgressBar pct={92} label="Accuracy" value="92%" height={3}/>
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
            <span style={{
              font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
              color: 'var(--on-surface-variant)',
            }}>Reaction Time</span>
            <span style={{
              font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
              color: 'var(--secondary-fixed-dim)',
            }}>0.8s</span>
          </div>
          <div style={{
            width: '100%', height: 3,
            background: 'var(--surface-container-high)',
            borderRadius: 'var(--radius-full)', overflow: 'hidden',
          }}>
            <div style={{
              height: '100%', width: '75%',
              background: 'var(--secondary-container)',
              borderRadius: 'var(--radius-full)',
            }}/>
          </div>
        </div>
      </div>
    </Glass>
  );
}

// Hero — Daily Training card. Copy + CTA top; progress ring below.
// Matches screenshot: copy stacked, then Start Sequence, then ring centered.
function DailyTrainingHero({ onStart }) {
  return (
    <Glass padding={24} radius={12} style={{
      position: 'relative', overflow: 'hidden',
      border: '1px solid var(--outline-variant)',
      borderTop: '1px solid rgba(255,255,255,.1)',
      borderLeft: '1px solid rgba(255,255,255,.1)',
    }}>
      {/* atmospheric gradient wash */}
      <div style={{
        position: 'absolute', inset: 0,
        background: 'linear-gradient(135deg, rgba(16,19,26,.3), rgba(50,53,60,.3))',
        pointerEvents: 'none',
      }}/>
      {/* proton glow bloom top-right */}
      <div style={{
        position: 'absolute', top: -60, right: -60, width: 220, height: 220,
        background: 'radial-gradient(circle, rgba(0,240,255,.25) 0%, transparent 70%)',
        filter: 'blur(40px)', pointerEvents: 'none',
      }}/>

      <div style={{ position: 'relative', zIndex: 1 }}>
        <h1 style={{
          margin: 0,
          font: 'var(--t-display)', fontSize: 40, lineHeight: 1.05,
          letterSpacing: 'var(--ls-display)',
          color: 'var(--primary)',
          fontWeight: 600,
        }}>Daily<br/>Training</h1>

        <p style={{
          margin: '14px 0 20px 0',
          font: 'var(--t-body-md)', letterSpacing: 'var(--ls-body)',
          color: 'var(--on-surface-variant)',
        }}>Complete your tasks to maintain your streak and earn bonus credits.</p>

        <PrimaryButton onClick={onStart}>Start Sequence</PrimaryButton>

        <div style={{ display: 'flex', justifyContent: 'center', marginTop: 28 }}>
          <ProgressRing pct={75} size={170} stroke={8}>
            <span style={{
              font: 'var(--t-h1)', letterSpacing: 'var(--ls-h1)',
              color: 'var(--primary)', fontWeight: 500,
            }}>75%</span>
            <span style={{
              font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
              color: 'var(--on-surface-variant)', textTransform: 'uppercase',
              marginTop: 2,
            }}>Goal</span>
          </ProgressRing>
        </div>
      </div>
    </Glass>
  );
}

function TracksScreen({ goToGame }) {
  const tracks = [
    {
      name: 'Pattern Match', level: 4,
      desc: 'Enhance cognitive speed by identifying complex sequences.',
      tileSym: 'category', tileColor: 'var(--secondary)', tileFill: 1,
      accent: 'extension', accentColor: 'var(--secondary-container)',
    },
    {
      name: 'Shape Counter', level: 2,
      desc: 'Test your spatial awareness and rapid calculation.',
      tileSym: 'token', tileColor: 'var(--primary-container)', tileFill: 1,
      accent: 'functions', accentColor: 'var(--primary-container)',
    },
    {
      name: 'Logic Chain', level: 3,
      desc: 'Route signals through gates to solve the circuit.',
      tileSym: 'hub', tileColor: 'var(--tertiary-fixed-dim)', tileFill: 1,
      accent: 'bolt', accentColor: 'var(--tertiary-fixed-dim)',
    },
    {
      name: 'Memory Grid', level: 1,
      desc: 'Recall tile positions before the grid resets.',
      tileSym: 'grid_view', tileColor: 'var(--secondary-fixed-dim)', tileFill: 1,
      accent: 'memory', accentColor: 'var(--secondary-fixed-dim)',
    },
  ];

  return (
    <div style={{
      display: 'flex', flexDirection: 'column', gap: 16,
      padding: '16px var(--space-gutter) 24px',
    }}>
      <DailyTrainingHero onStart={() => goToGame(tracks[0])}/>
      {tracks.map((t, i) => <TrackCard key={i} track={t} onPlay={() => goToGame(t)}/>)}
      <StatsCard/>
    </div>
  );
}

Object.assign(window, { TracksScreen });
