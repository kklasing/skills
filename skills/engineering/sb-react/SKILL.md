---
name: sb-react
description: Sunbytes implementation guardrails for React projects. Covers component design, hooks, state management, performance, accessibility, and security. Apply whenever writing React code. Automatically includes all TypeScript standards from the sb-typescript skill.
---

# Sunbytes React

## When to apply

Trigger on `.tsx` files or any React component work. **Always** load [`sb-typescript`](../sb-typescript/SKILL.md) alongside this skill.

## Components

- Function components only. No class components.
- One component per file. File name = component name in `PascalCase.tsx`.
- Props go in a typed prop alias at the top of the file: `type FooProps = { ... }`. Don't inline anonymous prop types in the signature.
- Destructure props in the signature. No `props.foo` access inside the body.
- Type children as `ReactNode`, not `JSX.Element` or `ReactElement`.
- Don't export prop types unless another module legitimately needs them. Internal types stay internal.

## Hooks

- Follow the [Rules of Hooks](https://react.dev/reference/rules/rules-of-hooks). No conditional, looped, or nested hook calls.
- Custom hooks start with `use*` and return a stable object or tuple — pick one shape per hook and stick to it.
- `useEffect` is a last resort. Before reaching for it, ask: can this be derived during render, an event handler, or computed in a `useMemo`?
- Always include the full dependency array. Never silence the exhaustive-deps lint rule — fix the underlying issue (memoisation, ref, event handler).
- Don't sync external state with `useEffect` if a library exists for it (TanStack Query, Zustand, etc.).

## State management

- **Local first.** `useState` / `useReducer` until you have a concrete reason to lift.
- **Server state** belongs in TanStack Query (or framework data-fetching for Next.js — see `sb-nextjs`). Never store fetched data in `useState`.
- **Global UI state** uses Zustand. Avoid Context for anything that updates frequently — every consumer re-renders on every change.
- **Never store derived data in state.** Compute it during render or via `useMemo` if measurably expensive.
- **URL is state too.** Filter/sort/page state goes in the URL when it's meaningful to share or refresh.

## Performance

- Don't `memo` / `useMemo` / `useCallback` preemptively. Measure first. Most React perf problems are unnecessary state in the wrong place, not missing memoisation.
- Lists: stable `key` from data identity (e.g. `item.id`). Never the array index when items can be added, removed, or reordered.
- Lazy-load route-level chunks with `React.lazy` + `Suspense`. Don't lazy-load below the fold without a real bundle-size justification.
- Images: use the framework's image component (`next/image` in Next.js); otherwise set explicit `width`/`height` to avoid layout shift.

## Accessibility

- Use semantic HTML (`<button>`, `<nav>`, `<main>`, `<header>`) before reaching for `role`. A `<div onClick>` is never acceptable.
- Every interactive element must be keyboard-accessible. Tab order matches visual order.
- Form inputs have associated `<label htmlFor>` (or wrap the input). Placeholders are not labels.
- Run `eslint-plugin-jsx-a11y` and fix all warnings — don't disable rules.
- Test with the keyboard. If you can't operate the feature without a mouse, it isn't done.

## Security

- Never `dangerouslySetInnerHTML` with user-supplied content. If unavoidable, sanitize with DOMPurify and document why.
- Don't pass user input through `href` without protocol allowlisting (block `javascript:`, `data:`).
- `target="_blank"` always paired with `rel="noopener noreferrer"`.
- Secrets never appear in client code or `NEXT_PUBLIC_*` env vars. If it's bundled, it's public.

## Testing

- React Testing Library + Vitest (or Jest where the framework requires it).
- Query by accessible role and name (`getByRole('button', { name: /save/i })`), not test IDs. Test IDs are a last resort and a smell.
- Test what users see and do — not internal state, not implementation details.
- Co-locate tests next to components. See [`tdd`](../tdd/SKILL.md).

## Project layout

- Group by feature/domain, not by technical layer. `features/checkout/` (containing components, hooks, tests, types) beats `components/`, `hooks/`, `types/` siblings.
- Shared primitives live in `components/ui/` (or similar). Anything used by exactly one feature stays inside that feature folder.
