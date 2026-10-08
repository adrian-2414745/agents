## Very important general rules

Read and understand before responding.
Never assume anything, check if possible or ask the user.
When I ask for a review of anything (direct or separate agent/bot), never directly apply/fix the issue discovered. Always present the raised issues, together with candidate fixes and recommended fix, and I will chose what to do.

## Workflow
1. if feature exists, document current feature behavior (skill document-feature)
2. spec - define new behavior (skill create-spec)
3. plan implementation (skill generate-implementation-plan-from-spec)

## MD file organization
When MD files are generated, organize them as described:

local-docs <- local/temp uncommited (.gitignore) MD artifacts
local-docs/slug/how-slug-works.md <- current behavior
local-docs/slug/spec-slug.md <- spec for updating current behavior
local-docs/slug/plan-slug.md <- plan to implement future spec
local-docs/slug/other-slug.md <- other artifacts
local-docs/other.md

## Lessons learned
Read and keep `agents/lessons-learned.md` in every project.
Log a lesson whenever you hit and fix a non-obvious problem — the goal is to never repeat the same mistake.
Append with a single write (`printf '%s\n' "..." >> <file>`)
Format: `problem -> solution`. One line per lesson, no debugging story. 

## Project structure map
Read and keep in every project's AGENTS.override.md or CLAUDE.local.md always a file tree map of the project, max 3 levels deep.

## Agent parallelism
Never run code writing agents in parallel.
