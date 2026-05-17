#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <directory>" >&2
  exit 2
fi

target_dir="$1"
if [ ! -d "$target_dir" ]; then
  echo "Directory not found: $target_dir" >&2
  exit 2
fi

shopt -s nocasematch

allowlist=()
allowlist_file=".prompt-injection-allowlist"
if [ -f "$allowlist_file" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="${line%%[[:space:]]*}"
    if [ -n "$line" ]; then
      allowlist+=("$line")
    fi
  done < "$allowlist_file"
fi

patterns=(
  'coding agents'
  'read this first'
  'you should do'
  'ignore previous'
  'disregard (previous|prior)'
  '<\|im_start\|>'
  '\[INST\]'
  'jailbreak'
  'act as (an? )?(ai|llm|assistant)'
  '^user-invocable:[[:space:]]*true'
)

while IFS= read -r -d '' file; do
  line_number=0
  in_fence=false
  in_sanitization_note=false

  while IFS= read -r line || [ -n "$line" ]; do
    line_number=$((line_number + 1))

    if [[ "$line" =~ '^[[:space:]]*<!--[[:space:]]*SANITIZATION[[:space:]]+NOTE' ]]; then
      in_sanitization_note=true
    fi

    if $in_sanitization_note; then
      if [[ "$line" =~ '-->' ]]; then
        in_sanitization_note=false
      fi
      continue
    fi

    if [[ "$line" =~ '^```' ]]; then
      if [ "$in_fence" = true ]; then
        in_fence=false
      else
        in_fence=true
      fi
      continue
    fi

    if [ "$in_fence" = true ]; then
      continue
    fi

    for pattern in "${patterns[@]}"; do
      if [[ "$line" =~ $pattern ]]; then
        skip=false
        for allow in "${allowlist[@]:-}"; do
          if [[ "$file" =~ $allow ]] || [[ "$line" =~ $allow ]]; then
            skip=true
            break
          fi
        done
        if [ "$skip" = false ]; then
          echo "$file:$line_number: $pattern"
          error=1
          break
        fi
      fi
    done
  done < "$file"
done < <(find "$target_dir" -type f \( -iname '*.md' -o -iname '*.html' -o -iname '*.jsx' -o -iname '*.js' -o -iname '*.css' -o -iname '*.txt' -o -iname '*.json' \) -print0)

if [ "${error:-0}" -ne 0 ]; then
  exit 1
fi
