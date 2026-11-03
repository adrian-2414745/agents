agents configs

## Setup

After cloning, link this config into `~/.claude` (or `$CLAUDE_CONFIG_DIR`):

```bash
./setup_claude.sh            # or -n / --dry-run to preview
```

Agents, skills, `CLAUDE.md` and `statusline-command.sh` are symlinked into the repo, so `git pull` updates them


`settings.json` is not linked; only its `statusLine` key is set to run the linked script (needs `jq`).
Existing files are moved to `~/.claude/setup_claude-backups/<timestamp>/`. Safe to re-run.

## Agents.MD
Prefer AGENTS.MD - to keep your CLAUDE.local.md and still have Claude read AGENTS.md, set:
/config -> Project instructions -> claude-md-and-agents-md
