# Track Icon Asset Manifest — BL-30

> Provenance for bundled track artwork under `assets/images/icons/`.  
> All icons are original miToosa design assets committed in-repo (no third-party stock).

| Filename | Dimensions | Source | License | Creator | Derivative | Mapped tracks |
|----------|------------|--------|---------|---------|------------|---------------|
| `track_pattern_match.png` | 128×128 | In-repo original | Proprietary (miToosa) | miToosa design | No | track_1 |
| `track_shape_counter.png` | 128×128 | In-repo original | Proprietary (miToosa) | miToosa design | No | track_2 |
| `track_memory.png` | 128×128 | In-repo original | Proprietary (miToosa) | miToosa design | No | track_3, track_5 |
| `track_color_code.png` | 128×128 | In-repo original | Proprietary (miToosa) | miToosa design | No | track_4 |
| `track_sequence.png` | 128×128 | In-repo original | Proprietary (miToosa) | miToosa design | No | track_6 |
| `track_logic_gates.png` | 128×128 | In-repo original | Proprietary (miToosa) | miToosa design | No | track_7, track_8 |
| `track_number_crunch.png` | 128×128 | In-repo original | Proprietary (miToosa) | miToosa design | No | track_9–track_15 |
| `track_spatial.png` | 128×128 | In-repo original | Proprietary (miToosa) | miToosa design | No | track_16–track_23 |

**Reuse policy:** Multiple tracks may share one icon when the visual theme matches the puzzle family. Each `worlds.json` row declares its `iconAsset` explicitly — the UI does not infer paths from track IDs.

**Validation:** `test/core/content/catalog_validation_test.dart` (T-003) loads every declared `iconAsset` from the asset bundle.
