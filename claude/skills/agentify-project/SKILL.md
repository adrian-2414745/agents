---
name: agentify-project
description: Check that a project meets the user's agent folder setup (agent-docs, lessons file, CLAUDE.local.md), recommend fixes, and apply the ones the user picks.
argument-hint: optional "check" to report only
disable-model-invocation: true
---

Bring this project in line with the user's agent setup. Every change goes through the report first: you check, report the gaps with recommended fixes, the user picks, then you apply only what they picked. If `$ARGUMENTS` contains `check`, stop after the report.

## What the user setup expects

Agents keep their md artifacts at the project root with the following structure:

```
CLAUDE.local.md                                  (required; ignored;)
agent-docs/                                      (required; committed)
    lessons-learned.md                           (required, may be empty; committed; main session)
    <agent>/                                     (optional; committed; owned by each agent)
        <agent>-lessons-learned.md               (optional; committed)
local-docs/                                      (required, may be empty; ignored via .gitignore; local/temp MD artifacts)
```


## Process

1. Read `agent-docs/lessons-learned.md` and `CLAUDE.local.md`, if they exist.
2. **Check** each line of the tree above that exists or is required, plus the `CLAUDE.local.md` rules. For each, record: ok | missing | wrong, with the evidence (path, `git check-ignore -v <file>`, `git ls-files <file>` output).
3. **Write the report** (format below) and stop for the user's choice. Apply nothing yet.
4. **Apply** only the fixes the user picked. Back up `CLAUDE.local.md` to `$CLAUDE.local.md.bk` before changing it.

## Report

```markdown
# Agentify — <project>

## Setup check
| # | item | status | evidence | recommended fix |
Status: ok / missing / wrong. Use "—" in the last column when status is ok.

## Fixes to apply
1. <fix> (recommended)
2. …
Alternatives, when there is a real choice (e.g. `.git/info/exclude` vs `.gitignore`).

Questions: … (omit if none)
```
