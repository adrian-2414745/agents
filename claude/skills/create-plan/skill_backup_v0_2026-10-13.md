---
name: generate-implementation-plan-from-spec
description: Creates the implementation plan for the given specification document. To be used only if there is an existing specification document.
argument-hint: [specification file][plan]
---


Create the implementation plan from the given specification: "$ARGUMENTS"
If a plan file was also referenced, use that as a starting poing for the solution design, else create `local-docs/<slug>/plan-<slug>.md` (next to the spec `local-docs/<slug>/spec-<slug>.md`)

## General code design rules
1. CLEAN architecture style
2. apply SOLID principles
3. Prefer pure functions, strong types, FP/Haskel code style.
4. Favor strong type design that makes illegal states unrepresentable
5. Separate over-the-wire/persistence formats from internal data models using DTO and DBO models
6. The new design and behaviour should favour backwards compatibility with the old: API, DBOs, and DTOs should be handled with migration support and de/serialization unit tests.

## Plan creation process
1. read and understand: how the code is structured and works now, the new specification.
   - Prefer reading/linking the existing `local-docs/<slug>/how-<slug>-works.md` (current-state doc) over re-describing current behaviour. If no such doc exists and the current state is non-trivial, write one first, then reference it from the plan.
2. write the initial `local-docs/<slug>/plan-<slug>.md`
3. raise any open questions and wait for answers
4. integrate the answers back into the plan
5. Launch a sonnet review agent to review the plan: check consistency/contradictions
6. Present the review findings together with solutions and the recommended one to the user as a wizard. Let the user choose the final solution and integrate the responses back into the plan. Never auto-apply review fixes (user should be kept in the loop).

## Plan format
1. Plan starts with context section describing in natural language, in short form each of: the current state/problem, reference to the spec file, reference to the relevant `local-docs/<slug>/how-<slug>-works.md` doc(s), the proposed high-level architecture/design solution.
2. The plan should be composed of smaller tasks, ordered logically **so that each task compiles on its own**, progress tracked by ticking checkboxes [x].
3. Each task has: implementation description, tests to add/adapt, verification steps (compile, run tests).
4. Highlight the changes/updates/removals of data types (model, dbo, dto) and trait/interfaces (see Components and Data Model below).
5. Close the task list with a final dedicated **Full verify** task: full compile + all test suites.

### Components (New / Modified tables)
Summarise the code surface as two tables so the blast radius is visible at a glance.

**New**

| Component | Module | Role |
|-----------|--------|------|
| `NewThing` | `core` | one-line responsibility |

**Modified**

| Component | Change |
|-----------|--------|
| `ExistingThing` | what changes and why |

- Name the module for every new component.
- In the Modified table, be explicit about trait/interface signature changes (new params, new methods).

### Data Model
Show the concrete types with inline markers, not just prose. Annotate every added/changed field.

```scala
private case class RequestStateDBO(
  @Key("_id") requestId: RefreshRequestId,
  state: StateDBO,
  profile: Option[EnrichedLIProfileLookupDBO] // NEW
)
```

- Use `// NEW`, `// CHANGED`, `// REMOVED` markers.
- Call out DTO/DBO/model separation and the migration/de-serialization impact of each change.

### Task done-notes (audit trail)
When a task completes, tick its checkbox and append a short italic done-note recording:
- what was actually done (deviations from the plan);
- test result counts (e.g. `core 47/47 green`);
- **any temporary shim, and the task ID where it is removed** (e.g. *temporary `leechResponse = false` at the DTO site — replaced in T7*).

Track every temporary shim forward to the task that resolves it, so nothing is silently left behind.

### Testing
Find all existing possibly impacted tests.

A dedicated section listing exactly which specs to create/extend and what each asserts. Always include:
- **back-compat tests**: legacy record / absent field decodes to the intended default;
- **de/serialization tests** for every changed DTO/DBO/wire model (round-trip + golden where applicable);
- the unit/integration specs per new component, naming the scenarios each covers.

### Failure handling
Enumerate the failure modes introduced or touched by the change and the intended behaviour for each (error propagation, fallbacks, idempotency, retries). One bullet per mode.
