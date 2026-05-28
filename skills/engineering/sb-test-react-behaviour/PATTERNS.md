# React behaviour test patterns

Concrete recipes for backfilling React component tests.

For query semantics, user-event details, async helpers, `within`, `renderHook`, debugging, and RTL configuration, use [`react-testing-library`](../react-testing-library/SKILL.md).
For mocking, timers, and other Vitest mechanics, use [`vitest`](../vitest/SKILL.md).

## Render helper with providers

If the component reads from a provider, build one helper in the test file instead of repeating boilerplate.

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

## Forms

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

## Async UI

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

## Callback props

```tsx
it('calls onSelect with the clicked item id', async () => {
  const user = userEvent.setup();
  const onSelect = vi.fn();
  render(<ItemList items={[{ id: 'a1', label: 'Apple' }]} onSelect={onSelect} />);

  await user.click(screen.getByRole('button', { name: /apple/i }));

  expect(onSelect).toHaveBeenCalledExactlyOnceWith('a1');
});
```

## Custom hooks

```ts
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

## Network

Prefer MSW for anything non-trivial.

```ts
it('shows the empty state when the API returns no items', async () => {
  server.use(http.get('/api/items', () => HttpResponse.json([])));

  renderWithProviders(<ItemsList />);

  expect(await screen.findByText(/no items yet/i)).toBeInTheDocument();
});
```

## Router

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

## Fake timers

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

## Accessibility checks

If the component is interactive, add at least one assertion that uses the accessibility tree:

- `getByRole('button', { name: /save/i })`
- `getByLabelText(/email/i)`

If you need `getByTestId`, treat that as a signal to improve the component first.
