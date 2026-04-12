# Feature Delivery Workflow

## Objective

Ship one small, reviewable feature slice at a time without random repo-wide changes.

## Before Coding

For each task, state:

- the exact feature scope
- the files expected to change
- the acceptance checks

## Delivery Rules

- Prefer one feature or one thin vertical slice per round
- Avoid touching unrelated files
- Avoid opportunistic refactors unless they are necessary to complete the scoped task
- Preserve existing working behavior while expanding functionality

## Recommended Task Size

Good examples:

- Add Home `Delay` flow using sample data
- Add `Prescription` model serialization
- Add Meds active or inactive toggle state
- Add Google Calendar sync status badge

Bad examples:

- Rewrite the entire app structure in one round
- Redesign every screen while also adding backend integration
- Replace local and cloud data layers at the same time without a migration plan

## During Coding

- Keep business logic out of widgets
- Add only the files needed for the scoped feature
- Maintain deterministic sample data for demo stability

## After Coding

Report:

- files changed
- what behavior was added or changed
- what verification was run
- any blocked checks or follow-up items

## Acceptance Mindset

- Treat non-functional visible buttons as failures
- Treat silent sync or upload failures as failures
- Treat accidental UI regressions as failures
