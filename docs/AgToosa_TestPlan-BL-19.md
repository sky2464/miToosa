# Test Plan: BL-19 — Sanitize embedded prompt-injection text in docs/mitoosa-design-system-2/

> **Spec reference:** [Docs/archived/spec-BL-19.md](archived/spec-BL-19.md)
> **Coverage target:** Every Must AC mapped to ≥1 test.

---

## AC Coverage Table

| AC | Description | Test IDs | Category |
|----|-------------|----------|----------|
| AC-001 | No imperative agent-directive headings remain outside SANITIZATION NOTE / fenced blocks | T-001 | Static-scan |
| AC-002 | Retained former-directive content is wrapped in `SANITIZATION NOTE (BL-19)` HTML comment + non-executable code fence | T-002 | Static-scan |
| AC-003 | Spec file `Docs/archived/spec-BL-19.md` contains a §2.5 sanitization log enumerating every change | T-003 | Doc-presence |
| AC-004 | CI script flags re-introduced banned patterns (exit 1) | T-004, T-005, T-006 | Bash/CI |
| AC-005 | CI script passes on current sanitized state (exit 0) | T-007 | Bash/CI |
| AC-006 | `SKILL.md` has no top-level `user-invocable: true` | T-008 | Static-scan |
| AC-007 | Design content (color tokens, type scale, components) preserved in `project/README.md` + `project/DESIGN_SPEC.md` | T-009 | Doc-presence |

---

## Test Details

| ID | Test Name | AC | @smoke |
|----|-----------|-----|--------|
| T-001 | `directive_headings_absent` — grep `docs/mitoosa-design-system-2/` for `^#\s*CODING AGENTS`, `READ THIS FIRST`, `What you should do`, `IMPORTANT` H2/H3 patterns outside SANITIZATION NOTE blocks. Expect zero hits. | AC-001 | @smoke |
| T-002 | `sanitization_notes_present` — assert `docs/mitoosa-design-system-2/README.md` and `docs/mitoosa-design-system-2/project/SKILL.md` each contain exactly one `<!-- SANITIZATION NOTE (BL-19):` comment block, and the SKILL.md former-metadata is inside a fenced code block. | AC-002 | @smoke |
| T-003 | `spec_contains_sanitization_log` — assert `Docs/archived/spec-BL-19.md` contains section `### 2.5 Sanitization Log (AC-003)` with a markdown table referencing both sanitized files. | AC-003 | |
| T-004 | `ci_script_flags_directive_heading` — drop a temp file `/tmp/inj.md` containing `# CODING AGENTS: READ THIS FIRST`; run `scripts/check_prompt_injection.sh /tmp`; expect exit 1 and stderr listing the file. | AC-004 | |
| T-005 | `ci_script_flags_user_invocable_true` — temp file with frontmatter `user-invocable: true`; expect exit 1. | AC-004, AC-006 | |
| T-006 | `ci_script_flags_role_hijack` — temp file with `act as an AI assistant`; expect exit 1. | AC-004 | |
| T-007 | `ci_script_passes_current_state` — run `scripts/check_prompt_injection.sh docs/mitoosa-design-system-2/` against HEAD; expect exit 0. | AC-005 | @smoke |
| T-008 | `skill_md_not_invocable` — assert no line in `docs/mitoosa-design-system-2/project/SKILL.md` matches the top-level (column-0) regex `^user-invocable:\s*true` outside fenced code blocks. | AC-006 | |
| T-009 | `design_content_preserved` — assert `docs/mitoosa-design-system-2/project/README.md` contains the strings "color", "spacing", "type"; assert `project/DESIGN_SPEC.md` exists and is non-empty (>500 bytes). | AC-007 | |

---

## Notes

- All tests are static / shell-based. No Flutter widget tests required (chore touches docs + CI only).
- Tests T-004 / T-005 / T-006 exercise the CI guard's positive-detection path; T-007 exercises the negative path against real state.
- The script's allowlist must permit lines inside `<!-- SANITIZATION NOTE ... -->` HTML comments and inside triple-backtick fences so that the documented historical text in `README.md` + `SKILL.md` does not self-trip the guard (verified by T-007).
- Wave 3 / 3.4 in the spec (synthetic fixture) implements T-004 through T-006.
