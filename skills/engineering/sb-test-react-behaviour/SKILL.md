---
name: sb-test-react-behaviour
description: Backfill behaviour-focused tests for existing React components and custom hooks. Use this for repo-specific React test conventions and workflow. For Testing Library APIs, use react-testing-library. For Vitest mechanics, use vitest. Always load sb-react alongside this skill.
---

# Sunbytes - Test React behaviour

Use this for React components and custom hooks that already exist.

Always load [`sb-react`](../sb-react/SKILL.md) alongside this skill.
Use [`react-testing-library`](../react-testing-library/SKILL.md) when you need Testing Library API guidance.
Use [`vitest`](../vitest/SKILL.md) when you need runner, mocking, timer, snapshot, or config guidance.

## File conventions

- One test file per component, beside the source: `Counter.tsx` -> `Counter.test.tsx`.
- Use `*.test.tsx`, never `*.spec.*`. `.spec.` is reserved for integration/e2e.
- Custom hooks: `useCart.ts` -> `useCart.test.ts` with `renderHook`.
- One top-level `describe` per component or hook, named after it.

## What to test

- Test behaviour, not implementation.
- Focus on what the user sees and does.
- Do not assert on internal state, prop spreading, class names, or DOM structure.
- Do not snapshot whole components.
- If the test needs a query or interaction pattern, consult `react-testing-library`.

## Workflow

1. Read the component and any custom hooks it composes.
2. List the behaviours worth testing.
3. Confirm the behaviour list with the user before writing tests.
4. If the component needs providers, build a single `renderWithProviders` helper in the test file.
5. Write tests one behaviour at a time.
6. Run the full file at the end and verify there are no type errors.

## Test quality

- Use AAA structure: Arrange, Act, Assert.
- Keep one concept per test.
- Test names should describe behaviour.
- Mock only at the boundary.
- Cleanup is automatic with RTL + Vitest jsdom.

## Setup expectations

- `vitest.config` sets `environment: 'jsdom'` or `'happy-dom'` and `restoreMocks: true`.
- The setup file imports `@testing-library/jest-dom/vitest`.

See [`PATTERNS.md`](PATTERNS.md) for provider wrappers, async UI, forms, `renderHook`, mocking network/router/store, callback assertions, fake timers, and accessibility checks.
