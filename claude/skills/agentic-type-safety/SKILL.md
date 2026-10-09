---
name: agentic-type-safety
description: Audit a project's type safety setup — typecheckers, compiler flags, linters, codegen checks, and the language features/patterns/libraries in use — and recommend what to add, ranked HIGH / MEDIUM-HIGH / MEDIUM-LOW / LOW, so coding agents can verify their own output (verifier runs, post-write hooks). Report only, never implements. Use when asked to audit, assess or improve type safety, strong typing, or agent verification checks for a project.
argument-hint: optional "run" to also run the installed checks for baselines; optional focus (module, language)
---

Audit how much this project's types and checks can catch, and recommend what to add. The goal is a fast, reliable verification loop for coding agents: after an agent writes code, a typechecker, compiler or linter should tell it what it got wrong, so it can fix the mistake before a human sees it.

Deliverable: `local-docs/agentic-type-safety/agentic-type-safety.md`. Create the directory if it's missing. Overwrite the file on every run, and never read a previous report: every run assesses the project from scratch.

## Hard rules

- **Report only.** The only file you write is the report. Never install tools or dependencies.
- **Never simulate a tool.** Don't count or estimate how many violations a check would produce, and don't grep the code to guess.
- **Greps are fine for detecting features.** For example, check whether `opaque type`, branded types or `NewType` appear anywhere. The answer is yes or no.
- **Check versions first.** Detect the language and tool versions. Recommend only what those versions support, or tag the item `requires: <version>`. Check every flag or rule name you propose against current docs (WebSearch/WebFetch when available), because names change between releases.

## Modes

- **Static (default).** Read build files, tool configs, CI config, dependency manifests, and a sample of source files. Don't run anything.
- **Run (only when `$ARGUMENTS` contains `run`).** Do everything in static mode, and also run the project's existing check commands, plus advisory variants that only add CLI flags without touching config (e.g. `tsc --noEmit --noUncheckedIndexedAccess`, `mypy --strict`). Record each command's exit code, duration, and the tool's own summary line. Never run a command that writes files, installs anything or needs network credentials. Redirect output to `$TMPDIR` and keep only the summary.
- In static mode, if the tools look installed (e.g. `node_modules` exists, there's a venv, there's an sbt project), add a note at the end of the report saying `/agentic-type-safety run` would add the real exit codes and timings.

## Process

1. Read `agent-docs/lessons-learned.md` if it exists.
2. **Inventory.** Find the languages, modules, language versions and build tool. In multi-language repos or monorepos, fan out read-only subagents (`code-scout` or `Explore`), one per language or module, and keep only their conclusions. If `$ARGUMENTS` names a focus, go deeper there but still cover the whole project.
3. **Check what's already in place.** For each language, find:
   - the typechecker or compiler strictness settings
   - linters and their rule sets
   - codegen steps (GraphQL, OpenAPI, protobuf, ORM schemas) and whether anything checks the generated code is up to date
   - where each check runs: CI, a pre-commit hook, an agent hook, a script, or nowhere
   - whether findings block (error / fatal warnings) or only warn
4. **Detect language features and libraries in use.** Look at dependency manifests and a few domain/model files, and grep for feature markers (see the reference file). Mark each one as "used" or "not seen".
5. **Build the candidate list.** Start from what the project actually is. Use `references/<language>.md` (`scala.md`, `python.md`, `typescript.md`) as examples, not a checklist. For other languages, apply the same method using your own knowledge.
6. **Rank each candidate** with the rules below.
7. **Write the report.** Re-read it once and ask: "Could a human approve or reject each item in under a minute?" Cut anything that doesn't help with that.

## Ranking rules

Two questions decide the level of a check:

- **Basic or advanced?** A check is **basic** if it's part of the ecosystem's standard strict preset: `tsc --strict`, typescript-eslint `recommended-type-checked`, `mypy --strict`, pyright `strict`, sbt-tpolecat defaults, exhaustive pattern-match checking. Anything beyond the preset is **advanced**.
- **Can it be non-blocking?** It can if it's configurable to only **warn**, or if it can run as an **advisory command** that reports problems without failing CI or hooks, e.g. a separate `tsconfig.strict.json` or a `mypy --strict` job.

| | can be non-blocking | blocking only |
|---|---|---|
| **basic** | **HIGH** | **MEDIUM-LOW** |
| **advanced** | **MEDIUM-HIGH** | **LOW** |

Items that need code changes instead of config:
- **MEDIUM-HIGH:** patterns or libraries that new code can use while old code stays as it is. Examples: newtypes or branded IDs, ADTs for states, smart constructors, schema validation at boundaries, Result types. A library doesn't enforce itself, so the item's `How:` must say how agents are made to use it: a convention line for `CLAUDE.md` / `AGENTS.md`, or a lint rule that pairs with it.
- **LOW:** migrations that touch the whole codebase. Examples: adopting an effect system, explicit nulls, refinement types everywhere.
- **LOW** with a `requires: <version>` tag: anything that needs a language or major tool upgrade with no backport. If a backport exists (`typing_extensions`, a library), rank the item normally.

**HIGH always starts with fixes to existing checks:** a check that's configured but doesn't run in CI, has no single command, or (run mode) currently fails.

Within a level, order items as follows:
1. Fixes to existing checks.
2. Items with fast per-file feedback.
3. Strength of the type-safety gain.

Note dependencies between items, e.g. "type-aware lint rules need `parserOptions.project`".

Group related flags into one item, e.g. "TS strictness flags" instead of five separate items.

**Caps.** The report is meant to be read in one sitting. Describe at most 5 HIGH, 3 MEDIUM-HIGH, 2 MEDIUM-LOW and 2 LOW items in full (12 in total), keeping the highest-ranked ones.

**Explain every item.** Each item gets:
- **Why:** one line on the kind of bug it catches and how that helps an agent verify its output.
- **Prevents:** a minimal example in the project's language of code that is accepted today and would be rejected or flagged after the change, plus what goes wrong at runtime without it. Use a real pattern from the project when you've seen one during exploration, otherwise a typical one. Keep it to one to three lines.

**Out of scope:** formatters, general tests and coverage. If they already exist, list them only in Verification commands. Type-level tests and property-based tests are in scope, ranked as advanced.

## Report structure

Keep it short and easy to scan. It's for human review.

```markdown
# Agentic type safety — <project>

<date> · commit <short sha> · mode: static | run

## Summary
- Languages / versions / build tool: …
- Strongest thing in place: …
- Biggest gap: …

## In place
| area | tool / feature | runs in | blocking? | notes |
Areas: typecheck, compiler flags, lint, codegen check, language features & libs used.
"runs in": CI / pre-commit / agent hook / script only / not wired.

## Recommendations

Levels:
- **HIGH** — standard checks you can turn on today as warnings; nothing breaks.
- **MEDIUM-HIGH** — stronger checks that can warn, or patterns and libraries for new code; nothing breaks, old code can stay as it is.
- **MEDIUM-LOW** — standard checks that can't warn; turning them on fails the build until existing violations are fixed.
- **LOW** — advanced checks that can't warn, or whole-codebase changes; plan these first.

### HIGH
1. **<item>**
   Why: <one line: what kind of bug it catches>
   Prevents: `<code accepted today that gets rejected / flagged>` → <what goes wrong without it>
   How: `<minimal config snippet or command>` (warning / advisory mode)
   Notes: depends on … · requires …   ← omit if nothing to say

### MEDIUM-HIGH
1. **<item>**
   Kind: check | pattern/library
   Why: …
   Prevents: …
   How: `<minimal config snippet or command>`; for a pattern/library, also how agents are made to use it
   Notes: …

### MEDIUM-LOW
Same item format as HIGH, but `How:` is the blocking config.

### LOW
Same item format as HIGH.

Example item:
1. **Branded ID types** (MEDIUM-HIGH)
   Kind: pattern/library
   Why: IDs of different entities are all `string`, so mixing them up compiles.
   Prevents: `chargeCustomer(order.id, user.id)` with the arguments swapped → charges the wrong account.
   How: `type UserId = string & { readonly __brand: "UserId" }` in new modules; parse at the API boundary. Add to `CLAUDE.md`: "new entity IDs are branded types".

## Verification commands
Commands an agent or hook can run, including ones proposed above (mark them "proposed").
| check | project command | per-file command | blocking? | speed | hook fit |
- per-file command: the same check scoped to one changed file (e.g. `eslint <file>`, `ruff check <file>`), so a post-write hook shows only warnings in the file the agent just wrote. Write `—` when the tool can't scope to a file, and give the fastest incremental command instead. IDE/LSP diagnostics are an alternative per-file typecheck when the project has a language server.
- speed: measured in run mode, otherwise "fast / medium / slow (estimate)".
- hook fit: `PostToolUse` (per-file, ~5s or less) · `Stop` / pre-commit (project-wide) · CI only.
```

Leave out empty sections. Every config snippet must use real file names from this project, e.g. `tsconfig.json`, `pyproject.toml`, `build.sbt`.
