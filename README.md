# Skills for software development

## Quick start

1. Install the skills

```
npx skills@latest add kklasing/skills
```

2. Pick the skills and which coding agent You want to install them on. **Make sure to select the /setup-sunbytes-skills**
3. Run /setup-sunbytes-skills in your agent. It will:

* Ask you which issue tracker you want to use (GitHub, Linear, or local files)
* Ask you what labels you apply to ticks when you triage them (/triage uses labels)
* Ask you where you want to save any docs we create

## Reference

### Development / engineering

* [`diagnose`](./skills/engineering/diagnose/SKILL.md) -- Disciplined diagnosis loop for hard bugs and performance regressions
* [`grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) -- Stress-test a plan against the project's domain model and update CONTEXT.md/ADRs inline
* [`improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) -- Find deepening opportunities in a codebase, informed by CONTEXT.md and `docs/adr/`
* [`setup-sunbytes-skills`](./skills/engineering/setup-sunbytes-skills/SKILL.md) -- Bootstrap a repo's `## Agent skills` config (issue tracker, triage labels, domain docs) for the engineering skills
* [`tdd`](./skills/engineering/tdd/SKILL.md) -- Test-driven development with the red-green-refactor loop
* [`to-issues`](./skills/engineering/to-issues/SKILL.md) -- Break a plan or PRD into independently-grabbable issues using tracer-bullet vertical slices
* [`to-prd`](./skills/engineering/to-prd/SKILL.md) -- Turn the current conversation context into a PRD on the project issue tracker
* [`triage`](./skills/engineering/triage/SKILL.md) -- Triage issues through a state machine driven by triage roles
* [`zoom-out`](./skills/engineering/zoom-out/SKILL.md) -- Get a higher-level map of the relevant modules and callers using the project's domain glossary

### Productivity

* [`grill-me`](./skills/productivity/grill-me/SKILL.md) -- Interview the user relentlessly about a plan or design, resolving every branch of the decision tree
* [`write-a-skill`](./skills/productivity/write-a-skill/SKILL.md) -- Write a new skill with the proper structure and bundled resources

### Tools / misc

* [`git-guardrails-claude-code`](./skills/misc/git-guardrails-claude-code/SKILL.md) -- Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, branch -D, etc.)
* [`setup-pre-commit`](./skills/misc/setup-pre-commit/SKILL.md) -- Set up Husky pre-commit hooks with lint-staged, type checking, vulnerability audits, and tests
