# sb-audit-nodejs — per-perspective checklist

Walk through every section. For each item, capture: (a) the finding, (b) evidence (file path, line, or analyzer output), (c) severity / effort / confidence. Skip items that don't apply (e.g. web-surface checks for a CLI tool) and note *why* in the report's **Methodology & gaps**.

## Maintainability

### TypeScript / JS quality
- [ ] `tsconfig.json`: `strict: true`? Note any disabled flags (`noImplicitAny`, `strictNullChecks`, etc.).
- [ ] Density of `// @ts-ignore` / `// @ts-expect-error` / `as any`. Flag the worst clusters.
- [ ] ESLint configured? Errors silenced via `// eslint-disable` clusters? Custom rules?
- [ ] Formatter (Prettier / Biome) configured?
- [ ] Unused exports — `npx -y ts-prune` if useful.

### Test coverage
- [ ] Test runner present and wired into CI?
- [ ] Coverage tracked? Unit vs. integration ratio sane?
- [ ] Critical paths (controllers, services, domain logic) without any tests?
- [ ] `*.spec.*` vs `*.test.*` consistency (Sunbytes convention: `.test.` unit, `.spec.` integration/e2e — see [`sb-write-vitest`](../sb-write-vitest/SKILL.md)).

### Module structure
- [ ] Madge cycles — every cycle is a maintainability bug.
- [ ] Files >500 lines, functions >100 lines, files juggling many concerns.
- [ ] Mixed concerns (HTTP + DB + business logic colocated where it shouldn't be).
- [ ] Shallow modules — interface nearly as complex as the implementation (see [`improve-codebase-architecture`](../improve-codebase-architecture/SKILL.md)).

### Tooling & process
- [ ] CI runs lint + type check + tests on every PR?
- [ ] Pre-commit hooks (Husky + lint-staged)?
- [ ] Lockfile committed and matching the package manager?
- [ ] `engines.node` pinned, `.nvmrc` present?
- [ ] Conventional-commit history (sample last ~50 commits)?
- [ ] README explains run / dev / test? `CONTEXT.md` / `docs/adr/` present?

### Dead weight
- [ ] depcheck **unused** deps — drop them.
- [ ] depcheck **missing** deps — implicit deps are a latent bug.
- [ ] Commented-out code blocks, TODO/FIXME density, debug `console.log`.

## Security

### Dependencies
- [ ] `npm audit` — list critical/high CVEs by package and fix path (direct vs transitive).
- [ ] Unmaintained packages: last publish >2y, archived repo, single-maintainer risk.
- [ ] Lockfile drift — `npm ci` reproducibility.

### Secrets
- [ ] `.env*` in `.gitignore`? `.env.example` committed?
- [ ] Hardcoded API keys, JWT secrets, DB credentials in source / configs / tests / fixtures?
- [ ] Secret-shaped strings in commit history (don't echo values; just count and locate).

### Web surface (skip if not applicable)
- [ ] Input validation at every trust boundary — DTOs, zod, class-validator?
- [ ] Authn / authz on every protected route?
- [ ] CSRF, CORS allowlist, Helmet (or equivalent), rate-limit?
- [ ] **SQL injection** — parameterised queries everywhere? Raw concatenation anywhere?
- [ ] **Command injection** — `child_process.exec`/`execSync` with user-influenced input?
- [ ] **SSRF** — outbound HTTP from user-supplied URLs without an allowlist?
- [ ] **Path traversal** — `fs` ops with user-supplied paths?
- [ ] **XSS** — React `dangerouslySetInnerHTML`, raw HTML in templates, `innerHTML` writes?
- [ ] **Insecure deserialization** — `eval`, `vm`, `Function()` on untrusted input?

### Crypto & runtime
- [ ] MD5 / SHA1 used for security purposes (signing, password hashing)?
- [ ] Weak randomness — `Math.random()` for tokens, IDs, password resets?
- [ ] JWT `alg=none`, weak secrets, no expiry?
- [ ] Outdated Node.js (EOL major version)?

## Scalability

### Event-loop hygiene
- [ ] Sync I/O (`readFileSync`, `execSync`, `crypto.pbkdf2Sync`) on request paths?
- [ ] CPU-heavy work on the main loop — no worker threads, no offload?
- [ ] Large `JSON.parse` / `JSON.stringify` on hot paths?

### Data access
- [ ] N+1 query smells — repo calls inside `.map`/`for` loops?
- [ ] Connection pooling configured? Pool size sane for the deployment shape?
- [ ] Indexes on filter columns (read schema / migrations)?
- [ ] Pagination on list endpoints? Unbounded `findMany` / `find()`?

### Caching & I/O
- [ ] HTTP responses cacheable but no `Cache-Control` headers?
- [ ] In-memory caches that break horizontal scaling (state pinned to one box)?
- [ ] Streams used for large payloads, or full-buffer reads?
- [ ] Backpressure on producer/consumer pipelines?

### Horizontal scaling
- [ ] Sticky sessions assumed? Session store in-process?
- [ ] Cron jobs / scheduled tasks — single-instance only or distributed-safe?
- [ ] WebSocket / SSE scaling — adapter for multi-node (Redis, etc.)?
- [ ] File uploads to local disk vs. object storage?

### Observability
- [ ] Structured logs (pino, winston, JSON) or `console.log` everywhere?
- [ ] Request IDs / trace context propagated?
- [ ] Metrics exposed (Prometheus, OTel)?
- [ ] Error tracking wired up (Sentry, etc.)?
- [ ] Liveness / readiness endpoints?

### Resource limits
- [ ] Container memory / CPU limits set in deploy config?
- [ ] Graceful shutdown on `SIGTERM` (drain connections, flush logs)?
- [ ] Long-lived intervals / event listeners that leak on hot reload or restart?
