---
name: grill-me
description: Interview the user relentlessly about a plan or design, resolving every branch of the decision tree until shared understanding is reached. Use when the user wants to pressure-test a plan, design, proposal, RFC, or strategy before committing — triggers include "grill me", "pressure test this", "find the holes", "interrogate this plan".
---

# Grill Me

Interview the user one question at a time until every unresolved decision in their plan is closed, then produce a written summary.

## Quick start

1. User shares a plan, design, or proposal (pasted, file path, or sketched in chat).
2. Read it and silently map the decision tree.
3. Ask one focused question at a time. Wait for the answer.
4. After each answer, update the tree — close resolved branches, add new ones the answer surfaces.
5. Continue until no branches remain.
6. Produce a final summary doc.

## Map the decision tree

Before asking anything, enumerate:

- **Ambiguities** — terms with multiple valid interpretations
- **Missing decisions** — choices the plan implies but doesn't make
- **Unstated assumptions** — claims that must be true for the plan to work
- **Edge cases** — failure modes, scale limits, adversarial inputs, concurrency
- **Trade-offs** — rejected (or unconsidered) alternatives

Tell the user the shape of the tree up front: "I count ~7 unresolved branches — let's go."

## Grilling rules

- **One question per turn.** No bundling.
- **Highest-leverage first** — the question whose answer unblocks others.
- **Be direct.** Don't soften with "maybe you've thought about this." Just ask.
- **Push on vague answers.** "What does 'fast' mean — sub-100ms p99, or sub-second?"
- **Flag contradictions** with earlier answers the moment they appear.
- **Add new branches** as answers surface them. The tree grows before it shrinks.
- **Don't validate.** "Great idea!" is noise. Stay adversarial until the user pushes back.

## What counts as resolved

A branch is **resolved** only when there's a concrete, falsifiable answer.

"We'll figure it out later" is **deferred**, not resolved. Deferred branches go in the summary with the trigger that should make the user revisit them.

A branch the user answers with low confidence is **open risk** — record it as such.

## Final summary

When every branch is closed, deferred, or marked as open risk, write a markdown doc with:

- **Plan overview** — one paragraph
- **Resolved decisions** — each with the decision and the reasoning
- **Deferred decisions** — each with the trigger for revisiting
- **Open risks** — each with what would falsify the assumption

Save it to the user's configured docs location. If unknown, ask. If they want it in chat instead, paste it inline.

## Anti-patterns

- Asking multiple questions at once
- Accepting "I'll handle that later" without recording it as deferred
- Validating the plan instead of pressure-testing it
- Stopping when the user seems tired — finish the tree, or get an explicit "park it"
- Skipping the final summary because the conversation "covered it"
