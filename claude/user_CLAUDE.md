## Very important general rules

Read and understand before responding.
Never assume anything, check if possible or ask the user.
When I ask for a review of anything (direct or separate agent/bot), never directly apply/fix the issue discovered instead always present the raised issues, together with candidate fixes and recommended fix, and I will chose what to do.

## Workflow
1. if feature exists, document current feature behavior (skill document-feature)
2. spec - define new behavior (skill create-spec)
3. plan implementation (skill generate-implementation-plan-from-spec)

## Agentic workflow

### Agents
code-scout
verifier

### Documentation
Agents keep their md artifacts at the project root with the following structure:

```
agent-docs  (committed)
    lessons-learned.md                           (main session)
    code-style.md
    onboarding-<project>.md                      (skill document-project)
    component-diagram-mermaid-<project>.md       (skill document-project)
    <agent>/                                     (owned by each agent)
        <agent>-lessons-learned.md
local-docs  (local/temp uncommitted (.gitignore) MD artifacts)
    <slug>/
        how-<slug>-works.md                      (current behavior, skill document-feature)
        spec-<slug>.md                           (spec, skill create-spec)
        plan-<slug>.md                           (implementation plan, skill generate-implementation-plan-from-spec)
        <artifact>-<slug>.md                     (others: diagrams, scripts)
```





## Lessons learned
Read `agent-docs/lessons-learned.md` in every project.
Log a lesson whenever you hit and fix a non-obvious problem — the goal is to never repeat the same mistake.
Append with a single write (`printf '%s\n' "..." >> <file>`)
Format: `problem -> solution`. One line per lesson, no debugging story. 

## Project structure map
Read and keep in every project's AGENTS.override.md or CLAUDE.local.md always a file tree map of the project, max 3 levels deep.

## Agent parallelism
Never run code writing agents in parallel.
