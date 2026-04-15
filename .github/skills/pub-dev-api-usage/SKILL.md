---
name: pub-dev-api-usage
description: Verified pub.dev REST API endpoints for querying package metadata, changelogs, and advisories. Agents must use these — do not guess or invent URLs.
---

# pub.dev API Usage

## Base URL

```
https://pub.dev/api
```

All endpoints return JSON. Use `curl -sL --max-time 10` and validate with `jq` before acting on the response.

---

## Endpoints

### Package metadata

```bash
curl -sL --max-time 10 "https://pub.dev/api/packages/<name>"
```

Key fields:
- `.latest.version` — latest stable version string
- `.latest.pubspec.version` — same, from the pubspec
- `.advisories` — array of advisory objects (may be absent; use `// []`)

### All versions list

```bash
curl -sL --max-time 10 "https://pub.dev/api/packages/<name>" \
  | jq '[.versions[].version]'
```

### Specific version metadata

```bash
curl -sL --max-time 10 "https://pub.dev/api/packages/<name>/versions/<version>"
```

### Advisories for a package

```bash
curl -sL --max-time 10 "https://pub.dev/api/packages/<name>" \
  | jq '.advisories // []'
```

If the array is non-empty, each advisory contains:
- `.id` — advisory identifier
- `.aliases[]` — CVE IDs if mapped
- `.summary` — human-readable description
- `.affected[].versions` — affected version ranges
- `.severity` — severity string

---

## Changelog

The changelog is served as an HTML page, not a JSON endpoint:

```
https://pub.dev/packages/<name>/changelog
```

To extract text (agent use):

```bash
curl -sL --max-time 10 "https://pub.dev/packages/<name>/changelog" \
  | sed 's/<[^>]*>//g' \
  | sed '/^[[:space:]]*$/d'
```

Or fetch the raw `CHANGELOG.md` from the package's GitHub repository if linked in the pubspec's `homepage` or `repository` field.

---

## Rate Limits & Caching

- pub.dev does not publish explicit rate limits, but use `--max-time 10` on every request to avoid hanging.
- In CI, cache advisory responses per run — do not query the same package twice in one job.
- If a request returns HTTP 429, wait 5 seconds and retry once.

---

## Validating Responses

Always validate that the response is JSON before parsing:

```bash
RESPONSE=$(curl -sL --max-time 10 "https://pub.dev/api/packages/go_router")
if ! echo "$RESPONSE" | jq empty 2>/dev/null; then
  echo "ERROR: Invalid JSON from pub.dev" >&2
  exit 1
fi
```

---

## Example: Check if installed version has an advisory

```bash
NAME="share_plus"
INSTALLED="10.1.4"

ADVISORIES=$(curl -sL --max-time 10 "https://pub.dev/api/packages/${NAME}" \
  | jq --arg v "$INSTALLED" '
    .advisories // [] |
    map(select(.affected[]?.versions[]? | . == $v)) |
    length
  ')

if [ "$ADVISORIES" -gt 0 ]; then
  echo "ADVISORY FOUND for ${NAME}@${INSTALLED}" >&2
  exit 1
fi
```
