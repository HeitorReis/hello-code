---
name: hello-code-frontend
description: Build or review the Hello Code 2026 juror and organization interfaces. Use for changes to the repository's HTML, CSS, browser JavaScript, interaction flows, responsive behavior, rendering, accessibility, or API consumption.
---

# Hello Code — frontend

Read [`../../../docs/contexto/frontend/README.md`](../../../docs/contexto/frontend/README.md) before changing either interface.

## Preserve the product behavior

- Keep user-facing content in Brazilian Portuguese.
- Preserve the mobile-first juror flow: identification, team selection, seven scoring steps, review, submission and later editing.
- Preserve the admin distinction between test and official modes and keep destructive controls unavailable for official data.
- Keep the canonical criterion order aligned with the backend and with the 100-point total.
- Reuse the existing pink/green tokens and visual language unless a redesign is requested.

## Browser implementation

- Render user or API data with `textContent` or safe DOM construction, not unsanitized `innerHTML`.
- Derive final-step logic from `CRITERIA.length` instead of hard-coded index values.
- Provide distinct loading, empty, error and success states for API operations.
- Keep keyboard navigation, visible focus, accessible names, focus movement and live announcements working.
- Verify narrow screens, safe areas, 200% zoom and the dashboard's horizontally scrollable table.
- Keep the Supabase `window.fetch` adapters and file-only preview gate distinct. Hosted pages must report database failures instead of switching to local evaluation storage.

Read [references/ui-review.md](references/ui-review.md) for a UI implementation or review. Do not load it for backend-only changes.
