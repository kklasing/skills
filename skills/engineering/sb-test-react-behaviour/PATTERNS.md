# React behaviour test patterns

Concrete recipes for the cases that come up most when backfilling React component tests. Stack: Vitest + `@testing-library/react` + `@testing-library/user-event`.

## Render helper with providers

If the component reads from a provider (TanStack Query, Router, theme), build one helper in the test file instead of repeating boilerplate.

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { MemoryRouter } from 'react-router-dom';
import { render, type RenderOptions } from '@testing-library/react';
import type { ReactElement, ReactNode } from 'react';

function renderWithProviders(ui: ReactElement, options?: RenderOptions) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  const Wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>{children}</MemoryRouter>
    </QueryClientProvider>
  );

  return render(ui, { wrapper: Wrapper, ...options });
}
```

Disable retries on the test `QueryClient` — otherwise rejected fetches stall the test.

## Setting up `userEvent`

Call `userEvent.setup()` once per test so typing and clicks share a consistent pointer/keyboard session.

```tsx
it('submits the form when the user fills both fields and clicks save', async () => {
  const user = userEvent.setup();
  const onSave = vi.fn();
  render(<Form onSave={onSave} />);

  await user.type(screen.getByLabelText(/name/i), 'Ada');
  await user.type(screen.getByLabelText(/email/i), 'ada@example.com');
  await user.click(screen.getByRole('button', { name: /save/i }));

  expect(onSave).toHaveBeenCalledWith({ name: 'Ada', email: 'ada@example.com' });
});
```

## Async UI — `findBy*` over `waitFor`

`findBy*` is `getBy* + waitFor` in one call. Reach for it first; only fall back to `waitFor` for assertions `findBy` can't express.

```tsx
it('shows the loaded items after fetching', async () => {
  renderWithProviders(<ItemsList />);

  expect(screen.getByRole('status', { name: /loading/i })).toBeInTheDocument();

  const items = await screen.findAllByRole('listitem');
  expect(items).toHaveLength(3);
});

it('clears the error banner once the retry succeeds', async () => {
  const user = userEvent.setup();
  renderWithProviders(<ItemsList />);

  await user.click(await screen.findByRole('button', { name: /retry/i }));

  await waitFor(() =>
    expect(screen.queryByRole('alert')).not.toBeInTheDocument(),
  );
});
```

Use `queryBy*` (not `getBy*`) when asserting absence — `getBy*` throws if the element is missing.

## Forms — typing, validation, submission

```tsx
it('shows a validation error when email is blank on submit', async () => {
  const user = userEvent.setup();
  render(<SignupForm onSubmit={vi.fn()} />);

  await user.click(screen.getByRole('button', { name: /sign up/i }));

  expect(
    await screen.findByText(/email is required/i),
  ).toBeInTheDocument();
});

it('clears the email error once a valid email is typed', async () => {
  const user = userEvent.setup();
  render(<SignupForm onSubmit={vi.fn()} />);

  await user.click(screen.getByRole('button', { name: /sign up/i }));
  expect(await screen.findByText(/email is required/i)).toBeInTheDocument();

  await user.type(screen.getByLabelText(/email/i), 'ada@example.com');

  expect(screen.queryByText(/email is required/i)).not.toBeInTheDocument();
});
```

For native `<select>` use `user.selectOptions`. For custom comboboxes/listboxes, click the trigger then click the option by name — never reach for the DOM directly.

## Asserting on callback props

Assert that the callback received the right shape, not that "something was called".

```tsx
it('calls onSelect with the clicked item id', async () => {
  const user = userEvent.setup();
  const onSelect = vi.fn();
  render(<ItemList items={[{ id: 'a1', label: 'Apple' }]} onSelect={onSelect} />);

  await user.click(screen.getByRole('button', { name: /apple/i }));

  expect(onSelect).toHaveBeenCalledExactlyOnceWith('a1');
});
```

## Testing custom hooks with `renderHook`

Custom hooks are tested by their public return value, not their internals. Wrap state updates in `act`.

```ts
// src/useCounter.test.ts
import { describe, expect, it } from 'vitest';
import { act, renderHook } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('starts at the initial value', () => {
    const { result } = renderHook(() => useCounter(5));

    expect(result.current.count).toBe(5);
  });

  it('increments when increment() is called', () => {
    const { result } = renderHook(() => useCounter(0));

    act(() => result.current.increment());

    expect(result.current.count).toBe(1);
  });
});
```

For hooks that need providers (e.g. `useQuery`), pass `{ wrapper: Wrapper }` to `renderHook` — same wrapper you'd use in `renderWithProviders`.

## Mocking the network layer

Two acceptable approaches. Prefer MSW for anything non-trivial.

**MSW (preferred)** — define handlers once in `test/msw/handlers.ts`, start the server in your Vitest setup file, override handlers per test with `server.use(...)`.

```ts
import { http, HttpResponse } from 'msw';
import { server } from '../test/msw/server';

it('shows the empty state when the API returns no items', async () => {
  server.use(http.get('/api/items', () => HttpResponse.json([])));

  renderWithProviders(<ItemsList />);

  expect(await screen.findByText(/no items yet/i)).toBeInTheDocument();
});
```

**`vi.mock` of the fetch client** — fine for a single-call component, awkward for complex flows.

```ts
import { fetchItems } from './api';
vi.mock('./api');

it('renders the items returned by the API', async () => {
  vi.mocked(fetchItems).mockResolvedValue([{ id: 'a1', label: 'Apple' }]);

  renderWithProviders(<ItemsList />);

  expect(await screen.findByRole('listitem', { name: /apple/i })).toBeInTheDocument();
});
```

Never mock a child component of your own — render the real one. If a child is too heavy to render, that's a design smell to surface, not paper over.

## Router-aware assertions

For a component that navigates, render inside `MemoryRouter` with `initialEntries` and assert via what the user sees after navigation. Don't reach into router internals.

```tsx
it('navigates to the item detail page when an item is clicked', async () => {
  const user = userEvent.setup();
  render(
    <MemoryRouter initialEntries={['/items']}>
      <Routes>
        <Route path="/items" element={<ItemsList items={[{ id: 'a1', label: 'Apple' }]} />} />
        <Route path="/items/:id" element={<h1>Item detail</h1>} />
      </Routes>
    </MemoryRouter>,
  );

  await user.click(screen.getByRole('link', { name: /apple/i }));

  expect(screen.getByRole('heading', { name: /item detail/i })).toBeInTheDocument();
});
```

## Fake timers around `userEvent`

`userEvent.setup` needs to know if timers are fake — otherwise typing hangs forever.

```ts
beforeEach(() => vi.useFakeTimers());
afterEach(() => vi.useRealTimers());

it('debounces the search input by 300ms', async () => {
  const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });
  const onSearch = vi.fn();
  render(<Search onSearch={onSearch} delay={300} />);

  await user.type(screen.getByRole('searchbox'), 'ada');
  expect(onSearch).not.toHaveBeenCalled();

  await act(async () => {
    vi.advanceTimersByTime(300);
  });

  expect(onSearch).toHaveBeenCalledExactlyOnceWith('ada');
});
```

## Accessibility smoke checks

If the component is interactive, add at least one assertion that uses the accessibility tree:

- `getByRole('button', { name: /save/i })` — proves the button has an accessible name.
- `getByLabelText(/email/i)` — proves the input is labelled.

If you find yourself reaching for `getByTestId`, the component probably needs an `aria-label`, a visible label, or a semantic element instead. Fix that before adding the test id.
