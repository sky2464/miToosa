# Spec: LP-01 — Local Network QR Play (deferred POC)

> **Story ID:** LP-01
> **Epic:** EP-05 Technical Debt & Infrastructure
> **Status:** ⬜ Backlog (deferred POC — not v1.5.1 launch scope)
> **Estimate:** L
> **Clarity:** ready (legacy draft)
> **Spec created:** 2026-04-22
> **Legacy filename:** `spec-local-network-qr-play-v1.md`

---

## 1. Overview

Enable players to play miToosa on Android phones (and other devices) on the same home network by:
1. One device (host) generates a QR code containing connection info (IP, port, session ID)
2. Another device (guest) scans the QR code via camera
3. Guest connects to host's local WebSocket server
4. Both devices sync gameplay state in real-time
5. Scores are tallied and displayed

---

## 2. User Stories

### 2.1 Host Device (Initiates Local Play)
**As a** player on Device A  
**I want to** start a "local network play" session  
**So that** friends or family on the same WiFi can join and play together

**Acceptance Criteria**:
- [ ] Player can select "Play Locally" from main menu
- [ ] Device A generates a unique session ID (UUIDv4)
- [ ] Device A detects its local IP address on the home network
- [ ] Device A starts a WebSocket server on a free port (e.g., 8765)
- [ ] Device A displays a QR code encoding: `ws://192.168.1.X:8765?session=<UUID>&playerId=<UUID>`
- [ ] Device A shows "Waiting for players... Tap to start anyway" UI
- [ ] Player can configure difficulty tier before starting

### 2.2 Guest Device (Joins Via QR)
**As a** player on Device B  
**I want to** scan a QR code from Device A  
**So that** I can join a local play session

**Acceptance Criteria**:
- [ ] Player can select "Join Local Game" from main menu
- [ ] Camera permission is requested and handled gracefully
- [ ] Player can scan QR code via native camera or in-app scanner
- [ ] Device B parses the QR code and extracts connection info
- [ ] Device B connects to the WebSocket server at the decoded address
- [ ] Device B validates the session ID matches the host
- [ ] Connection success shows "Connected to Player ABC" confirmation
- [ ] Connection failure shows retry option with error reason

### 2.3 Shared Game Session
**As** both players  
**I want to** see the same puzzle/options in real-time  
**So that** we can play competitively or cooperatively

**Acceptance Criteria**:
- [ ] Host player starts a round → level loads on both devices
- [ ] Options (4 shapes) are identical on both devices
- [ ] When host selects an option, guest sees the selection within 100ms
- [ ] Correct/incorrect feedback is synchronized
- [ ] Timer counts down identically on both devices (within 50ms tolerance)
- [ ] After each round, scores are aggregated and displayed
- [ ] Either player can end the session; other is notified and returns to main menu
- [ ] If connection drops, both players see "Disconnected" message with reconnect option

### 2.4 Scoring & Leaderboard
**As** players in a local session  
**I want to** see who scored more points  
**So that** we can compete fairly

**Acceptance Criteria**:
- [ ] Each player's score is tracked independently (XP, coins, stars awarded)
- [ ] After each level, scores are displayed side-by-side
- [ ] Session summary shows cumulative points and winner
- [ ] Each player's progress is saved locally to their Hive box
- [ ] Streaks are NOT affected by local network play (single-player streaks only)

---

## 3. Technical Architecture

### 3.1 Network Protocol

**WebSocket Message Format** (JSON):
```json
{
  "type": "move_selected",
  "playerId": "uuid-v4",
  "sessionId": "uuid-v4",
  "timestamp": 1713787200000,
  "payload": {
    "levelId": 42,
    "optionIndex": 2,
    "isCorrect": true,
    "stars": 3,
    "xpGained": 150
  }
}
```

**Server-initiated Messages**:
- `game_start` → Sent to all connected clients; triggers level load
- `timer_tick` → Sent every 100ms with remaining time (prevents clock drift)
- `player_connected` → Sent to all clients when a new player joins
- `player_disconnected` → Sent to all clients when a player leaves
- `session_ended` → Sent by host when ending the session

**Client-initiated Messages**:
- `join_session` → Initial handshake with playerId + sessionId
- `move_selected` → Player selected an option
- `request_sync` → Client asks for current game state (resync)

### 3.2 File Structure

```
lib/
├── data/
│   ├── network/
│   │   ├── local_network_server.dart         # WebSocket server (host)
│   │   ├── local_network_client.dart         # WebSocket client (guest)
│   │   ├── network_models.dart               # JSON-serializable messages
│   │   └── network_exceptions.dart           # Errors (ConnectionFailed, etc.)
│   └── local_session_provider.dart           # Riverpod StateNotifier for session state
├── features/
│   └── local_play/
│       ├── local_play_router.dart            # Navigation for local play flows
│       ├── qr_host_screen.dart               # Display QR code (host device)
│       ├── qr_scanner_screen.dart            # Scan QR code (guest device)
│       ├── local_session_screen.dart         # During-play sync screen
│       └── local_session_view_model.dart     # Local session game state
└── core/
    └── network/
        └── local_network_info.dart           # Detect local IP, free ports
test/
├── data/
│   └── network/
│       ├── local_network_server_test.dart
│       ├── local_network_client_test.dart
│       └── network_models_test.dart
```

### 3.3 State Flow (Riverpod)

**Host Flow**:
1. `localSessionProvider` initialized with mode=host, sessionId=UUIDv4, playerId=currentUser
2. `LocalNetworkServer.start()` → listens on 0.0.0.0:8765
3. QR code generated from `ws://[local_ip]:8765?session=[sessionId]&playerId=[playerId]`
4. When guest joins → `localSessionProvider` state updated with connected peers
5. Host starts level → `gameplayViewModel` ticks, each move emitted as network message
6. Guest receives move → syncs into their `gameplayViewModel`

**Guest Flow**:
1. Scan QR code → extract connection URL
2. `localSessionProvider` initialized with mode=guest, sessionId=decoded, hostUrl=decoded
3. `LocalNetworkClient.connect()` → establishes WebSocket
4. On connection success → join session message sent
5. Host acknowledges → level loads on guest
6. Guest's game state kept in sync via incoming network messages

### 3.4 Dependencies to Add

```yaml
# pubspec.yaml

dependencies:
  qr_flutter: ^4.1.0                # QR code generation & display
  web_socket_channel: ^2.4.0        # WebSocket client/server
  network_info_plus: ^5.0.0         # Detect local IP address
  barcode_scan2: ^4.3.0             # Optional: better QR scanner
  camera: ^0.10.0                   # Optional: native camera integration
```

---

## 4. Phase 1 Scope (MVP)

### In Scope
- [ ] QR code generation on host
- [ ] QR code scanning on guest (using native platform APIs or simple library)
- [ ] WebSocket connection between host and guest
- [ ] Move synchronization (host's selections appear on guest)
- [ ] Score tracking per player
- [ ] Session end and disconnect handling
- [ ] Basic error handling (connection timeout, invalid QR)

### Out of Scope (Phase 2+)
- [ ] Competitive scoring modes (first-to-answer, fastest time)
- [ ] Turn-based multiplayer (one player plays, other guesses)
- [ ] Multiple guests connecting to one host (>2 players)
- [ ] Persistent session history
- [ ] Relay server for cross-network play (outside home WiFi)
- [ ] Voice/video chat
- [ ] Achievements specific to multiplayer

---

## 5. Acceptance Criteria Checklist

### 5.1 Functional
- [ ] Host can start a local play session and display QR code
- [ ] Guest can scan QR code and connect to host
- [ ] Both devices run the same level in sync
- [ ] Player selections are synchronized within 100ms
- [ ] Scores are calculated and displayed for each player
- [ ] Session can be ended gracefully
- [ ] Connection drop is handled without crash

### 5.2 Non-Functional
- [ ] All network code has unit tests
- [ ] Network messages are < 1KB (efficient)
- [ ] Connection latency < 100ms on typical home WiFi
- [ ] No leaks: session cleanup on exit/disconnect
- [ ] Deterministic gameplay (no race conditions)
- [ ] No crash on rapid disconnects/reconnects

### 5.3 Security & Privacy
- [ ] Session ID is not logged or stored
- [ ] QR code is only valid for 5 minutes (expires)
- [ ] No sensitive player data in QR (only session + player ID)
- [ ] WebSocket server only binds to local interface (not 0.0.0.0 exposed to internet)
- [ ] Validates incoming messages (type checks, bounds)

### 5.4 UX
- [ ] Clear "Play Locally" vs "Solo" vs "Online" modes in menu
- [ ] QR display is large and scannable (min 2x2 inches at arm's length)
- [ ] Scanning feedback is clear ("Scanning...", "Invalid QR", "Connecting...")
- [ ] Waiting for players shows as non-blocking state
- [ ] Disconnection message is user-friendly with retry

---

## 6. Edge Cases & Error Handling

| Scenario | Expected Behavior |
|----------|-------------------|
| Guest closes app mid-session | Host shows "Player disconnected" and waits for new connection or times out after 30s |
| Host closes app | Guest shows "Host disconnected, session ended" and returns to main menu |
| QR code expires (>5 min old) | New QR displayed on host; guest's attempt to connect is rejected |
| Network goes offline mid-game | Both show "Connection lost" message; retry available |
| Invalid QR scanned | Guest shown "Invalid session QR" error with back option |
| Port 8765 already in use | Server tries ports 8765–8775; if all busy, user shown error |
| Two players with same UUID (collision) | Reject with error; regenerate UUID and restart session |

---

## 7. Testing Strategy

### 7.1 Unit Tests
- `LocalNetworkServer`: Start/stop, handle connections, broadcast messages
- `LocalNetworkClient`: Connect, parse messages, emit events
- `NetworkModels`: JSON serialization/deserialization
- `LocalNetworkInfo`: IP detection, port availability

### 7.2 Integration Tests
- Host starts session → guest connects → level loads → move synced → session ends
- Rapid connect/disconnect cycles
- Message ordering under latency
- Hive persistence: scores saved after local session

### 7.3 Manual QA
- Test on real Android devices on home WiFi
- Test on iOS (if adding iOS support)
- Test on macOS/Web clients
- Verify QR scanner reliability with various lighting conditions

---

## 8. Success Metrics

- [ ] Feature is testable with >90% network code coverage
- [ ] Can run a 5-minute local play session without crashes
- [ ] QR code is scannable on first try in normal lighting
- [ ] Sync latency is < 100ms on typical home network
- [ ] User can complete onboarding ("Tap Join → Scan → Play") in <30 seconds
- [ ] No data loss: scores are persisted and accurate

---

## 9. Future Enhancements (Phase 2+)

1. **Multiplayer Modes**:
   - Competitive: Players race to complete levels first
   - Cooperative: Players must agree on answer before submitting
   - Turn-based: Players take turns, highest score wins

2. **Relay Server**:
   - Central server for cross-WiFi connections
   - Permanent friend lists and session history

3. **Mobile Platform Optimizations**:
   - Better camera integration
   - Vibration feedback on sync events
   - Battery optimization for long sessions

4. **Analytics**:
   - Track multiplayer session duration, drop rates, player retention

---

## 10. Questions for Product

- Should streaks be earned in local play, or only solo?
- Should local play XP count toward daily allowance (25 free games)?
- Should there be a limit on session duration to prevent abuse?
- Should we track "multiplayer sessions" as a metric for retention?
