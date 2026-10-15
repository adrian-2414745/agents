---
name: create-design
description: Create the high-level design for a reviewed spec, together with the user — first 2–3 prose proposals with pros/cons, then, for the adopted one, components, seams, APIs, contract formats (DTO/DBO), protocols, error handling between components/services, with diagrams. Sits between spec and plan. Use when asked to design a feature or before generating an implementation plan from a spec.
argument-hint: "[specification file] [draft design file (optional)]"
---

Create the design for the given specification: "$ARGUMENTS"
Save it as `local-docs/<slug>/design-<slug>.md`, next to `local-docs/<slug>/spec-<slug>.md`.
If a draft design file was also given, treat it as one of the candidate proposals (see Draft design).

The spec says **what**. The design says **how, at architecture level**. The plan (skill create-plan) turns the design into ordered tasks.

## Level of abstraction

Stay at architecture / component level. The reader must understand the solution in a few minutes.

**In**: components and their responsibilities, module boundaries, public APIs (endpoints, traits/interfaces, topics/events), contract formats (DTO, DBO, wire models), protocols between components (sync/async, ordering, idempotency, retries), error handling across boundaries, data ownership, migration/back-compat.

**Out**: private functions and helpers, internal algorithms, class internals, file-by-file changes, task ordering, test lists. These belong in the plan or the code.

Rule of thumb: if it is not visible from outside a component, leave it out.

## Design rules

1. Separate over-the-wire/persistence formats from internal models (DTO, DBO, model).
2. Favour backwards compatibility: API, DTO and DBO changes need a migration / de-serialization story.
3. Favour types that make illegal states unrepresentable (show it in contracts, e.g. ADTs instead of flags).
4. Clear seams: each new component plugs into existing code at a named boundary.

## Draft design (optional input)

The user's draft can be in any shape: notes, partial sections, diagrams, code.
- It is **one candidate**, not the default. Evaluate it in phase 2 like the other proposals, with honest pros and cons. Propose alternatives that differ from it, and recommend another one if it is better.
- If the user adopts it (or a mix), keep its decisions in phase 3. Don't silently change them; raise conflicts with the spec, code facts or design rules as open questions with candidate fixes and the recommended one.
- Never modify the draft file. If the draft is `design-<slug>.md` itself, ask before overwriting it.

## Process

The design is built in collaboration with the user, in three phases. No diagrams before the user adopts a proposal.

### Phase 1 — understand
1. Read the spec. It must be reviewed by the user; if not, stop and say so.
2. Read the current-state doc `local-docs/<slug>/how-<slug>-works.md` and, if present, `agent-docs/component-diagram-mermaid-<project>.md`. If no current-state doc exists and the current state is non-trivial, ask the user whether to run skill document-feature first.
3. Gather facts with agents: Explore to locate code, code-scout for verified behaviour (existing contracts, error mapping, defaults). Don't guess existing signatures or formats.

### Phase 2 — proposals (prose only)
4. Write 2–3 proposals (the draft, if given, counts as one). They must differ in a meaningful way (e.g. where the logic lives, sync vs async, new service vs extend existing, schema change vs new collection), not be variations of one idea. Each proposal (no diagrams) has all of:
   - **Idea**: 3–6 sentences of prose — components involved, how they talk, what data changes.
   - **Pros**: bullets, at least one.
   - **Cons**: bullets, at least one. Every option has costs; don't leave this empty.
   - Pros and cons cover, where relevant: complexity, back-compat/migration, failure handling, performance, operational cost, fit with existing code.
   - **Spec fit**: acceptance criteria or goals it handles poorly, if any.
5. Close with a comparison table (proposal × key criteria) and a recommendation with the reason.
6. Write the proposals into §2 of `design-<slug>.md` and present them to the user. Then collaborate: answer questions, refine, merge proposals, add new ones. Repeat until the user explicitly adopts one. Don't move on without that.

### Phase 3 — full design
7. Write the rest of `design-<slug>.md` for the adopted proposal (sections 3–10, with diagrams). Reduce §2 to the adopted approach plus the rejected proposals with one-line reasons.
8. Raise open questions and wait for answers. Integrate them.
9. Launch a sonnet review agent to check: consistency with the spec and the adopted proposal, every acceptance criterion covered, abstraction level (flag internal details), contradictions between diagrams and contracts.
10. Present the review findings with candidate fixes and the recommended one, as a wizard. Never auto-apply review fixes.
11. Stop. The user reviews the design before any plan is written.

## Change markers

Mark every element: `NEW`, `CHANGED`, `REMOVED`. Untouched elements appear only when needed for context.
- In code blocks: `// NEW`, `// CHANGED: <what>`, `// REMOVED`.
- In tables: a `Change` column.
- In diagrams: `classDef` colours (see Diagrams).

## Design format

### 1. Context
Short, plain language: the problem, link to the spec, link to the current-state doc(s).

### 2. Approach
Phase 2: the proposals, pros/cons, comparison table and recommendation (see Process).
After adoption: the adopted approach (3–6 sentences), then **Alternatives considered**: each rejected proposal, one line on why.

### 3. Components
Diagram 1 (component), then a table:

| Component | Module | Change | Responsibility |
|-----------|--------|--------|----------------|
| `NewThing` | `core` | NEW | one line |
| `ExistingThing` | `api` | CHANGED | what changes and why |
| `OldThing` | `infra` | REMOVED | why |

### 4. Seams
Where new code plugs into existing code, one bullet each: boundary, who calls whom, what crosses it.

### 5. APIs & Contracts
Public surface only, with change markers.
- **APIs**: endpoints (method, path, request/response DTO, status codes), traits/interfaces (signatures only), topics/events (name, key, payload).
- **Formats**: DTO, DBO and wire models as code. Annotate every added/changed/removed field.

```scala
case class RequestStateDBO(
  @Key("_id") requestId: RefreshRequestId,
  state: StateDBO,
  profile: Option[EnrichedLIProfileLookupDBO] // NEW
)
```

- For each changed DTO/DBO: back-compat impact (legacy records, absent fields, defaults) and migration need.

### 6. Protocols
Diagram 2 (sequence) per main flow. Under each: sync/async, ordering, idempotency, retries, timeouts, transaction boundaries.

### 7. Error handling between components
One row per failure crossing a boundary:

| Boundary | Failure | Representation (error type / status code / event) | Caller behaviour (propagate / fallback / retry / DLQ) |
|----------|---------|------|------|

### 8. Data ownership & migration
Who writes and who reads each store/collection/topic. Migration and back-compat strategy (links to spec §11).

### 9. Spec traceability

| Acceptance criterion | Component(s) / flow |
|----|----|
| AC-1 | |

### 10. Open questions

## Diagrams

Mermaid only. Keep each diagram readable: ~15 nodes max; split by flow or region otherwise.

Colour convention, used in every flowchart:

```
classDef new fill:#d4f7d4,stroke:#2e7d32;
classDef changed fill:#fff3cd,stroke:#b8860b;
classDef removed fill:#f8d7da,stroke:#b02a37,stroke-dasharray:4 3;
classDef existing fill:#eeeeee,stroke:#888888;
```

**Always**
1. **Component** (`flowchart`): existing + new/changed/removed components, subgraphs per module (shows seams), edges = call/dependency direction labelled with the contract (`-- UserRepo.find -->`). If `component-diagram-mermaid-<project>.md` exists, draw only the affected region of it.
2. **Sequence** (`sequenceDiagram`): one per main spec flow, plus the main failure path. Use `->>` for sync, `-)` for async; show events, retries, transaction boundaries.

**When applicable**
3. **State** (`stateDiagram-v2`): an entity has a lifecycle (status, job state). States, transitions, triggers, terminal states.
4. **Data model** (`erDiagram` or `classDiagram`): 3+ related types/collections. Relations and ownership only; fields stay in §5 code blocks.
5. **System / container** (`flowchart`, C4-style): the change crosses services or infra (services, queues/topics, DBs, external APIs). Skip for single-service changes.

Not used: separate before/after diagrams (colours cover it), per-class diagrams (too detailed).
