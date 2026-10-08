---
name: hello-code-context
description: Preserve the Hello Code 2026 domain rules and coordinate changes that affect both the evaluation page and organization dashboard. Use for project-wide planning, shared scoring or team data, architecture changes, and cross-layer reviews in this repository.
---

# Hello Code — contexto geral

Read [`../../../docs/contexto/README.md`](../../../docs/contexto/README.md) before making a project-wide or cross-layer change.

## Essential constraints

- Preserve the seven criteria, their canonical order and the 100-point maximum unless the user explicitly changes the scoring model.
- Keep test and official data strictly isolated.
- Distinguish Supabase RPC adapters from file-only preview mocks. Hosted pages must not silently store evaluations in `localStorage` when the database is unavailable.
- Preserve the chosen simple architecture: static HTML on GitHub Pages, direct Supabase RPCs and juror identification by name only. Do not introduce accounts or a separate server unless the user changes the scope.
- Coordinate changes to duplicated team, criterion and score structures across both pages until a shared source of truth exists.
- Keep user-facing copy in Brazilian Portuguese and preserve the pink/green Hello Code identity unless redesign is requested.

## Routing

- For Supabase SQL, RPC contracts, persistence, aggregation or test operations, also use `hello-code-backend`.
- For HTML, CSS, browser behavior, responsive layout or accessibility work, also use `hello-code-frontend`.
- For a change spanning both, read both specialized context documents and verify their API assumptions still agree.

For a cross-layer completion review, read [references/change-impact.md](references/change-impact.md).
