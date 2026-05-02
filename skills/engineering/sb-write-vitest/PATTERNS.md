# Vitest patterns

Concrete recipes for the cases that come up most when backfilling unit tests.

## Mocking a module

```ts
import { describe, expect, it, vi } from 'vitest';
import { readFileSync } from 'node:fs';
import { loadConfig } from './config';

vi.mock('node:fs', async (importOriginal) => {
  const actual = await importOriginal<typeof import('node:fs')>();
  return {
    ...actual,
    readFileSync: vi.fn(),
  };
});

describe('loadConfig', () => {
  it('parses the JSON returned by readFileSync', () => {
    vi.mocked(readFileSync).mockReturnValue('{"flag":true}');

    expect(loadConfig()).toEqual({ flag: true });
  });
});
```

`vi.mock()` is hoisted to the top of the file by Vitest, so it runs before the imports it shadows. To use a value defined in the test file inside the factory, wrap that value with `vi.hoisted(() => ...)`:

```ts
const fakeNow = vi.hoisted(() => new Date('2026-01-01'));
vi.mock('./clock', () => ({ now: () => fakeNow }));
```

## Spying on a method

```ts
import { afterEach, expect, it, vi } from 'vitest';
import { logger } from './logger';
import { deprecated } from './deprecated';

afterEach(() => vi.restoreAllMocks());

it('logs a deprecation warning', () => {
  const warn = vi.spyOn(logger, 'warn').mockImplementation(() => {});

  deprecated();

  expect(warn).toHaveBeenCalledWith(expect.stringContaining('deprecated'));
});
```

Prefer `restoreMocks: true` in `vitest.config` so you don't have to remember `restoreAllMocks` in every file.

## Fake timers

```ts
import { afterEach, beforeEach, expect, it, vi } from 'vitest';
import { debounce } from './debounce';

beforeEach(() => vi.useFakeTimers());
afterEach(() => vi.useRealTimers());

it('only fires once after the wait window elapses', () => {
  const fn = vi.fn();
  const debounced = debounce(fn, 100);

  debounced();
  debounced();
  vi.advanceTimersByTime(99);
  expect(fn).not.toHaveBeenCalled();

  vi.advanceTimersByTime(1);
  expect(fn).toHaveBeenCalledOnce();
});
```

For code that mixes timers with real async work, pass `{ shouldAdvanceTime: true }` to `useFakeTimers`.

## Polling for async state

```ts
import { expect, it } from 'vitest';
import { bus } from './bus';

it('eventually publishes the done event', async () => {
  bus.emit('start');

  await expect.poll(() => bus.lastEvent, { timeout: 1000 }).toBe('done');
});
```

`expect.poll` retries the getter until the matcher passes or the timeout expires. Prefer it over `setTimeout` + assert.

## Asserting on thrown errors

```ts
import { expect, it } from 'vitest';
import { parse, loadAsync } from './parser';
import { EmptyInputError } from './errors';

it('throws EmptyInputError on empty input', () => {
  expect(() => parse('')).toThrow(EmptyInputError);
});

it('rejects when the upstream times out', async () => {
  await expect(loadAsync()).rejects.toThrow(/timeout/);
});
```

For sync code use `expect(() => fn()).toThrow(...)`; for async use `expect(promise).rejects.toThrow(...)`.

## Parameterized cases

```ts
import { expect, it } from 'vitest';
import { slugify } from './slugify';

it.each([
  { input: 'Hello World', expected: 'hello-world' },
  { input: '  trim  me  ', expected: 'trim-me' },
  { input: 'Æther', expected: 'aether' },
])('slugify($input) → $expected', ({ input, expected }) => {
  expect(slugify(input)).toBe(expected);
});
```

## React components (with Testing Library)

```ts
// src/Counter.test.tsx
import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Counter } from './Counter';

describe('<Counter>', () => {
  it('increments the visible count when the button is clicked', async () => {
    render(<Counter />);

    await userEvent.click(screen.getByRole('button', { name: /increment/i }));

    expect(screen.getByText('1')).toBeInTheDocument();
  });
});
```

Set `environment: 'jsdom'` (or `'happy-dom'`) in `vitest.config`, and import `'@testing-library/jest-dom/vitest'` in your setup file so matchers like `toBeInTheDocument` are typed correctly.

## Snapshots

Use snapshots sparingly — they're great for stable serialized output (e.g. a config object, a small DOM fragment) and terrible for anything that changes often. Prefer `toMatchInlineSnapshot()` over file snapshots so the expected value is visible in the test.

```ts
expect(buildHeaders({ auth: 'token' })).toMatchInlineSnapshot(`
  {
    "authorization": "Bearer token",
    "content-type": "application/json",
  }
`);
```
