---
name: document-feature
description: Document how an existing feature works — file index, types, components, data flow, interactions — so a new dev or LLM agent can quickly get productive updating it, adding to it, or fixing bugs. Use when asked to document, explain, or map a feature/subsystem before modifying it.
argument-hint: feature name or description
---

Document how the feature "$ARGUMENTS" currently works in this project. The deliverables (kebab-case slug derived from the feature name), placed in `local-docs/<feature-slug>/` (create it if missing) unless the user specified another name or location:

- `local-docs/<feature-slug>/how-<feature-slug>-works.md` — the main document
- `local-docs/<feature-slug>/data-flow-mermaid-<feature-slug>.md` — mermaid diagram(s) of the data flow
- `local-docs/<feature-slug>/component-diagram-mermaid-<feature-slug>.md` — mermaid diagram of the components and their dependencies

## Goal

The document will be read by a new developer or an LLM agent whose job is to update the feature, add adjacent features, or fix bugs — with minimal re-exploration of the codebase. Optimize for that reader: concrete file paths, real type/function names, and behavior as it IS (not as it should be). This is not a design proposal and not user-facing docs.

## Process

1. **Explore first, write second.** Find every file involved in the feature: entry points (routes, handlers, commands, UI components), core logic, types/models, persistence, config, and tests. Use subagents for broad searches when the feature's footprint is unclear. Read the key files — do not describe code you haven't opened.
2. **Trace the data flow end to end** — from the trigger (request, user action, event, cron) through each transformation to its outputs (response, DB write, emitted event, UI render). Note where validation, authorization, error handling, and side effects happen.
3. **Verify claims against code.** Every file path, type name, and function name in the document must exist in the codebase. Never assume behavior from naming — check the implementation.
4. Write the document, then re-read it once asking: "could an agent with no other context locate and safely modify this feature using only this document?" Fill any gaps.

## Document structure

```markdown
# How <Feature> Works

One-paragraph summary: what the feature does, who/what triggers it, what it produces.

## File Index
Table: path | role (one line each). Group by layer (entry point / logic / types / persistence / tests / config / UI).

## Types & Data Model
The core types/models/schemas with their fields (only fields that matter), where each is defined, and how they map to storage or wire formats.

## Components
The main functions/classes/modules/services and their responsibilities. For each: what it does, what it depends on, who calls it. Link to `component-diagram-mermaid-<feature-slug>.md`.

## Data Flow
Step-by-step trace of the main path(s), referencing files and symbol names (e.g. `src/billing/invoice.ts` → `createInvoice()`) — never line numbers, they go stale. Cover important branches: error paths, empty/edge cases, feature flags. Link to `data-flow-mermaid-<feature-slug>.md`.

## Interactions
External touchpoints: APIs called, events published/consumed, DB collections/tables, queues, other features that depend on this one or that this one depends on.

## Extension Points & Gotchas
Where to hook in for the most likely changes; invariants that must hold; non-obvious behavior, workarounds, or tech debt discovered while reading the code.
```

Adapt sections to the project — drop ones that don't apply (e.g. no persistence), don't pad them. Keep the document tight enough to read in one sitting; depth goes into precise file references, not prose.

## Companion diagrams

Both diagram files are markdown with fenced ```mermaid blocks so they render on GitHub and in IDEs.

- `data-flow-mermaid-<feature-slug>.md`: a sequence diagram (or flowchart where there is no request/response shape) of the main path(s) traced in Data Flow. Use one diagram per trigger if the paths differ significantly.
- `component-diagram-mermaid-<feature-slug>.md`: a graph of the components and their dependencies (calls/imports), grouped by layer where helpful.

Node and participant labels must be real file/type/function names — the diagrams are subject to the same verification as the main document. Skip a diagram only if the feature is too small for it to add anything (say so in the main document instead of emitting a trivial diagram).

If "$ARGUMENTS" is ambiguous (matches multiple features or nothing recognizable in the codebase), list what you found and ask the user which one they mean before writing.
