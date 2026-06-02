# Templates

File bodies for `sb-setup-tooling`. Adapt the package manager (examples use **pnpm**) and drop React/Playwright pieces the user opted out of. Pin to the latest stable major when installing.

## Dependencies

Install as devDependencies.

**Core (always):**

```
eslint @eslint/js typescript-eslint eslint-config-prettier eslint-plugin-import-x
prettier
husky lint-staged
@commitlint/cli @commitlint/config-conventional
typescript
```

**React (if React project):** add to ESLint deps

```
eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-jsx-a11y
```

**Vitest + Testing Library:**

```
vitest @vitest/coverage-istanbul jsdom
@testing-library/react @testing-library/jest-dom @testing-library/user-event
```

**Playwright (if e2e):**

```
@playwright/test
```

Then `pnpm exec playwright install` to fetch browsers.

## package.json scripts

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test",
    "audit": "pnpm audit",
    "prepare": "husky"
  }
}
```

## eslint.config.mjs

Full flat config. Remove the `react`, `react-hooks`, `jsx-a11y` blocks for non-React projects. `eslint-config-prettier` must be **last** so it wins.

```js
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import importX from 'eslint-plugin-import-x';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import jsxA11y from 'eslint-plugin-jsx-a11y';
import prettier from 'eslint-config-prettier';

export default tseslint.config(
  { ignores: ['dist', 'build', 'coverage', 'node_modules', '.next', 'playwright-report'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  importX.flatConfigs.recommended,
  importX.flatConfigs.typescript,
  // --- React block (drop for non-React) ---
  {
    files: ['**/*.{jsx,tsx}'],
    ...react.configs.flat.recommended,
    settings: { react: { version: 'detect' } },
  },
  {
    files: ['**/*.{jsx,tsx}'],
    plugins: { 'react-hooks': reactHooks },
    rules: reactHooks.configs.recommended.rules,
  },
  jsxA11y.flatConfigs.recommended,
  // --- end React block ---
  {
    languageOptions: {
      parserOptions: { projectService: true, tsconfigRootDir: import.meta.dirname },
    },
    rules: {
      'import-x/order': [
        'warn',
        { 'newlines-between': 'always', alphabetize: { order: 'asc' } },
      ],
    },
  },
  prettier,
);
```

## .prettierrc

```json
{
  "useTabs": false,
  "tabWidth": 2,
  "printWidth": 100,
  "singleQuote": true,
  "trailingComma": "all",
  "semi": true,
  "arrowParens": "always"
}
```

## .prettierignore

```
dist
build
coverage
node_modules
.next
pnpm-lock.yaml
playwright-report
```

## .editorconfig

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
```

## .lintstagedrc.json

```json
{
  "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md,yml,yaml,css}": ["prettier --write"],
  "*": "prettier --ignore-unknown --write"
}
```

## commitlint.config.js

```js
export default { extends: ['@commitlint/config-conventional'] };
```

## Husky hooks

No shebang needed (Husky v9+). Swap `pnpm` for the detected manager.

`.husky/pre-commit`

```sh
pnpm typecheck
pnpm exec lint-staged
```

`.husky/commit-msg`

```sh
pnpm exec commitlint --edit "$1"
```

`.husky/pre-push`

```sh
pnpm typecheck
pnpm test
```

## vitest.config.ts

```ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./vitest.setup.ts'],
    include: ['src/**/*.test.{ts,tsx}'],
    exclude: ['e2e/**', 'node_modules/**'],
    coverage: {
      provider: 'istanbul',
      reporter: ['text', 'html', 'lcov'],
      include: ['src/**'],
      exclude: ['**/*.test.{ts,tsx}', '**/*.d.ts'],
    },
  },
});
```

For a non-React project, set `environment: 'node'` and drop the setup file.

## vitest.setup.ts

```ts
import '@testing-library/jest-dom/vitest';
```

## playwright.config.ts

```ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  testMatch: '**/*.spec.ts',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: 'html',
  use: { trace: 'on-first-retry' },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
```

## GitHub CI

`.github/workflows/ci.yml` — runs on PRs and pushes to `main`. Swap `pnpm` and the setup steps for the detected package manager. Drop the e2e job if Playwright wasn't set up.

**Node version:** align CI with the project. Prefer `node-version-file: '.nvmrc'` (shown below) so there's one source of truth — if the repo has no `.nvmrc`/`.node-version`, create one from `engines.node` in `package.json` (or ask the user) and reference it. Only fall back to a pinned `node-version: '<major>'` if the user explicitly wants no version file.

```yaml
name: ci
on:
  push:
    branches: [main]
  pull_request:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: '.nvmrc'
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm typecheck
      - run: pnpm test:coverage
      - run: pnpm audit --audit-level high
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: '.nvmrc'
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm exec playwright install --with-deps
      - run: pnpm test:e2e
```

## release-please

`.github/workflows/release-please.yml`

```yaml
name: release-please
on:
  push:
    branches: [main]
permissions:
  contents: write
  pull-requests: write
jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          release-type: node
```

`release-please-config.json`

```json
{
  "packages": {
    ".": { "release-type": "node" }
  },
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json"
}
```

`.release-please-manifest.json`

```json
{ ".": "0.0.0" }
```

Set the manifest version to the package's current version. For a monorepo, add each package path to both `packages` and the manifest.
