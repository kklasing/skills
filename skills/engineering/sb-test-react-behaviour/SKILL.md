---
name: sb-test-react-behaviour
description: Backfill behaviour-focused tests for React components in `.tsx` files using Vitest, React Testing Library, and `@testing-library/user-event`. Tests focus on what users see and do — clicks, typing, form submission, async UI, provider-wrapped components, and custom hooks via `renderHook`. Tests live beside the component using `*.test.tsx` (never `*.spec.*` — `.spec.` is reserved for integration/e2e). Use when the user wants to add tests for an existing React component or custom hook. Skip and use `tdd` instead when writing tests *before* the component exists. Skip and use `sb-write-vitest` when testing plain `.ts` modules.
---

# Sunbytes — Test React behaviour

For React components and custom hooks that **already exist**. If the user is writing tests *before* the implementation, stop and use [`tdd`](../tdd/SKILL.md). For non-React `.ts` modules, use [`sb-write-vitest`](../sb-write-vitest/SKILL.md). Always load [`sb-react`](../sb-react/SKILL.md) alongside this skill.

## File conventions

- One test file per component, **beside** the source: `Counter.tsx` → `Counter.test.tsx`.
- Use `*.test.tsx`, never `*.spec.*`. `.spec.` is reserved for integration/e2e.
- Custom hooks: `useCart.ts` → `useCart.test.ts` (use `renderHook`).
- One top-level `describe` per component or hook, named after it: `describe('<Counter>', ...)` or `describe('useCart', ...)`.

## What to test — and what not to

- **Test behaviour, not implementation.** What the user sees on screen and what happens when they interact. Survive an internal refactor that preserves observable behaviour.
- **Do not** assert on internal state, hook return values from inside a component, prop spreading, class names, or DOM structure.
- **Do not** snapshot whole components — snapshots invite churn and hide regressions. Use inline snapshots only for small, stable serialised output.
- **Query by accessibility.** Prefer `getByRole(name)`, `getByLabelText`, `getByText` — in that order. `getByTestId` is a last resort and a smell.
- **`userEvent`, not `fireEvent`.** `userEvent` simulates real keyboard/pointer behaviour (focus, bubbling, debounce-friendly). Always `await` it.

## Workflow

1. **Read the component** and any custom hooks it composes. Note: rendered output for each prop combination, interactive elements, async data, context dependencies.
2. **List behaviours worth testing.** What the user can *do* and what they *see*. Examples: "shows a loading skeleton while fetching", "disables submit until both fields are filled", "calls `onSelect` with the clicked item id".
3. **Confirm the behaviour list with the user before writing tests.** Ask which behaviours matter most and whether any can be skipped.
4. **Decide on test setup.** If the component needs providers (TanStack Query, Router, theme), build a single `renderWithProviders` helper in the test file. Don't repeat boilerplate per test.
5. **Write tests one behaviour at a time.** Run `vitest run path/to/Foo.test.tsx` after each, confirm green, move on.
6. **Run the full file at the end** and verify there are no type errors.

## Test quality

- **AAA structure** — Arrange (`render`), Act (`await userEvent.*`), Assert (`expect(screen.*)`). Blank line between.
- **One concept per test.** If the test name needs "and", split it.
- **Test names describe behaviour** — `it('disables submit until both fields are filled')`, not `it('handles the disabled state')` or `it('works')`.
- **Mock only at the boundary.** Network (MSW or `vi.mock` of the fetch client), time, third-party SDKs. Don't mock child components or hooks from your own codebase — render the real thing.
- **Async-aware queries.** Use `findBy*` for elements that appear after an async operation. Use `waitFor` only when asserting absence-then-presence isn't expressible as `findBy*`. Never `setTimeout`.
- **Cleanup is automatic** with RTL + Vitest's jsdom env — don't call `cleanup()` yourself.

## Minimal example

```tsx
// src/Counter.test.tsx
import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Counter } from './Counter';

describe('<Counter>', () => {
  it('increments the visible count when the increment button is clicked', async () => {
    render(<Counter />);

    await userEvent.click(screen.getByRole('button', { name: /increment/i }));

    expect(screen.getByRole('status')).toHaveTextContent('1');
  });
});
```

## Setup expectations

- `vitest.config` sets `environment: 'jsdom'` (or `'happy-dom'`) and `restoreMocks: true`.
- Setup file imports `'@testing-library/jest-dom/vitest'` so matchers like `toBeInTheDocument` are typed.

See [PATTERNS.md](PATTERNS.md) for: provider wrappers, async UI, forms, `renderHook`, mocking network/router/store, and asserting on callbacks.
