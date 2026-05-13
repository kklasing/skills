# Skills for software development

## Quick start

1. Install the skills

```
npx skills@latest add kklasing/skills
```

2. Pick the skills and which coding agent You want to install them on. **Make sure to select the /setup-sb-skills**
3. Run /setup-sb-skills in your agent. It will:

* Ask you which issue tracker you want to use (GitHub, Linear, or local files)
* Ask you what labels you apply to ticks when you triage them (/triage uses labels)
* Ask you where you want to save any docs we create

## Reference

### Development / engineering

* [`diagnose`](./skills/engineering/diagnose/SKILL.md) -- Disciplined diagnosis loop for hard bugs and performance regressions
* [`grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) -- Stress-test a plan against the project's domain model and update CONTEXT.md/ADRs inline
* [`improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) -- Find deepening opportunities in a codebase, informed by CONTEXT.md and `docs/adr/`
* [`review-pr`](./skills/engineering/review-pr/SKILL.md) -- End-to-end GitHub PR review (code, security, conventions, tests) that posts top-level and inline comments via `gh`
* [`sb-audit-nodejs`](./skills/engineering/sb-audit-nodejs/SKILL.md) -- Audit a Node.js project across maintainability, security, and scalability; writes a dated report to `docs/` with a high-risk summary and an improvement plan ready for `/to-issues`
* [`sb-nestjs`](./skills/engineering/sb-nestjs/SKILL.md) -- Sunbytes implementation guardrails for NestJS (v10/11) — modules, DI, controllers, DTOs, validation, guards, security, database patterns
* [`sb-nextjs`](./skills/engineering/sb-nextjs/SKILL.md) -- Sunbytes implementation guardrails for Next.js (App Router) — Server/Client Components, caching, routing, security headers
* [`sb-react`](./skills/engineering/sb-react/SKILL.md) -- Sunbytes implementation guardrails for React — components, hooks, state, performance, accessibility, security
* [`sb-test-react-behaviour`](./skills/engineering/sb-test-react-behaviour/SKILL.md) -- Backfill behaviour-focused tests for React components and custom hooks in `.tsx`/`.ts` using Vitest + React Testing Library + `user-event`
* [`sb-typescript`](./skills/engineering/sb-typescript/SKILL.md) -- Sunbytes implementation guardrails for TypeScript — strict typing, async, security, SOLID/KISS/DRY, testing, Sunbytes coding standards
* [`sb-write-vitest`](./skills/engineering/sb-write-vitest/SKILL.md) -- Backfill modern Vitest unit tests beside existing source files (`*.test.*`, never `*.spec.*`)
* [`setup-sb-skills`](./skills/engineering/setup-sb-skills/SKILL.md) -- Bootstrap a repo's `## Agent skills` config (issue tracker, triage labels, domain docs) for the engineering skills
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
