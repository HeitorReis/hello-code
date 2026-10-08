---
name: hello-code-backend
description: Implement or review Hello Code 2026 Supabase SQL, evaluation and dashboard RPC contracts, validation, persistence, ranking and test operations. Use for database or API-contract work in this repository.
---

# Hello Code — backend

Read [`../../../docs/contexto/backend/README.md`](../../../docs/contexto/backend/README.md) before changing SQL, an RPC contract, persistence or a test operation.

## Required behavior

- Validate exactly seven integer scores against the canonical maxima `[15, 15, 20, 15, 10, 15, 10]`.
- Calculate totals in the database; never trust a client-provided total.
- Enforce one active evaluation per evaluator, team and mode.
- Preserve juror identification by normalized name, without accounts. The dashboard code is visual and the RPCs do not validate it; do not describe it as authentication or add login requirements without a scope change.
- Keep `test` and `official` isolated in storage, queries, aggregation, seed and reset operations.
- Refuse seed and reset in official mode, regardless of client state.
- Generate evaluation timestamps in the database and preserve creation dates on edits.

## Compatibility

The frontend intercepts `/api/evaluations` and `/api/admin` in the browser and calls Supabase RPCs. These are compatibility routes, not server endpoints. Coordinate contract changes with both HTML consumers. Preserve the hosted error path and the file-only preview gate; do not remove the RPC adapters as if they were mocks.

Read [references/production-readiness.md](references/production-readiness.md) when changing SQL or verifying the database integration. Do not load it for documentation-only edits.
