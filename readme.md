agents configs

## Setup

After cloning, link this config into `~/.claude` (or `$CLAUDE_CONFIG_DIR`):

```bash
./setup_claude.sh            # or -n / --dry-run to preview
```

Agents, skills and `CLAUDE.md` are symlinked into the repo, so `git pull` updates them.
Existing files are moved to `~/.claude/setup_claude-backups/<timestamp>/`. Safe to re-run.
