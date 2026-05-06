---
name: sb-audit-nodejs
description: Audit a Node.js project for technical health across maintainability, security, and scalability. Detects framework (NestJS, Next.js, Express, Fastify, generic), runs analyzers (npm audit, depcheck, madge, tsc, ESLint), reads code, then writes a dated report to `docs/` with a high-risk summary, per-perspective findings, and an improvement plan structured for `/to-issues`. Use when the user wants a tech-status report, project health check, due-diligence audit, or tech-debt scan of a Node.js app.
---

# sb-audit-nodejs

Produce a technical status report for a Node.js project across three perspectives — **maintainability**, **security**, **scalability** — plus an actionable improvement plan.

## Invocation

`/sb-audit-nodejs` from the repo root. No args.

## Workflow

### 1. Detect the project shape

Read `package.json`, lockfile, and `tsconfig.json`. Identify:

- **Framework:** NestJS, Next.js, Express, Fastify, generic Node, monorepo
- **Language:** TypeScript (strict?) or JavaScript
- **Test runner:** vitest, jest, mocha, none
- **Source layout:** `src/`, `apps/`, `packages/`
- **Node version:** `engines.node`, `.nvmrc`
- **Package manager:** npm / pnpm / yarn (from lockfile)

If NestJS or Next.js is detected, apply [`sb-nestjs`](../sb-nestjs/SKILL.md) or [`sb-nextjs`](../sb-nextjs/SKILL.md) as the lens for framework-specific findings. If TypeScript, apply [`sb-typescript`](../sb-typescript/SKILL.md).

### 2. Run analyzers

**Confirm each command before running.** Capture output; never edit files. Use `npx -y` for missing tools rather than mutating `package.json`.

- [ ] `npm audit --json` — CVEs
- [ ] `npx -y depcheck --json` — unused / missing deps
- [ ] `npx -y madge --circular --extensions ts,js <src>` — import cycles
- [ ] `npx tsc --noEmit` — type errors (TS only)
- [ ] `npx eslint . --max-warnings 0` (if configured) — lint state
- [ ] `npm outdated --json` — dependency freshness
- [ ] `git log --since="1 year ago" --oneline | wc -l` — activity signal

If a tool would take more than ~5 min on a large repo, confirm scope first or narrow it. If a tool fails or is missing, log the gap in the report's **Methodology & gaps** section instead of silently skipping.

### 3. Read code by perspective

Use the Agent tool with `subagent_type=Explore` to walk the codebase. Don't re-read what analyzers already covered — read what they can't see (architecture smells, manual security patterns, scalability footguns).

Work through [CHECKLIST.md](CHECKLIST.md) — per-perspective audit items.

### 4. Synthesize

Score every finding:

- **Severity:** critical / high / medium / low
- **Effort:** S (hours) / M (day) / L (week+)
- **Confidence:** certain (analyzer hit) / likely (code read) / suspected (smell)

Anything **critical** or **high-severity security** is also surfaced in the report's **High-risk summary** at the top.

### 5. Write the report

File: `docs/tech-status-<YYYY-MM-DD>.md`. Create `docs/` if missing. If a same-day report exists, append `-2`, `-3`, … — never overwrite.

Use [REPORT-TEMPLATE.md](REPORT-TEMPLATE.md). The improvement-plan section must follow that structure exactly so [`to-issues`](../to-issues/SKILL.md) can consume it: P0/P1/P2 buckets, each item with title, perspective, severity, effort, why, acceptance criteria, and pointers.

### 6. Hand off

End the conversation with:

> Report written to `docs/tech-status-<date>.md`. Run `/to-issues` to convert the improvement plan into tickets.

## When to stop and ask

- A real secret appears in a file — **stop**, don't echo it, alert the user out-of-band.
- An analyzer would take more than ~5 min — confirm scope first.
- No `package.json` at the repo root — stop, report that this isn't a Node.js project.
- A prior `tech-status-*.md` exists — ask whether to write a fresh report or a *delta* against the most recent one.
- The repo doesn't run (`npm install` fails, lockfile is broken) — report that as a finding rather than fighting it.
