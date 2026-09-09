---
name: document-project
description: Document an entire project for onboarding — responsibilities, entry points (API, consumers, scheduled jobs), main components/modules, data stores, deployments, with an index to the main files. Use when asked to document a project, create onboarding docs, or map a whole codebase/service for a new dev or LLM agent.
argument-hint: optional focus areas or emphasis (leave empty for full project)
---

Document how this project works, end to end, for someone joining it. If "$ARGUMENTS" is non-empty, treat it as areas to emphasize — still cover the whole project, but go deeper there. The deliverables (kebab-case slug derived from the project/repo name), placed at the repository root unless the user specified another name or location:

- `onboarding-<project-slug>.md` — the main document
- `component-diagram-<project-slug>-mermaid.md` — mermaid diagram of the main components/modules and their dependencies

## Goal

The document will be read by a new developer or an LLM agent on their first day with this codebase. After reading it they should know: what the project is responsible for (and NOT responsible for), every way work enters the system, which module owns which concern, what it talks to externally, and what actually gets deployed. Optimize for that reader: concrete file paths, real type/function names, and behavior as it IS (not as it should be). This is not a design proposal and not user-facing docs.

## Process

1. **Map the surface first.** Start from the build definition (e.g. `build.sbt`, `package.json`, `pom.xml`, Dockerfiles, CI/deploy config) to find the modules, the produced artifacts/services, and the main classes/binaries. Then find every entry point: HTTP/GraphQL routes, message/queue consumers, scheduled jobs and polling loops, CLI commands. Use subagents for broad searches — the project footprint is by definition large; delegate per-area exploration (entry points, persistence, deployment) and keep only the conclusions.
2. **Trace one representative path per entry point class** — from trigger through the main components to its outputs (response, DB write, published message). Enough to show how the layers connect; this is not a per-feature deep dive (use document-feature for that).
3. **Identify boundaries.** External systems: databases, caches, queues/topics (produced and consumed), third-party APIs, other internal services. For each: what it's used for and where the client/config lives.
4. **Verify claims against code and config.** Every file path, module name, type name, queue/topic name, and service name in the document must exist in the repo. Never assume behavior from naming — check the implementation.
5. Write the document, then re-read it once asking: "could an agent with no other context pick up a typical ticket on this project and know where to start using only this document?" Fill any gaps.

## Document structure

```markdown
# <Project> Onboarding

One-paragraph summary: what the project is responsible for in the larger system, who calls it, what it produces.

## Responsibilities
What this project owns, and explicit non-responsibilities where a newcomer would guess wrong (things that live in neighboring services).

## Entry Points
Every way work enters the system, grouped by kind:
- **API** — routes/queries/mutations, where they're defined, auth if any
- **Consumers** — queues/topics consumed, the consumer class, what each message triggers
- **Scheduled** — cron jobs/polling loops, their schedule, what they do
- **Other** — CLI, admin endpoints, startup hooks
For each: trigger → handler file/symbol → one line on what happens.

## Components / Modules
The main modules/packages/services and their responsibilities. For each: what it owns, what it depends on, who calls it. Link to `component-diagram-<project-slug>-mermaid.md`.

## Data & External Systems
Databases (collections/tables that matter), caches, queues/topics published to, third-party and internal APIs called. For each: purpose and where the client/repository code lives.

## Deployments
What actually runs: one service or several, the artifact(s) built, main classes/entry files, how instances differ (env vars, roles, consumer-only vs API), and where deploy/infra config lives (Dockerfile, k8s/helm, CI pipeline).

## File Index
Table: path | role (one line each). The files a newcomer will touch first, grouped by area (entry points / core logic / types / persistence / config / tests / deploy).

## Running It Locally
How to build, run tests, and start the service(s) locally — real commands from the repo (CI config and scripts are the source of truth), plus required local dependencies (docker-compose, env vars).

## Conventions & Gotchas
Project-specific patterns a newcomer must follow (error handling, layering, test structure), invariants that must hold, and non-obvious behavior or tech debt discovered while reading the code.
```

Adapt sections to the project — drop ones that don't apply (e.g. no scheduled jobs), don't pad them. Keep the document tight enough to read in one sitting; depth goes into precise file references, not prose. Breadth over depth: name every entry point and module, but link deeper exploration to the code itself.

## Companion diagram

`component-diagram-<project-slug>-mermaid.md` is markdown with a fenced ```mermaid block so it renders on GitHub and in IDEs: a graph of the main modules/components and their dependencies (calls/imports), grouped by layer or deployable service where helpful. Include external systems (DBs, queues, APIs) as distinct nodes at the boundary.

Node labels must be real file/module/type/function names — the diagram is subject to the same verification as the main document. Skip it only if the project is too small for it to add anything (say so in the main document instead of emitting a trivial diagram).
