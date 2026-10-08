# Cross-layer change review

Use this checklist only for changes that affect shared domain behavior or both applications.

- Are team IDs, names and active status consistent everywhere?
- Is the canonical criterion order unchanged or migrated in every consumer?
- Do score maxima still total 100 and match backend validation?
- Do request and response payloads agree between producer and consumer?
- Are test and official modes isolated in reads, writes and destructive actions?
- Can existing evaluations still be interpreted after the change?
- Were both the juror journey and organization dashboard verified?
- Was the relevant documentation updated with the implementation?

