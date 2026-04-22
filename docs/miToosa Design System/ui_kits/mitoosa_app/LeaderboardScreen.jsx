// LeaderboardScreen.jsx — Kinetic Obsidian ranking list
function RankRow({ rank, avatar, name, score, you }) {
  const medal =
    rank === 1 ? 'linear-gradient(135deg, #00f0ff, #7df4ff)' :
    rank === 2 ? 'linear-gradient(135deg, #d1bcff, #e9ddff)' :
    rank === 3 ? 'linear-gradient(135deg, #ffb1c3, #ffccd6)' : null;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: you ? '12px 14px' : '12px 4px',
      borderRadius: 'var(--radius-lg)',
      background: you ? 'rgba(0,240,255,.08)' : 'transparent',
      border: you ? '1px solid rgba(0,240,255,.3)' : '1px solid transparent',
      boxShadow: you ? '0 0 16px rgba(0,240,255,.15)' : 'none',
    }}>
      <div style={{
        width: 30, height: 30, borderRadius: 'var(--radius-full)',
        background: medal || 'var(--surface-container-high)',
        color: medal ? '#00363a' : 'var(--on-surface-variant)',
        display: 'grid', placeItems: 'center',
        font: 'var(--t-label-lg)', letterSpacing: 'var(--ls-label-lg)',
        fontWeight: 700, fontSize: 13, flexShrink: 0,
      }}>{rank}</div>
      <img src={avatar} alt="" style={{
        width: 40, height: 40, borderRadius: 'var(--radius-full)',
        objectFit: 'cover',
        border: you ? '1px solid var(--primary-container)' : '1px solid var(--outline-variant)',
      }}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          font: 'var(--t-label-lg)', letterSpacing: 'var(--ls-label-lg)',
          color: 'var(--on-surface)', textTransform: 'none', fontWeight: 500,
        }}>{name}{you && <span style={{ color: 'var(--primary-container)', marginLeft: 6 }}>· YOU</span>}</div>
        <div style={{
          font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
          color: 'var(--on-surface-variant)',
        }}>{score.toLocaleString()} XP</div>
      </div>
      <MSym name="military_tech" size={20} fill={1}
        color={rank <= 3 ? 'var(--primary-container)' : 'var(--outline)'}/>
    </div>
  );
}

const AV = (n) => `../../assets/avatars/avatar_${n}.png`;

function LeaderboardScreen() {
  const rows = [
    { rank: 1, name: 'Mira K.',    score: 24820, avatar: AV(1) },
    { rank: 2, name: 'Diego R.',   score: 22110, avatar: AV(2) },
    { rank: 3, name: 'Aiko T.',    score: 19500, avatar: AV(3) },
    { rank: 4, name: 'Pilot_042',  score: 12480, avatar: AV(4), you: true },
    { rank: 5, name: 'Priya S.',   score: 11230, avatar: AV(5) },
    { rank: 6, name: 'Jordan L.',  score: 10870, avatar: AV(6) },
    { rank: 7, name: 'Sam O.',     score:  9420, avatar: AV(7) },
  ];
  return (
    <div style={{
      display: 'flex', flexDirection: 'column', gap: 16,
      padding: '16px var(--space-gutter) 24px',
    }}>
      {/* Header */}
      <Glass padding={20} radius={12} style={{ position: 'relative', overflow: 'hidden' }}>
        <div style={{
          position: 'absolute', inset: 0,
          background: 'radial-gradient(ellipse at top right, rgba(112,0,255,.15), transparent 60%)',
          pointerEvents: 'none',
        }}/>
        <div style={{ position: 'relative' }}>
          <div style={{
            font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
            color: 'var(--primary-container)', textTransform: 'uppercase',
          }}>Weekly · Global</div>
          <h1 style={{
            margin: '4px 0 0 0',
            font: 'var(--t-h1)', letterSpacing: 'var(--ls-h1)',
            color: 'var(--primary)',
          }}>Leaderboard</h1>
        </div>
      </Glass>

      {/* Filter tabs */}
      <div style={{ display: 'flex', gap: 8 }}>
        {['Global', 'Friends', 'Local'].map((t, i) => {
          const on = i === 0;
          return (
            <button key={t} style={{
              flex: 1,
              padding: '10px 0',
              borderRadius: 'var(--radius-lg)',
              background: on ? 'var(--grad-kinetic)' : 'rgba(29,32,38,.5)',
              border: on ? 'none' : '1px solid var(--outline-variant)',
              font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
              color: on ? 'var(--on-primary, #00363a)' : 'var(--on-surface-variant)',
              textTransform: 'uppercase', fontWeight: 600,
              fontFamily: 'var(--font-body)',
              cursor: 'pointer',
              boxShadow: on ? 'var(--shadow-neon-soft)' : 'none',
            }}>{t}</button>
          );
        })}
      </div>

      {/* List */}
      <Glass padding={14} radius={12}>
        {rows.map((r, i) => (
          <React.Fragment key={r.rank}>
            <RankRow {...r}/>
            {i < rows.length - 1 && <div style={{ height: 1, background: 'rgba(255,255,255,.04)', margin: '2px 0' }}/>}
          </React.Fragment>
        ))}
      </Glass>
    </div>
  );
}

Object.assign(window, { LeaderboardScreen });
