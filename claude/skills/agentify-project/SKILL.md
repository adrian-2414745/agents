---
name: agentify-project
description: Check that a project meets the user's agent setup (agent-docs, lessons file, CLAUDE.local.md), recommend fixes, and write a tested `## Verification` section (exact typecheck, lint, test, build commands) into CLAUDE.local.md. Removes the file tree map from it. Use when the user runs /agentify-project or asks to agentify, onboard or set up a project for agents.
argument-hint: optional focus (module, language) or "check" to report only
---

Bring this project in line with the user's agent setup. Every change goes through the report first: you check, report the gaps with recommended fixes, the user picks, then you apply only what they picked. If `$ARGUMENTS` contains `check`, stop after the report.

## What the user setup expects

Source of truth: the user's `~/.claude/CLAUDE.md`. Re-read it on every run, and if it adds or drops requirements, follow it rather than this list.

1. `agent-docs/` exists at the repo root and is committed.
2. `agent-docs/lessons-learned.md` exists. It may be empty.
3. `CLAUDE.local.md` exists at the repo root and is not committed (untracked and ignored).
   - It adds local information on top of the project's committed instructions. It never replaces or duplicates them.
   - To ignore it, recommend `.git/info/exclude` (local only) over `.gitignore` (a repo change), unless the repo's `.gitignore` already lists other local files.
4. `CLAUDE.local.md` contains a `## Verification` section with tested commands (see below).
5. `CLAUDE.local.md` contains no file tree map (a `## Project structure map` section, or a fenced tree of the repo's directories). Remove the map and keep everything else in the file, e.g. the onboarding link added by `document-project`.

## Process

1. Read `agent-docs/lessons-learned.md` and `CLAUDE.local.md`, if they exist.
2. **Check** user setup items 1–5 above. For each, record: ok | missing | wrong, with the evidence (path, `git check-ignore -v <file>`, `git ls-files <file>` output).
3. **Understand the build and check setup** before proposing any command. See "Building the verification commands".
4. **Test-run every candidate command.** See "Test runs".
5. **Write the report** (format below) and stop for the user's choice. Apply nothing yet.
6. **Apply** only the fixes the user picked. Then show the final `## Verification` section and the diff of `CLAUDE.local.md`. Back up `CLAUDE.local.md` to `$TMPDIR` before changing it, and give the backup path.

## Building the verification commands

Work out how the project is actually built and checked. Don't guess from file names.

Sources, in order of trust:
1. CI config (`.gitlab-ci.yml`, `.github/workflows/*`, `Jenkinsfile`): the commands CI runs are the ones known to work.
2. Build definitions and scripts: `build.sbt` + `project/*.sbt`, `pyproject.toml`, `setup.cfg`, `tox.ini`, `noxfile.py`, `package.json` scripts, `Makefile`, `justfile`, `scripts/`.
3. Tool configs: `.scalafmt.conf`, `.scalafix.conf`, `mypy.ini`, `ruff.toml`, `tsconfig*.json`, `eslint.config.*`, test configs.
4. `README` / existing docs. Treat these as hints. They're often stale.

In multi-module or multi-language repos, fan out read-only subagents (`code-scout`, or `Explore` for locating), one per module or language, and keep only their conclusions.

Cover these checks when the project has them, in this order:

| check | what to find out |
|---|---|
| compile / typecheck | the command, and which modules it covers |
| codegen check | whether generated code (GraphQL, OpenAPI, protobuf, ORM) has an "is it up to date" check |
| lint | linter in check mode |
| format check | formatter in check mode (never write mode) |
| unit tests | full suite |
| single test / suite | a template with a placeholder, e.g. `sbt --client "core/testOnly *<Spec>"` |
| integration tests | the command, and what they need (docker, DB, env vars, credentials) |
| build / package | only if it catches something compile doesn't (e.g. assembly, bundling) |

Language notes. Treat these as starting points and confirm each against the repo:

- **Scala / sbt:** always `sbt --client`. Check the root aggregate, so `compile` / `test` cover all modules or name the modules explicitly. Check whether `Test / compile` is needed. Check for `IntegrationTest` / an `it` module, `scalafmtCheckAll`, `scalafix --check`, and fatal-warnings flags (`-Werror`, sbt-tpolecat modes).
- **Python:** detect the runner from lockfiles and config (`uv.lock` → `uv run`, `poetry.lock` → `poetry run`, a plain venv). Check for `mypy` / `pyright`, `ruff check`, `ruff format --check` / `black --check`, `pytest` with markers that split unit and integration.
- **TypeScript / JavaScript:** detect the package manager from the lockfile (`pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`, `bun.lockb`). Check for `tsc --noEmit` (and which tsconfig), eslint, the test runner (vitest / jest), workspaces (run per package or from the root), and codegen scripts.
- **Other languages:** apply the same method, using what CI runs as the anchor.

## Test runs

Run each candidate command once, from the repo root, before it goes into the report.

- Never run a command that writes source files (format / fix / write modes, codegen that writes into the source tree), installs dependencies, needs network credentials, deploys or publishes. List those as "not run" with the reason.
- Redirect output to a log under `$TMPDIR`, and keep only the exit code, duration and the tool's summary line (e.g. `506 passed, 1 skipped`). Never print full logs.
- Use a Bash timeout of 600000 ms or less. For longer suites, run them in the background and wait for completion.
- For the single test / suite template, run it with a real test name from the repo.
- Classify each result:
  - **works:** it ran and exited 0.
  - **works, failing:** it ran, but there are real failures (failing tests, lint errors). The command is right and the failures are the baseline. Record the counts.
  - **broken:** it didn't run (missing task or script, wrong module, missing binary). Investigate, fix the candidate and re-run, at most twice. If it's still broken, ask the user.
  - **needs setup:** a dependency is missing (docker, DB, env var, sbt server). Say what's missing.
- Log non-obvious problems to `agent-docs/lessons-learned.md` (`problem -> solution`, one line, appended with a single `printf '%s\n' "..." >>`).

## Report

```markdown
# Agentify — <project>

## Setup check
| # | item | status | evidence | recommended fix |
Status: ok / missing / wrong. Use "—" in the last column when status is ok.

## Verification (proposed)
<the exact section that will be written, see format below>

Not included:
- <command> — <reason: writes files / needs credentials / broken after 2 tries / user to decide>

## Fixes to apply
1. <fix> (recommended)
2. …
Alternatives, when there is a real choice (e.g. `.git/info/exclude` vs `.gitignore`).

Questions: … (omit if none)
```

## `## Verification` section format

The verifier agent and callers copy commands from here, so keep it exact and short.

```markdown
## Verification
Run from the repo root. Tested <date> at commit <short sha>.

| check | command | needs | time | last result |
|---|---|---|---|---|
| compile | `sbt --client compile Test/compile` | — | 1m10s | ok |
| test | `sbt --client test` | — | 3m40s | 506 passed, 1 skipped |
| single test | `sbt --client "core/testOnly *<Spec>"` | — | ~20s | ok |
| it tests | `sbt --client it/test` | docker running | 6m | ok |

Env: <env vars the commands need, without values; omit if none>
Notes: <gotchas, e.g. "start the sbt server first: `sbt --client`"; omit if none>
```

Commands must be copy-pasteable. Use no shell aliases and no paths outside the repo.
