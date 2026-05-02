---
name: sb-nestjs
description: Sunbytes implementation guardrails for NestJS (v10/11) projects. Covers modules, dependency injection, controllers, services, DTOs, validation, guards, security, database patterns, and Sunbytes coding standards. Apply whenever writing NestJS code. Automatically includes all TypeScript standards.
---

# Sunbytes Nest.js

## When to apply

Trigger on Nest.js projects (`@nestjs/*` imports, `nest-cli.json`, `*.module.ts` files, decorators like `@Controller`, `@Injectable`, `@Module`). **Always** load [`sb-typescript`](../sb-typescript/SKILL.md) alongside.

## Module organisation

- One module per **bounded context** (`UsersModule`, `BillingModule`, `NotificationsModule`), not per technical layer (`ServicesModule`, `ControllersModule` — never).
- Module file co-located with its controller, services, and DTOs. Folder = module.
- The module's public API is what the module file `exports`. Nothing else should be imported across module boundaries — enforce with ESLint `no-restricted-imports` if needed.
- Cross-module communication via injected interfaces or events, not direct service-to-service imports across contexts.

## Dependency injection

- Constructor injection only. No property injection (`@Inject()` on fields).
- Class providers by default. `useFactory` only when construction needs runtime config.
- `@Injectable({ scope: Scope.DEFAULT })` (singleton) — avoid `Scope.REQUEST` unless you've measured a real need. It disables caching and tanks throughput.
- Depend on **interfaces (abstract classes)**, not concrete services, for things that cross context boundaries (repositories, external clients). Bind the interface to the implementation in the module's `providers`.

## Controllers

- **Thin.** Controller methods do exactly: parse input → call service → shape response. No business logic.
- One concern per controller. Split when paths diverge.
- Use Nest decorators (`@Get`, `@Post`, `@Param`, `@Body`, `@Query`) — never hand-roll routing or parsing.
- Status codes via `@HttpCode()`. Default `201` for `POST` is rarely what you want — be explicit.
- No raw `req`/`res` access unless streaming or doing something Nest doesn't model. If you reach for `@Res()`, leave a comment explaining why.

## DTOs and validation

- Every controller input is a **class DTO** with `class-validator` decorators on every field.
- Global `ValidationPipe` configured with `{ whitelist: true, forbidNonWhitelisted: true, transform: true, transformOptions: { enableImplicitConversion: false } }`.
- Output DTOs via `class-transformer` + `@Expose()` / `@Exclude()`. Register `ClassSerializerInterceptor` globally so secrets never leak into responses.
- **Never reuse entity classes as DTOs.** It binds your transport schema to your DB schema and leaks columns by default.
- Don't accept arbitrary `Record<string, unknown>` payloads. If the shape is dynamic, validate the discriminator and switch.

## Guards, interceptors, pipes

- **Guards = authorisation.** "Can this caller do this?" One guard per concern (auth, role, ownership). Compose at the route.
- **Interceptors = cross-cutting concerns** (logging, timing, response transforms). Don't mutate request state in interceptors — use middleware or guards.
- **Pipes = transform/validate input.** Custom pipes only when `ValidationPipe` isn't enough.
- **Middleware** for things that touch the raw request (correlation IDs, body size limits) before Nest's pipeline.

## Configuration

- `@nestjs/config` with a Zod schema in `validate`. The app must fail to boot on invalid config.
- Inject `ConfigService<Config, true>` typed via `ConfigType<typeof myConfig>`. No string keys (`config.get('FOO')`) without typing — they rot silently.
- Group config by domain (`databaseConfig`, `authConfig`, `mailerConfig`), not one giant flat object.

## Database

- One repository per aggregate root. Repositories return **domain objects**, not ORM entities, when the domain layer is non-trivial.
- Transactions are **explicit**. Use the ORM's transaction API (`DataSource.transaction`, Prisma `$transaction`, Drizzle `db.transaction`). No request-scoped transaction magic.
- Migrations checked into the repo and run in CI on a clean DB. Never `synchronize: true` outside local dev — ever.
- Seed data goes through migrations or a dedicated seed script, never inline in module bootstrap.

## Errors

- Throw Nest's `HttpException` subclasses (`BadRequestException`, `NotFoundException`, etc.) at the **controller boundary** only.
- **Domain errors** are plain `Error` subclasses defined in the domain layer. A global exception filter maps them to HTTP responses — services and domain code don't know HTTP exists.
- Don't swallow errors in services. If you catch, you handle or you re-throw.

## Security

- `helmet()` global middleware.
- Rate limiting via `@nestjs/throttler` on auth endpoints, write endpoints, and anything expensive. Different limits per route group.
- CORS configured **explicitly per environment**. Never `origin: '*'` in production. Don't reflect arbitrary origins.
- Auth tokens validated by a guard, not parsed in controllers. Token verification logic lives in one place.
- **Log redaction.** Scrub `password`, `token`, `authorization`, `cookie`, `secret` keys before any log call. Use `nestjs-pino`'s redaction config.
- SQL via the ORM only. No `query()` with template strings.

## Logging

- `nestjs-pino` (or Nest's `Logger` for very small apps). Never `console.*`.
- Structured JSON logs in non-dev environments.
- Correlation ID per request — pino-http handles this with a middleware.
- Log at the boundary: one `info` per request in/out, `warn` for handled-but-notable situations, `error` for unhandled failures with stack.

## Testing

- Unit tests with Jest (Nest's default) — mock at module-edge interfaces, not internal collaborators. See [`tdd`](../tdd/SKILL.md).
- E2E tests in `test/` using `@nestjs/testing` + `supertest`. Hit a **real database** via testcontainers. Never mock the repository in E2E tests — that's the bug surface you most need to catch.
- Don't unit-test controllers as units. Their value is integration with pipes/guards/filters, which only the E2E test exercises.
