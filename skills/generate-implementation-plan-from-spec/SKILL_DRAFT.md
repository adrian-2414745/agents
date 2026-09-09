---
name: generate-implementation-plan-from-spec
description: Creates the implementation plan for the given specification document. To be used only if there is an existing specification document.
argument-hint: [specification file][plan]
---


Create the implementation plan from the given specification: "$ARGUMENTS"
If a plan file was also referenced, use that as a starting poing for the solution design, else create plan-<slug>.md

## General code design rules
1. CLEAN architecture style
2. apply SOLID principles
3. Prefer pure functions, strong types, FP/Haskel code style.
4. Favor strong type design that makes illegal states unrepresentable 
5. Separate over-the-wire/persistence formats from internal data models using DTO and DBO models
6. The new design and behaviour should favour backwards compatibility with the old: API, DBOs, and DTOs should be handled with migration support and de/serialization unit tests.

## Plan creation process
1. read and understand: how the code is structured and works now, the new specification.
2. write the initial plan-<slug>.md
3. raise any open questions and wait for answers
4. integrate the answers back into the plan
5. Launch a sonnet review agent to review the plan: check consistency/contradictions
6. Present the review findings together with solutions and the recommended one to the user as a wizard. Let the user choose the final solution and integrate the responses back into the plan. Never auto-apply review fixes.

## Plan format
1. Plan starts with context section describing in natural language, in short form each of: the current state/problem, reference to the spec file, the proposed high-level architecture/design solution.
2. The plan should be composed of smaller tasks, ordered logically, progress tracked by ticking checkboxes [x]
3. Each task has: implementation description, tests to add/adapt, verification steps (compile, run tests)
4. Highlight the changes/updates/removals of data types (model, dbo, dto) and trait/interfaces.