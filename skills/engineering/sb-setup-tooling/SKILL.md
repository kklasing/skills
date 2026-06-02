---
name: sb-setup-tooling
description: Bootstrap the baseline tooling for a Node.js project — ESLint (flat config) with Prettier, import-x, jsx-a11y, react, react-hooks; Husky hooks (pre-commit typecheck + lint-staged, commit-msg commitlint, pre-push typecheck + tests); commitlint conventional commits; release-please; GitHub CI workflow; Prettier; EditorConfig; pnpm audit; and Vitest (Istanbul coverage + Testing Library jsdom/React) plus Playwright. Use when the user wants to set up, scaffold, or bootstrap project tooling, linting, formatting, git hooks, conventional commits, releases, CI, or a test stack for a Node.js/TypeScript/React repo.
---

# Setup project tooling

Bootstrap the baseline dev tooling for a Node.js project. File contents live in [TEMPLATES.md](TEMPLATES.md) — read it before writing files.

## What this sets up

- **ESLint** flat config: typescript-eslint + Prettier (config), import-x, jsx-a11y, react, react-hooks
- **Prettier** + **EditorConfig**
- **Husky** hooks: `pre-commit` (typecheck + lint-staged), `commit-msg` (commitlint), `pre-push` (typecheck + all tests)
- **commitlint** with `config-conventional` (Conventional Commits only)
- **release-please** GitHub Action
- **GitHub CI** workflow (lint + typecheck + coverage + audit, plus an e2e job)
- **pnpm audit** script
- **Vitest** with Istanbul coverage + Testing Library (jsdom, React, jest-dom, user-event)
- **Playwright** e2e

## Before you start — ask the user

Detect what you can, then ask only what's still unclear. Don't assume:

1. **Package manager** — detect the lockfile (`pnpm-lock.yaml` → pnpm, etc.). User's default is **pnpm**; confirm if no lockfile exists.
2. **React?** — if not a React project, drop `react`, `react-hooks`, `jsx-a11y` from ESLint and skip jsdom/RTL deps.
3. **Playwright e2e?** — skip if they don't want browser/e2e tests.
4. **release-please + CI** — only if the repo is hosted on GitHub. Ask the release type (default `node`) and whether it's a monorepo. The CI workflow's e2e job is included only if Playwright is set up.
5. **Existing config** — never clobber. If a config already exists (ESLint, Prettier, Vitest, etc.), show the user and ask whether to merge, replace, or skip that piece.
6. **Missing prerequisites** — if `typescript`, a `tsconfig.json`, or a `package.json` is missing, stop and ask before continuing.

## Workflow

1. **Detect** package manager, framework (React/Next), TypeScript, the project's Node version (`.nvmrc`, `.node-version`, or `engines.node`), and any existing tool configs. Report what's already present.
2. **Confirm scope** using the questions above. Skip pieces the user opts out of.
3. **Install devDependencies** for the agreed pieces (see [TEMPLATES.md](TEMPLATES.md) § Dependencies). Use the detected package manager.
4. **Write config files** from [TEMPLATES.md](TEMPLATES.md), adapting to package manager and React/no-React. Skip any the user chose not to replace.
5. **Add package.json scripts**: `lint`, `format`, `typecheck`, `test`, `test:coverage`, `test:e2e`, `audit`, `prepare`.
6. **Init Husky** (`pnpm dlx husky init` or pkg-manager equivalent) and write the three hook files. Husky v9+ needs no shebang.
7. **Verify** (below), then tell the user what was set up and what they should review.

## Verify

- [ ] `pnpm lint`, `pnpm typecheck`, `pnpm test` run (or report which scripts are missing source to act on)
- [ ] `.husky/pre-commit`, `.husky/commit-msg`, `.husky/pre-push` exist; `prepare` script is `"husky"`
- [ ] A test commit with a non-conventional message is rejected by `commit-msg`
- [ ] `pnpm audit` runs
- [ ] ESLint, Prettier, EditorConfig, Vitest (and Playwright, if chosen) configs exist
- [ ] release-please and CI workflows exist under `.github/workflows/` (if on GitHub)

## Notes

- Run Prettier for formatting; use `eslint-config-prettier` to turn off conflicting ESLint rules (don't run Prettier *through* ESLint).
- Vitest unit tests are `*.test.ts(x)`; Playwright e2e are `*.spec.ts` under `e2e/` — keep them separate so Vitest doesn't pick up Playwright specs.
- Don't `git commit` for the user unless they ask; if you do, the new hooks act as a smoke test.
