---
name: testing
description: General testing entry point for existing code and test reviews. Use when you need to write, backfill, audit, or verify tests for compliance with routed testing skills.
---

# Testing

Use this skill as the first stop when the user asks for tests and you want a single entry point.

## Route by task

- React component or hook behaviour tests: use [`sb-test-react-behaviour`](../sb-test-react-behaviour/SKILL.md) and [`sb-react`](../sb-react/SKILL.md).
- Unit tests for functions, modules, or utilities: use [`sb-write-vitest`](../sb-write-vitest/SKILL.md).
- Tests before implementation: use [`tdd`](../tdd/SKILL.md).
- Vitest runner, mocking, timers, snapshots, config: use [`vitest`](../vitest/SKILL.md).
- Testing Library queries, user events, async helpers, debugging: use [`react-testing-library`](../react-testing-library/SKILL.md).

## Keep it thin

- Do not restate detailed rules from the routed skills.
- Load only the next skill needed for the task.
- If the request is ambiguous, choose the narrowest applicable skill and continue.
