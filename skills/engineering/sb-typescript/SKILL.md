---
name: sb-typescript
description: Sunbytes implementation guardrails for TypeScript code. Covers strict typing, modern TS patterns, async, security, SOLID/KISS/DRY principles, testing, and Sunbytes coding standards. Apply whenever writing or generating TypeScript code.
---

# Sunbytes TypeScript

## When to apply

Trigger on any work in `.ts` / `.tsx` files, or when the user asks to write or edit TypeScript. This is the base skill — `sb-react`, `sb-nextjs`, and `sb-nestjs` build on it and should be loaded alongside when the project matches.

## Core typing

- **Strict mode always.** `tsconfig` has `strict: true`, `noUncheckedIndexedAccess: true`, `exactOptionalPropertyTypes: true`, `noImplicitOverride: true`.
- **No `any`.** Use `unknown` and narrow with type guards. If `any` is unavoidable, leave a one-line comment explaining why.
- **No non-null assertions (`!`)** and no `as` casts except when narrowing from `unknown` after a guard, or for `as const`.
- **`type` over `interface`** for new code. Use `interface` only when extending classes or library shapes that require it (declaration merging).
- **Named exports only.** No default exports — they break refactoring tools and autocomplete.
- **No enums.** Use union literals (`type Status = 'pending' | 'done'`) or `as const` objects with a derived value type.
- **`readonly` by default** for arrays and object properties that aren't mutated. `ReadonlyArray<T>` for inputs.

## Async

- `async`/`await` everywhere. No raw `.then()` chains.
- Always handle rejections — `await` inside `try`/`catch`, or `Promise.allSettled` for fan-out where partial failure is acceptable.
- Never `await` inside a loop when the work is independent. Use `Promise.all`.
- Don't return `Promise<Promise<T>>` — TS flattens, but the code reads wrong. `return await` or restructure.

## Errors

- Throw `Error` (or a subclass), never strings, numbers, or plain objects.
- Use a discriminated `Result<T, E>` type only for *expected* failure paths (validation, lookups, parsing). Throw for programmer errors and infra failures — don't make every caller carry a `Result`.
- Catch narrowly. If you can't act on an error, don't catch it.

## Naming

- `camelCase` for variables, functions, methods.
- `PascalCase` for types, classes, components.
- `SCREAMING_SNAKE_CASE` only for module-level constants that are truly constant.
- Booleans: `is*`, `has*`, `should*`, `can*`.
- Functions: verb-first (`getUser`, `parseConfig`, `assertNever`).

## Module hygiene

- One concept per file. The file name matches the primary export.
- **No barrel files.** `index.ts` re-exports break tree-shaking, slow type checking, and create circular import risk.
- Path aliases via `tsconfig` `paths` (e.g. `@/lib/...`), not deep relative imports (`../../../`).
- Group imports: node built-ins, then third-party, then internal aliases, then relative — separated by blank lines.

## Boundaries & security

- Validate everything crossing a system boundary with Zod (or `class-validator` in Nest). Boundaries: HTTP requests, env vars, file/IO, message queues, anything from `JSON.parse`.
- `process.env` access is forbidden outside a single `env.ts` that parses + validates with Zod and exports a typed object. Import the typed object everywhere else.
- Never `eval`, `new Function`, or template-string SQL. Use the ORM or a parameterised driver.
- Don't log secrets. Redact `password`, `token`, `authorization`, `cookie` before any structured-log call.

## SOLID / KISS / DRY (in that priority order)

- **KISS first.** Three similar lines beats a wrong abstraction. Don't extract until you have at least three real call sites with the same shape.
- **Single responsibility per module.** If the file describes itself with "and", split it.
- **Inversion of dependencies at boundaries.** Domain code depends on interfaces; concrete adapters live at the edge (HTTP, DB, third-party SDKs).
- **DRY only after KISS.** Premature abstractions are a bigger long-term cost than duplication.

## Testing

- Co-locate tests next to source: `foo.ts` ↔ `foo.test.ts`.
- Test behaviour through the public API. Don't reach into internals to set up state.
- See [`tdd`](../tdd/SKILL.md) for the red-green-refactor loop.
- Vitest for libraries and frontends; Jest where the framework dictates (e.g. Nest).

## Tooling baseline

- `tsconfig` extends a shared base (`@tsconfig/strictest` or equivalent).
- ESLint with `@typescript-eslint`, `import/no-cycle`, `import/no-default-export` rules on.
- Prettier for formatting — never argue style in PRs.
- Type-check in CI (`tsc --noEmit`) separately from build, so type errors fail fast.
