# Supabase integration review

- Validate schemas, IDs, modes, array lengths, integer scores and comment lengths.
- Use database constraints for valid modes and evaluation uniqueness.
- Perform evaluation upserts and total calculation atomically.
- Preserve the chosen public, name-only model; do not claim that names or the visual dashboard code authenticate users.
- Keep the frontend configuration limited to the project URL and public key.
- Escape output and never persist executable markup from names or comments.
- Limit reset and simulation queries explicitly to test records.
- Preserve ranking by total sum, then evaluation count, then team name unless the user requests a change.
- Verify RPC behavior with the public client role, including grants and RLS.
- Verify saving, editing, validation, totals and test/official isolation in the authorized project before claiming the database works.
