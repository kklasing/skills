---
name: sb-nextjs
description: Sunbytes implementation guardrails for Next.js (App Router) projects. Covers Server/Client Components, caching, routing, security headers, and Next.js 16 best practices. Apply whenever writing Next.js code. Automatically includes all React and TypeScript standards.
---

# Sunbytes Next.js

## When to apply

Trigger on Next.js projects (`next.config.{js,ts,mjs}`, `app/` directory, `@next/*` or `next/*` imports). **Always** load [`sb-react`](../sb-react/SKILL.md) and [`sb-typescript`](../sb-typescript/SKILL.md) alongside.

## App Router only

- New code goes in `app/`. Don't add to `pages/` even if it exists for legacy reasons — flag the migration if it blocks you.
- Co-locate route-specific UI inside the route segment folder, not in a global `components/`.
- Use the file conventions Next provides: `loading.tsx`, `error.tsx`, `not-found.tsx`, `route.ts`. Don't reinvent them.

## Server vs Client Components

- **Default to Server Components.** Add `'use client'` only when you need state, effects, browser APIs, refs to DOM, or event handlers.
- **Push `'use client'` as deep as possible.** A small leaf client component beats a whole page marked client.
- Server Components can be `async` and fetch directly. Don't introduce a route handler if the page can fetch inline.
- Don't pass non-serialisable values (functions, class instances, Dates without care) from Server to Client Components.

## Data fetching & mutations

- `fetch` in Server Components — Next handles dedup and caching.
- **Be explicit about cache.** Pass `{ cache: 'force-cache' | 'no-store' }` and/or `{ next: { revalidate: N, tags: [...] } }`. Don't rely on framework defaults silently — they shift between Next versions.
- Mutations via Server Actions, not custom POST routes, unless the endpoint must be public/external.
- After mutations, call `revalidatePath` or `revalidateTag`. Don't leave stale cache.
- Server state on the client uses TanStack Query against Server Actions or route handlers. Don't roll your own `useEffect` fetcher.

## Routing

- Loading UI in `loading.tsx`, errors in `error.tsx`, 404s in `not-found.tsx`. One per segment as needed.
- Parallel + intercepting routes for modals — don't store modal open state in URL search params unless the modal is genuinely deep-linkable.
- Dynamic params are async (Next 15+): `{ params }: { params: Promise<{ id: string }> }`. Same for `searchParams`.
- Validate dynamic params with Zod at the top of the page/route handler. Treat them as untrusted input.

## Security headers

Set in `next.config` via `headers()`:

- `Content-Security-Policy` with nonces for inline scripts. Use Next's middleware to inject the nonce per request.
- `Strict-Transport-Security: max-age=63072000; includeSubDomains; preload`.
- `X-Frame-Options: DENY` and `X-Content-Type-Options: nosniff`.
- `Referrer-Policy: strict-origin-when-cross-origin`.
- `Permissions-Policy` denying every feature the app doesn't use (camera, microphone, geolocation, etc.).

## Env vars

- All env access goes through a single `env.ts` parsed with Zod (see [sb-typescript](../sb-typescript/SKILL.md)). The app must fail to boot on invalid env.
- `NEXT_PUBLIC_*` is for values that are **safe in the browser**. Default to server-side. If unsure, it's not public.
- Never read `process.env` in a Client Component. The build will silently miss it or inline a stale value.

## Images, fonts, scripts

- `next/image` always for app content. Never raw `<img>` except for tiny icons inlined as SVG.
- `next/font` for self-hosted fonts. No `<link>` to Google Fonts (perf and privacy).
- Third-party scripts go through `next/script` with the right `strategy` (`afterInteractive` is usually correct, `beforeInteractive` only for things that block render).

## Middleware

- Keep it small — runs on every matching request. Heavy logic belongs in route handlers or Server Actions.
- Use `matcher` to scope it tightly. A broad matcher tanks edge perf.
- Auth checks fine here; anything that needs Node APIs is not (middleware runs on the Edge runtime).

## Error handling

- `error.tsx` per segment for recoverable errors. `global-error.tsx` only for the root shell.
- Server Actions return typed `{ ok: true, data } | { ok: false, error }` results — don't throw across the boundary unless it's an unexpected failure.
- Log unexpected errors with structured context (request ID, user ID, route).

## Testing

- Component tests with React Testing Library + Vitest.
- Server Actions and route handlers: integration test against a running dev server using Playwright, or unit-test the handler function directly with mocked `Request`.
- E2E (Playwright) for the critical user paths only — auth, checkout, key conversions. Don't try to E2E everything.
