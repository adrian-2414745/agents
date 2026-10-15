#!/usr/bin/env bash
# Link this repo's Claude Code user config into the Claude home (~/.claude).
#
#   claude/agents/*        -> $CLAUDE_HOME/agents/*
#   claude/skills/*        -> $CLAUDE_HOME/skills/*
#   claude/user_CLAUDE.md  -> $CLAUDE_HOME/CLAUDE.md
#   claude/statusline-command.sh -> $CLAUDE_HOME/statusline-command.sh
#
# settings.json is not linked (it holds machine-specific plugins/permissions);
# only its statusLine key is set to run the linked script (needs jq).
#
# user_CLAUDE.md must not use @imports: Claude resolves them relative to the
# symlink target (the repo), not $CLAUDE_HOME.
#
# Items are symlinked, so a `git pull` updates the config in place.
# Existing items are moved to $CLAUDE_HOME/setup_claude-backups/<timestamp>/.
# Safe to re-run: links that already point to the repo are left untouched.
#
# Usage: ./setup_claude.sh [-n|--dry-run]

set -euo pipefail

DRY_RUN=0
case "${1:-}" in
  -n|--dry-run) DRY_RUN=1 ;;
  "") ;;
  *) echo "Usage: $0 [-n|--dry-run]" >&2; exit 1 ;;
esac

REPO_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/claude"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
BACKUP_DIR="$CLAUDE_HOME/setup_claude-backups/$(date +%Y%m%d-%H%M%S)"

run() {
  if (( DRY_RUN )); then echo "  [dry-run] $*"; else "$@"; fi
}

# link <source> <dest>
link() {
  local src="$1" dest="$2"
  local rel="${dest#"$CLAUDE_HOME"/}"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "ok       $rel"
    return
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    run mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    run mv "$dest" "$BACKUP_DIR/$rel"
    echo "backup   $rel -> ${BACKUP_DIR#"$CLAUDE_HOME"/}/$rel"
  fi

  run ln -s "$src" "$dest"
  echo "linked   $rel"
}

# Remove links in <dir> that point into this repo but whose target no longer exists
# (e.g. a skill deleted or renamed in the repo).
prune() {
  local dir="$1" entry
  [[ -d "$dir" ]] || return 0
  for entry in "$dir"/*; do
    if [[ -L "$entry" && ! -e "$entry" && "$(readlink "$entry")" == "$SRC/"* ]]; then
      run rm "$entry"
      echo "pruned   ${entry#"$CLAUDE_HOME"/}"
    fi
  done
}

# Point settings.json statusLine at the linked script; other keys are kept.
set_status_line() {
  local settings="$CLAUDE_HOME/settings.json"
  local cmd="bash \"$CLAUDE_HOME/statusline-command.sh\""

  if ! command -v jq >/dev/null; then
    echo "skip     settings.json statusLine (jq not installed; the status line also needs it)"
    return
  fi
  if [[ -f "$settings" ]] && jq -e --arg c "$cmd" \
      '.statusLine.type == "command" and .statusLine.command == $c' "$settings" >/dev/null 2>&1; then
    echo "ok       settings.json statusLine"
    return
  fi

  if [[ -f "$settings" ]]; then
    run mkdir -p "$BACKUP_DIR"
    run cp "$settings" "$BACKUP_DIR/settings.json"
    echo "backup   settings.json -> ${BACKUP_DIR#"$CLAUDE_HOME"/}/settings.json"
  fi
  if (( DRY_RUN )); then
    echo "  [dry-run] set statusLine in settings.json"
  else
    local tmp
    tmp="$(mktemp)"
    { [[ -f "$settings" ]] && cat "$settings" || echo '{}'; } \
      | jq --arg c "$cmd" '.statusLine = {type: "command", command: $c}' > "$tmp"
    mv "$tmp" "$settings"
  fi
  echo "set      settings.json statusLine"
}

[[ -d "$SRC" ]] || { echo "Source dir not found: $SRC" >&2; exit 1; }

echo "Repo:        $REPO_DIR"
echo "Claude home: $CLAUDE_HOME"
(( DRY_RUN )) && echo "Mode:        dry run (no changes)"
echo

run mkdir -p "$CLAUDE_HOME/agents" "$CLAUDE_HOME/skills"

shopt -s nullglob
for item in "$SRC"/agents/*; do
  link "$item" "$CLAUDE_HOME/agents/$(basename "$item")"
done
for item in "$SRC"/skills/*/; do
  item="${item%/}"
  link "$item" "$CLAUDE_HOME/skills/$(basename "$item")"
done
shopt -u nullglob

link "$SRC/user_CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
link "$SRC/statusline-command.sh" "$CLAUDE_HOME/statusline-command.sh"
set_status_line

prune "$CLAUDE_HOME"
prune "$CLAUDE_HOME/agents"
prune "$CLAUDE_HOME/skills"

echo
echo "Done. Restart Claude Code to pick up the changes."
