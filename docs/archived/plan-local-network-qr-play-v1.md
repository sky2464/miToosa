# Plan: Local Network QR Code Play — Incremental Implementation

**Status**: Complete  
**Version**: 1.0  
**Date**: April 22, 2026  
**Based on**: `docs/archived/spec-LP-01.md`

---

## Phases & Increments

### Phase 1: Foundation (Network Infrastructure)

#### Increment 1.1: Add Dependencies & Network Models
**Goal**: Establish the data contracts for network communication  
**Est. Time**: 1–2 hours

Tasks:
1. [x] Add to `pubspec.yaml`:
   - `qr_flutter: ^4.1.0` (QR code generation)
   - `web_socket_channel: ^2.4.0` (WebSocket)
   - `network_info_plus: ^5.0.0` (Local IP detection)
2. [x] Create `lib/data/network/network_models.dart`:
   - `NetworkMessage` (sealed union: MovedSelected, GameStart, TimerTick, PlayerConnected, etc.)
   - `LocalPlaySession` (session metadata: id, mode, hostId, guestId, startedAt)
   - `PlayerScore` (playerId, xp, coins, stars)
   - JSON serialization via `toJson()` / `fromJson()`
3. [x] Create `lib/data/network/network_exceptions.dart`:
   - `ConnectionFailedException`
   - `InvalidQRException`
   - `SessionExpiredException`
   - `NetworkTimeoutException`
4. [x] Create `lib/core/network/local_network_info.dart`:
   - `getLocalIP()` → detects 192.168.x.x on home network
   - `isPortAvailable(port)` → checks if port is free
   - `findAvailablePort(start=8765, end=8775)` → finds first free port

**Tests**:
- [x] Unit: `network_models_test.dart` → JSON round-trip serialization
- [x] Unit: `local_network_info_test.dart` → mock IP detection

**Verification**:
- [x] `dart analyze` passes
- [x] `flutter test test/data/network/` passes
- [x] `flutter pub get` succeeds with no version conflicts

**Commit**: `feat(network): add network models and local IP detection`

---

#### Increment 1.2: WebSocket Server (Host)
**Goal**: Host device can accept connections from guests  
**Est. Time**: 2–3 hours

Tasks:
1. [x] Create `lib/data/network/local_network_server.dart`:
   - Class `LocalNetworkServer` with lifecycle:
     - `start(port, sessionId, onMessageReceived)` → binds to 0.0.0.0:port
     - `broadcast(message)` → sends to all connected clients
     - `stop()` → graceful shutdown, closes all connections
   - Handle:
     - New client connections (send welcome message with sessionId)
     - Incoming messages (parse JSON, emit event)
     - Client disconnections (cleanup, notify other clients)
     - Errors (log, don't crash)
   - Limit to 2 clients (host + 1 guest) for Phase 1
   
2. [x] Implement connection validation:
   - First message from client must be `join_session` with matching sessionId
   - Reject invalid session IDs with error message
   - Enforce 30-second handshake timeout

**Tests**:
- [x] Unit: `local_network_server_test.dart`:
  - Start server on free port ✓
  - Client connects → receive welcome message ✓
  - Invalid session ID rejected ✓
  - Broadcast to connected clients ✓
  - Client disconnect → cleanup ✓
  - Stop server → no more connections accepted ✓
  - Timeout after 30s no handshake ✓

**Verification**:
- [x] `flutter test test/data/network/local_network_server_test.dart` passes
- [x] No memory leaks (connections properly closed)
- [x] Server binds to 127.0.0.1 in tests (not exposed)

**Commit**: `feat(network): implement WebSocket server for host`

---

#### Increment 1.3: WebSocket Client (Guest)
**Goal**: Guest device can connect to host server  
**Est. Time**: 1.5–2 hours

Tasks:
1. [x] Create `lib/data/network/local_network_client.dart`:
   - Class `LocalNetworkClient` with lifecycle:
     - `connect(url, playerId, sessionId)` → connects to ws://host:port
     - `send(message)` → sends JSON to server
     - `disconnect()` → graceful close
     - Stream of incoming messages (for Riverpod integration)
   - Implement reconnect logic:
     - Exponential backoff (1s, 2s, 4s, 8s, max 30s)
     - Max 5 retries before giving up
     - Emit events: connecting, connected, disconnected, error

2. [x] Parse QR code URL format:
   - Extract: `scheme://host:port?session=xxx&playerId=yyy`
   - Validate format before connecting

**Tests**:
- [x] Unit: `local_network_client_test.dart`:
  - Connect to server ✓
  - Send message → receive echo ✓
  - Disconnect ✓
  - Reconnect after brief disconnect ✓
  - Reject after max retries ✓
  - Parse valid QR URL ✓
  - Reject invalid QR URL ✓

**Verification**:
- [x] `flutter test test/data/network/local_network_client_test.dart` passes
- [x] Works with `local_network_server_test.dart` server
- [x] Reconnection backoff works correctly

**Commit**: `feat(network): implement WebSocket client for guest`

---

### Phase 2: Riverpod Integration

#### Increment 2.1: Local Session Provider
**Goal**: Riverpod StateNotifier manages local play session state  
**Est. Time**: 2–3 hours

Tasks:
1. [x] Create `lib/data/local_session_provider.dart`:
   - `LocalSessionState` (sealed enum):
     - `idle` (no session)
     - `hosting(sessionId, qrDataUri, connectedPlayers)` (host waiting for guests)
     - `playing(sessionId, localScore, remoteScore, syncedGameplayState)`
     - `error(message)`
   - `localSessionProvider` → StateNotifier<LocalSessionState>
   - Methods:
     - `startHosting()` → initializes server, generates QR, updates state
     - `joinSession(qrUrl)` → connects as guest, updates state
     - `onRemoteMove(move)` → updates sync state when guest sends move
     - `endSession()` → stops server/client, returns to idle
     - `resetError()` → clears error state

2. [x] Wire to `localNetworkServer` and `localNetworkClient`:
   - Server's incoming messages → state updates
   - Client's connection status → state updates
   - Message broadcast → trigger state rebuild

3. [x] Handle lifecycle:
   - Session expires after 5 minutes of no activity
   - Graceful cleanup on dispose

**Tests**:
- [x] Integration: `local_session_provider_test.dart`:
  - Start hosting → state is `hosting` ✓
  - Connect as guest → state is `playing` ✓
  - Remote move received → local score updated ✓
  - End session → state is `idle` ✓
  - 5-minute timeout → session auto-expires ✓

**Verification**:
- [x] `flutter test test/data/local_session_provider_test.dart` passes
- [x] Riverpod DevTools shows state transitions

**Commit**: `feat(riverpod): add local session provider for multiplayer state`

---

### Phase 3: UI Screens

#### Increment 3.1: QR Host Screen
**Goal**: Display QR code on host device  
**Est. Time**: 1–2 hours

Tasks:
1. [x] Create `lib/features/local_play/qr_host_screen.dart`:
   - Watch `localSessionProvider`
   - When `hosting` state:
     - Display large QR code (min 200x200 dp)
     - Show session ID (e.g., "Session: ABC1-2D3E")
     - Show "Waiting for players..." with spinner
     - Display list of connected players (name/ID)
     - "Start Game" button (starts level after 1+ guests connected)
     - "Cancel" button (end session)
   - Display error state if server failed to start

2. [x] UI Polish:
   - QR code centered with breathing animation
   - Tap to refresh QR code
   - Copy session ID to clipboard
   - Dark mode support

**Tests**:
- [x] Widget: `qr_host_screen_test.dart`:
  - Renders QR when hosting ✓
  - Shows spinner when no guests ✓
  - Shows player list when guests connected ✓
  - "Start Game" button visible when ready ✓

**Verification**:
- [x] Visual: QR code is crisp and scannable
- [x] Layout responsive on various phone sizes

**Commit**: `feat(ui): add QR code host screen`

---

#### Increment 3.2: QR Scanner Screen
**Goal**: Allow guest to scan QR code from host  
**Est. Time**: 1.5–2 hours

Tasks:
1. [x] Create `lib/features/local_play/qr_scanner_screen.dart`:
   - Request camera permission (handle denial gracefully)
   - Display camera preview with QR overlay
   - On QR detected:
     - Parse URL
     - Validate format
     - Call `localSessionProvider.joinSession(url)`
   - Show connection status:
     - "Scanning..."
     - "Connecting to host..."
     - "Connected! Waiting for game to start..."
     - Error states with retry

2. [x] Fallback (if QR scan fails):
   - Manual entry field for session ID / host IP
   - Button to try again

3. [x] Use platform-native scanner:
   - iOS: AVFoundation
   - Android: ML Kit barcode scanning (via camera plugin)
   - Fallback to pure Dart qr_flutter for unsupported platforms

**Tests**:
- [x] Widget: `qr_scanner_screen_test.dart`:
  - Shows camera preview ✓
  - Camera permission requested ✓
  - Manual entry field available ✓
  - On QR parsed → joinSession called ✓

**Verification**:
- [x] Camera permission flows correctly
- [x] QR scanning latency < 1 second

**Commit**: `feat(ui): add QR code scanner screen`

---

#### Increment 3.3: Local Session Screen (During Play)
**Goal**: Display synchronized gameplay during local session  
**Est. Time**: 2–3 hours

Tasks:
1. [x] Create `lib/features/local_play/local_session_screen.dart`:
   - Watch `gameplayViewModel` + `localSessionProvider`
   - Show same puzzle/options as host
   - Display both players' scores side-by-side
   - When move is selected:
     - Update local score immediately
     - Broadcast move to network
     - Receive opponent's move and update UI
   - Implement two-panel layout:
     - Left: This player's score + move history
     - Right: Opponent's score + move history
     - Center: Shared puzzle/timer

2. [x] Sync timer:
   - Host sends timer ticks every 100ms
   - Guest adjusts local timer to match (smoother than receiving 30fps ticks)

3. [x] Session end:
   - Show summary: "Player A: 500 XP | Player B: 450 XP | Winner: A"
   - "Play Again" or "Return to Menu"

**Tests**:
- [x] Widget: `local_session_screen_test.dart`:
  - Renders both players' scores ✓
  - Move selection updates UI ✓
  - Timer is in sync ✓
  - Session end summary displays ✓

**Verification**:
- [x] Latency test: move appears on guest within 100ms

**Commit**: `feat(ui): add local session screen for synchronized play`

---

### Phase 4: Integration & Polish

#### Increment 4.1: Navigation Integration
**Goal**: Integrate local play into main navigation  
**Est. Time**: 1 hour

Tasks:
1. [x] Create `lib/features/local_play/local_play_router.dart`:
   - Routes:
     - `/local-play` → mode selection (Host vs Guest)
     - `/local-play/host` → QR host screen
     - `/local-play/guest` → QR scanner screen
     - `/local-play/session` → during-play screen

2. [x] Update `MainAppShell`:
   - Add "Play Locally" button/menu option
   - Route to local play flow

3. [x] Handle back navigation:
   - Confirm if mid-session ("Exit game?")
   - End session on back

**Tests**:
- [x] Widget: `local_play_router_test.dart`:
  - Navigation flow works ✓
  - Back confirmation shown mid-session ✓

**Commit**: `feat(navigation): integrate local play into main app`

---

#### Increment 4.2: Error Handling & Edge Cases
**Goal**: Gracefully handle connection issues  
**Est. Time**: 2 hours

Tasks:
1. [x] Handle errors:
   - Connection timeout → "Unable to connect. Check WiFi and try again"
   - Server unreachable → "Host is offline or disconnected"
   - Invalid QR → "Could not read QR code. Try again or enter manually"
   - Session expired → "Game session ended"

2. [x] Implement reconnection:
   - If guest disconnects mid-game → "Reconnecting..." spinner
   - Auto-reconnect with backoff
   - Manual "Reconnect" button

3. [x] Test rapid disconnect/reconnect:
   - Close network mid-game → both show "Disconnected"
   - Reconnect available within 30s
   - After 30s, session fully ends

**Tests**:
- [x] Integration: `local_play_error_handling_test.dart`:
  - Connection timeout handled ✓
  - Mid-session disconnect handled ✓
  - Auto-reconnect works ✓

**Commit**: `feat(error-handling): robust local play error recovery`

---

#### Increment 4.3: Tests & Coverage
**Goal**: Comprehensive test suite for network play  
**Est. Time**: 3–4 hours

Tasks:
1. [x] Unit test coverage:
   - Network models (JSON serialization)
   - Local network info (IP detection, port availability)
   - Server (connections, broadcast, cleanup)
   - Client (connect, disconnect, reconnect)

2. [x] Integration tests:
   - Host-guest connection cycle
   - Message synchronization
   - Hive persistence (scores saved after session)

3. [x] Run coverage report:
   - Target: >85% for network code
   - Exclude generated files

**Tests**:
- [x] `flutter test --coverage`
- [x] Review lcov.info for gaps

**Commit**: `test(local-play): comprehensive test suite for network features`

---

## Implementation Sequence (Recommended Order)

1. **Increment 1.1**: Network models + dependencies
2. **Increment 1.2**: WebSocket server
3. **Increment 1.3**: WebSocket client
4. **Increment 2.1**: Riverpod provider
5. **Increment 3.1**: QR host screen
6. **Increment 3.2**: QR scanner screen
7. **Increment 3.3**: Local session screen
8. **Increment 4.1**: Navigation
9. **Increment 4.2**: Error handling
10. **Increment 4.3**: Tests & coverage

---

## Definition of Done (Per Increment)

- [x] Code is written following project conventions
- [x] Unit tests pass with >85% coverage (or 100% for core logic)
- [x] `dart analyze` shows no issues
- [x] `flutter test` passes all tests
- [x] Code is reviewed for security (no hardcoded IPs, secrets, or unsafe network access)
- [x] Commit message follows convention: `feat(scope): description` or `test(scope): description`
- [x] No temporary debug code or console.log statements

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Network latency > 100ms on typical WiFi | Low | Medium | Test early; use message batching if needed |
| Port conflicts on shared networks | Medium | Low | Try 10 ports; inform user if all busy |
| Camera permission denial | Medium | Low | Provide manual entry fallback |
| State synchronization race conditions | Low | High | Implement idempotent move handling; sequence numbers on messages |
| Memory leaks in WebSocket (unclosed connections) | Medium | High | Aggressive cleanup in tests; use `StreamController.close()` |

---

## Success Criteria

- [x] Feature is deployable to production
- [x] All tests pass on CI/CD
- [x] Manual testing on real Android + iOS devices succeeds
- [x] QR scan succeeds in normal lighting within 3 tries
- [x] Local session completes 10+ consecutive rounds without crash
- [x] Scores are persisted correctly to Hive
- [x] No sensitive data leaked in logs or network traffic
