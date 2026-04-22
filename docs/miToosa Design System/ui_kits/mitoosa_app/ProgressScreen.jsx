// ProgressScreen.jsx — XP hero, stat grid, achievements, cognitive skills
// Kinetic Obsidian. Vertical stack, mobile-first.

function StatTile({ symbol, value, label, color = 'var(--primary-container)', symFill = 1 }) {
  return (
    <Glass padding={18} radius={12} style={{ flex: 1, minWidth: 0 }}>
      <div style={{
        width: 40, height: 40,
        borderRadius: 'var(--radius-lg)',
        background: 'var(--surface-container-high)',
        border: '1px solid var(--outline-variant)',
        boxShadow: 'inset 0 2px 8px rgba(0,0,0,.5)',
        display: 'grid', placeItems: 'center', marginBottom: 12,
      }}>
        <MSym name={symbol} size={22} fill={symFill} color={color}/>
      </div>
      <div style={{
        font: 'var(--t-h2)', fontSize: 22, lineHeight: 1,
        letterSpacing: 'var(--ls-h2)',
        color: 'var(--on-surface)',
      }}>{value}</div>
      <div style={{
        marginTop: 6,
        font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
        color: 'var(--on-surface-variant)', textTransform: 'uppercase',
      }}>{label}</div>
    </Glass>
  );
}

function AchievementRow({ img, title, sub, unlocked }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '12px 0' }}>
      <img src={img} alt="" style={{
        width: 48, height: 48, objectFit: 'contain',
        filter: unlocked ? 'drop-shadow(0 0 10px rgba(0,240,255,.4))' : 'grayscale(1) opacity(.35)',
      }}/>
      <div style={{ flex: 1 }}>
        <div style={{
          font: 'var(--t-label-lg)', letterSpacing: 'var(--ls-label-lg)',
          color: 'var(--on-surface)', textTransform: 'uppercase', fontWeight: 500,
        }}>{title}</div>
        <div style={{
          font: 'var(--t-body-md)', fontSize: 13,
          color: 'var(--on-surface-variant)',
          letterSpacing: 'var(--ls-body)', marginTop: 2,
        }}>{sub}</div>
      </div>
      {unlocked
        ? <Chip tone="primary">Unlocked</Chip>
        : <MSym name="lock" size={18} color="var(--outline)"/>}
    </div>
  );
}

function SkillBar({ name, pct, value }) {
  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
        <span style={{
          font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
          color: 'var(--on-surface-variant)', textTransform: 'uppercase',
        }}>{name}</span>
        <span style={{
          font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
          color: 'var(--primary-container)',
        }}>{value}</span>
      </div>
      <ProgressBar pct={pct} height={3}/>
    </div>
  );
}

function ProgressScreen() {
  return (
    <div style={{
      display: 'flex', flexDirection: 'column', gap: 16,
      padding: '16px var(--space-gutter) 24px',
    }}>
      {/* Total XP hero */}
      <Glass padding={24} radius={12} style={{ position: 'relative', overflow: 'hidden' }}>
        <div style={{
          position: 'absolute', top: -40, right: -40, width: 180, height: 180,
          background: 'radial-gradient(circle, rgba(112,0,255,.25) 0%, transparent 70%)',
          filter: 'blur(30px)', pointerEvents: 'none',
        }}/>
        <div style={{ position: 'relative' }}>
          <div style={{
            font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
            color: 'var(--on-surface-variant)', textTransform: 'uppercase', marginBottom: 6,
          }}>Total XP</div>
          <div className="kinetic-text" style={{
            font: 'var(--t-display)', fontSize: 44, lineHeight: 1,
            letterSpacing: 'var(--ls-display)', fontWeight: 600,
            marginBottom: 16,
          }}>12,480</div>
          <ProgressBar pct={64} label="Level 08 · Next" value="64%" height={4}/>
        </div>
      </Glass>

      {/* Stat grid */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        <StatTile symbol="local_fire_department" value="7"  label="Day Streak"
                  color="#ffb4ab"/>
        <StatTile symbol="military_tech" value="42" label="Stars"
                  color="var(--primary-container)"/>
        <StatTile symbol="diamond" value="250" label="Credits"
                  color="var(--primary-fixed-dim)"/>
        <StatTile symbol="bolt" value="10" label="Energy"
                  color="var(--secondary-fixed-dim)"/>
      </div>

      {/* Cognitive skills breakdown */}
      <Glass padding={20} radius={12}>
        <h3 style={{
          margin: '0 0 16px 0',
          font: 'var(--t-h2)', letterSpacing: 'var(--ls-h2)',
          color: 'var(--on-surface)',
          display: 'flex', alignItems: 'center', gap: 8,
        }}>
          <MSym name="psychology" size={22} color="var(--primary-container)"/>
          Cognitive Skills
        </h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <SkillBar name="Pattern Recognition" pct={82} value="82"/>
          <SkillBar name="Working Memory"      pct={64} value="64"/>
          <SkillBar name="Logical Reasoning"   pct={71} value="71"/>
          <SkillBar name="Reaction Speed"      pct={88} value="88"/>
        </div>
      </Glass>

      {/* Achievements */}
      <Glass padding={20} radius={12}>
        <h3 style={{
          margin: '0 0 8px 0',
          font: 'var(--t-h2)', letterSpacing: 'var(--ls-h2)',
          color: 'var(--on-surface)',
        }}>Achievements</h3>
        <AchievementRow img="../../assets/badges/novice_mind.png"
          title="Novice Mind" sub="Complete your first puzzle" unlocked/>
        <div style={{ height: 1, background: 'rgba(255,255,255,.05)' }}/>
        <AchievementRow img="../../assets/badges/daily_spark.png"
          title="Daily Spark" sub="Play 7 days in a row" unlocked/>
        <div style={{ height: 1, background: 'rgba(255,255,255,.05)' }}/>
        <AchievementRow img="../../assets/badges/focus_master.png"
          title="Focus Master" sub="Earn 25 stars — 4 more to go" unlocked={false}/>
      </Glass>
    </div>
  );
}

Object.assign(window, { ProgressScreen });
