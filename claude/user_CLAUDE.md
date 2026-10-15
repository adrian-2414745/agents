## Very important general rules

Read and understand before responding.
Never assume anything, check if possible or ask the user.
When I ask for a review of anything (direct or separate agent/bot), never directly apply/fix the issue discovered instead always present the raised issues, together with candidate fixes and recommended fix, and I will chose what to do.


# Writing style
Be concise and use plain language.
Cut words that add no meaning: filler adjectives and adverbs (robust, comprehensive, seamless, simply, really), hedges, intensifiers. 
Keep the facts when shortening: paths, numbers, errors, caveats.
No preamble or recap: don't restate my question, announce what you are about to do.



### Documentation
Agents keep their md artifacts at the project root with the following structure:

```
agent-docs  (committed)
    lessons-learned.md                           (main session)
    onboarding-<project>.md                      (skill document-project)
    component-diagram-mermaid-<project>.md       (skill document-project)
    <agent>/                                     (owned by each agent)
        <agent>-lessons-learned.md
local-docs  (local/temp uncommitted (.gitignore) MD artifacts)
    <slug>/
        how-<slug>-works.md                      (current behavior, skill document-feature)
        spec-<slug>.md                           (spec, skill create-spec)
        design-<slug>.md                         (design, skill create-design)
        plan-<slug>.md                           (implementation plan, skill create-plan)
        <artifact>-<slug>.md                     (others: diagrams, scripts)
```



## Lessons learned
Read `agent-docs/lessons-learned.md` in every project.
Log a lesson whenever you hit and fix a non-obvious problem — the goal is to never repeat the same mistake.
Append with a single write (`printf '%s\n' "..." >> <file>`)
Format: `problem -> solution`. One line per lesson, no debugging story. 

## Agent parallelism
Never run code writing agents in parallel.

# Available agents
Using agents saves session context.
- `verifier`: always run builds, typechecks, tests, lint and dependency resolution through this agent; never run them directly with Bash in the main session. Pass the exact commands as `checks`.
- `code-scout`: use for read-only questions about existing code, config or docs (how X behaves, where Y is set) instead of reading many files in the main session. Pass numbered `questions` and `scope`.
