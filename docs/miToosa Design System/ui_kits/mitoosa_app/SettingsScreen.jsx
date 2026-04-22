// SettingsScreen.jsx — Kinetic Obsidian
const { useState: useStateS } = React;

function Toggle({ on, onChange }) {
  return (
    <div onClick={() => onChange(!on)} style={{
      width: 46, height: 26, padding: 3,
      borderRadius: 'var(--radius-full)',
      cursor: 'pointer',
      background: on ? 'var(--grad-kinetic)' : 'var(--surface-container-high)',
      border: `1px solid ${on ? 'rgba(0,240,255,.5)' : 'var(--outline-variant)'}`,
      boxShadow: on ? '0 0 12px rgba(0,240,255,.4)' : 'none',
      transition: 'all var(--dur-med) var(--ease-out)',
      display: 'flex', alignItems: 'center',
    }}>
      <div style={{
        width: 18, height: 18, borderRadius: 'var(--radius-full)',
        background: 'var(--on-surface)',
        transform: on ? 'translateX(20px)' : 'translateX(0)',
        transition: 'transform var(--dur-med) var(--ease-snappy)',
      }}/>
    </div>
  );
}

function SettingRow({ icon, title, sub, right, last = false }) {
  return (
    <>
      <div style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '14px 2px' }}>
        <div style={{
          width: 36, height: 36,
          borderRadius: 'var(--radius-lg)',
          background: 'var(--surface-container-high)',
          border: '1px solid var(--outline-variant)',
          display: 'grid', placeItems: 'center',
          flexShrink: 0,
        }}>
          <MSym name={icon} size={20} color="var(--primary-container)"/>
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{
            font: 'var(--t-label-lg)', letterSpacing: 'var(--ls-label-lg)',
            color: 'var(--on-surface)', textTransform: 'none', fontWeight: 500,
          }}>{title}</div>
          {sub && <div style={{
            font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
            color: 'var(--on-surface-variant)', textTransform: 'none', marginTop: 2,
          }}>{sub}</div>}
        </div>
        {right}
      </div>
      {!last && <div style={{ height: 1, background: 'rgba(255,255,255,.04)' }}/>}
    </>
  );
}

function SettingsScreen() {
  const [sfx, setSfx] = useStateS(true);
  const [push, setPush] = useStateS(true);
  const [haptics, setHaptics] = useStateS(false);
  return (
    <div style={{
      display: 'flex', flexDirection: 'column', gap: 16,
      padding: '16px var(--space-gutter) 24px',
    }}>
      <h1 style={{
        margin: '8px 0 4px 0',
        font: 'var(--t-h1)', letterSpacing: 'var(--ls-h1)',
        color: 'var(--primary)',
      }}>Settings</h1>

      {/* Profile */}
      <Glass padding={18} radius={12} style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
        <img src="../../assets/avatars/avatar_4.png" alt=""
          style={{
            width: 56, height: 56, borderRadius: 'var(--radius-full)', objectFit: 'cover',
            border: '1px solid var(--primary-container)',
            boxShadow: '0 0 14px rgba(0,240,255,.35)',
          }}/>
        <div style={{ flex: 1 }}>
          <div style={{
            font: 'var(--t-label-lg)', letterSpacing: 'var(--ls-label-lg)',
            color: 'var(--on-surface)', textTransform: 'uppercase', fontWeight: 600,
          }}>Pilot_042</div>
          <div style={{
            font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
            color: 'var(--on-surface-variant)', marginTop: 2,
          }}>Level 08 · 1,250 CR</div>
        </div>
        <MSym name="chevron_right" size={22} color="var(--on-surface-variant)"/>
      </Glass>

      {/* Account */}
      <div>
        <div style={{
          padding: '0 4px 8px',
          font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
          color: 'var(--on-surface-variant)', textTransform: 'uppercase',
        }}>Account</div>
        <Glass padding="2px 16px" radius={12}>
          <SettingRow icon="share" title="Share miToosa" sub="+40 sessions per invite"
            right={<MSym name="chevron_right" size={22} color="var(--on-surface-variant)"/>}/>
          <SettingRow icon="workspace_premium" title="Go VIP" sub="Ad-free + 10 bonus sessions / day"
            right={<Chip tone="purple">Upgrade</Chip>} last/>
        </Glass>
      </div>

      {/* Preferences */}
      <div>
        <div style={{
          padding: '0 4px 8px',
          font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
          color: 'var(--on-surface-variant)', textTransform: 'uppercase',
        }}>System</div>
        <Glass padding="2px 16px" radius={12}>
          <SettingRow icon="volume_up" title="Sound FX"
            right={<Toggle on={sfx} onChange={setSfx}/>}/>
          <SettingRow icon="notifications" title="Daily reminder" sub="Nudges if your streak is at risk"
            right={<Toggle on={push} onChange={setPush}/>}/>
          <SettingRow icon="vibration" title="Haptics"
            right={<Toggle on={haptics} onChange={setHaptics}/>} last/>
        </Glass>
      </div>

      {/* Danger */}
      <Glass padding="2px 16px" radius={12}>
        <SettingRow icon="restart_alt" title="Reset progress" sub="Clear all credits & stats"
          right={<MSym name="chevron_right" size={22} color="var(--on-surface-variant)"/>} last/>
      </Glass>

      <div style={{
        textAlign: 'center', marginTop: 8,
        font: 'var(--t-label-sm)', letterSpacing: 'var(--ls-label-sm)',
        color: 'var(--outline)', textTransform: 'uppercase',
      }}>miToosa · v1.2.0</div>
    </div>
  );
}

Object.assign(window, { SettingsScreen });
