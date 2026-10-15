#!/usr/bin/env bash
input=$(cat)

# ── Fields from JSON ────────────────────────────────────────────────────────
cwd=$(echo "$input"           | jq -r '.workspace.current_dir // .cwd // "."')
model=$(echo "$input"         | jq -r '.model.display_name // .model.id // "claude"')
effort=$(echo "$input"        | jq -r '.effort.level // empty')
transcript=$(echo "$input"    | jq -r '.transcript_path // empty')
repo_name=$(echo "$input"     | jq -r '.workspace.repo.name // empty')
used_pct=$(echo "$input"      | jq -r '.context_window.used_percentage // empty')
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ── Path: replace $HOME with ~ ───────────────────────────────────────────────
home="$HOME"
display_path="${cwd/#$home/~}"

# ── Repo name fallback: derive from git remote or dirname ───────────────────
if [ -z "$repo_name" ]; then
  repo_name=$(git -C "$cwd" remote get-url origin 2>/dev/null \
    | sed 's|.*[/:]||; s|\.git$||')
fi
if [ -z "$repo_name" ]; then
  repo_name=$(basename "$cwd")
fi

# ── Git branch + dirty indicator ─────────────────────────────────────────────
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
  || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
dirty=$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)

# ── Token counts: try transcript JSONL first, fall back to context_window ───
used_tokens=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  # Find last line that has a usage object with input_tokens
  last_usage=$(grep -o '"usage":{[^}]*}' "$transcript" 2>/dev/null | tail -1)
  if [ -n "$last_usage" ]; then
    input_tok=$(echo "$last_usage"   | grep -o '"input_tokens":[0-9]*'                  | grep -o '[0-9]*$' || echo 0)
    cache_write=$(echo "$last_usage" | grep -o '"cache_creation_input_tokens":[0-9]*'   | grep -o '[0-9]*$' || echo 0)
    cache_read=$(echo "$last_usage"  | grep -o '"cache_read_input_tokens":[0-9]*'        | grep -o '[0-9]*$' || echo 0)
    [ -z "$input_tok"    ] && input_tok=0
    [ -z "$cache_write"  ] && cache_write=0
    [ -z "$cache_read"   ] && cache_read=0
    used_tokens=$(( input_tok + cache_write + cache_read ))
  fi
fi
# Also try context_window.total_input_tokens as a fallback
if [ -z "$used_tokens" ] || [ "$used_tokens" -eq 0 ] 2>/dev/null; then
  used_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
fi

# ── Format token count: k or M ───────────────────────────────────────────────
format_tokens() {
  local n="$1"
  if [ -z "$n" ] || [ "$n" -eq 0 ] 2>/dev/null; then
    echo ""
    return
  fi
  if [ "$n" -ge 1000000 ]; then
    awk "BEGIN { printf \"%.1fM\", $n/1000000 }"
  elif [ "$n" -ge 1000 ]; then
    awk "BEGIN { printf \"%dk\", int($n/1000 + 0.5) }"
  else
    echo "${n}"
  fi
}
tokens_fmt=$(format_tokens "$used_tokens")

# ── ANSI colors ──────────────────────────────────────────────────────────────
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
DIM='\033[2;37m'
TEAL='\033[38;5;87m'
RESET='\033[0m'

SEP="${DIM} | ${RESET}"

# ── 1. Model ─────────────────────────────────────────────────────────────────
printf "${CYAN}%s${RESET}" "$model"
[ -n "$effort" ] && printf "${DIM} (%s)${RESET}" "$effort"

# ── 2. CWD ───────────────────────────────────────────────────────────────────
printf "%b" "$SEP"
printf "${BLUE}%s${RESET}" "$display_path"

# ── 3. Repo(branch) [dirty] ──────────────────────────────────────────────────
if [ -n "$branch" ]; then
  printf "%b" "$SEP"
  if [ -n "$dirty" ]; then
    printf "${GREEN}%s(${RED}%s*${GREEN})${RESET}" "$repo_name" "$branch"
  else
    printf "${GREEN}%s(${GREEN}%s${GREEN})${RESET}" "$repo_name" "$branch"
  fi
fi

# ── 4a. 5h rate-limit window % (+ current time / time left until reset) ─────
if [ -n "$five_hour_pct" ]; then
  printf "%b" "$SEP"
  printf "${TEAL}5h:%.0f%%${RESET}" "$five_hour_pct"

  now_time=$(date +%H:%M)
  resets_epoch=""
  if [ -n "$five_hour_resets_at" ]; then
    case "$five_hour_resets_at" in
      ''|*[!0-9]*)
        # ISO-8601 timestamp (e.g. 2026-07-24T18:00:00Z) — parse as UTC (BSD date, then GNU date)
        resets_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$five_hour_resets_at" "+%s" 2>/dev/null \
          || date -u -d "$five_hour_resets_at" "+%s" 2>/dev/null)
        ;;
      *)
        # Already epoch seconds
        resets_epoch="$five_hour_resets_at"
        ;;
    esac
  fi
  if [ -n "$resets_epoch" ]; then
    now_epoch=$(date +%s)
    remaining_fmt=$(awk -v resets="$resets_epoch" -v now="$now_epoch" 'BEGIN {
      secs = resets - now
      if (secs < 0) secs = 0
      h = int(secs / 3600)
      m = int((secs % 3600) / 60)
      if (h > 0) printf "%dh%dm", h, m
      else printf "%dm", m
    }')
    printf "${DIM} (%s, %s left)${RESET}" "$now_time" "$remaining_fmt"
  else
    printf "${DIM} (%s)${RESET}" "$now_time"
  fi
fi

# ── 4b. 7-day rate-limit window % ────────────────────────────────────────────
if [ -n "$seven_day_pct" ]; then
  printf "%b" "$SEP"
  printf "${TEAL}7d:%.0f%%${RESET}" "$seven_day_pct"
fi

# ── 4c. Used context % ───────────────────────────────────────────────────────
if [ -n "$used_pct" ]; then
  printf "%b" "$SEP"
  printf "${YELLOW}ctx:%.0f%%${RESET}" "$used_pct"
fi

# ── 5. Used token count ──────────────────────────────────────────────────────
if [ -n "$tokens_fmt" ]; then
  printf "%b" "$SEP"
  printf "${MAGENTA}%s${RESET}" "$tokens_fmt"
fi

printf "\n"
