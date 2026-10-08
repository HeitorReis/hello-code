# Frontend review checklist

## Juror journey

- Name and team selection have clear labels and validation.
- Score controls expose criterion name, current value and maximum to assistive technology.
- Previous/next navigation preserves comments and scores.
- Review totals match the seven visible scores.
- Submission cannot be triggered repeatedly while pending.
- Editing restores the correct evaluator, team, scores and comments.

## Admin journey

- Connection errors are visible on the access screen and after opening the dashboard; the existing code field is not authentication.
- Test/official mode has a programmatically exposed selected state.
- Seed and reset require confirmation and cannot affect official data.
- Empty rankings and API failures have explicit presentations.

## Presentation

- Verify 320 px, 360 px, tablet and desktop widths.
- Verify keyboard-only flow, visible focus and 200% zoom.
- Preserve safe-area padding on the mobile bottom navigation.
- Check contrast and reduced-motion behavior.
- Do not interpolate external strings into `innerHTML`.
