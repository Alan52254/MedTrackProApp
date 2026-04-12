# MedTrack Pro Task Board

## Current Status

- Flutter is installed
- Development environment is ready
- Emulator setup is ready
- Flutter starter project exists in `medtrack_pro/`
- Project documentation and agent skill files are being added
- Flutter UI should remain unchanged for this step

## Immediate Guardrail

- Do not modify Flutter UI in this documentation task
- Do not refactor `lib/` just because a better structure is possible
- Do not add fake interactions to unfinished screens

## Delivery Phases

### Phase 0: Foundation

Goal:

- Prepare the project skeleton for implementation

Work:

- Confirm package direction
- Add app shell structure
- Add bottom navigation
- Add four page placeholders
- Add theme foundation
- Create core models and sample-data contracts

Acceptance checks:

- App boots on Android emulator
- Bottom navigation changes tabs correctly
- No business logic lives directly in widgets

### Phase 1: Local Demo Flow

Goal:

- Make the app demoable with local sample data

Work:

- Home supports `Done`, `Delay`, `Skip`
- Decision alerts render and dismiss
- Meds screen supports active or inactive toggle
- Profile screen supports save and reset
- Calendar screen shows medication events and context events
- Schedule preview exists before saving a prescription

Acceptance checks:

- Every visible button on these flows works
- Delay and skip actions update visible state
- Active or inactive medication affects event generation
- No silent failures

### Phase 2: Firebase Integration

Goal:

- Replace local persistence with repository-backed cloud persistence where appropriate

Work:

- Add Firebase initialization
- Add Auth flow foundations
- Add Firestore repositories
- Add Storage upload for prescription images
- Persist image metadata in Firestore

Acceptance checks:

- Firebase access is routed through repositories or services
- Uploaded images go to Storage
- Firestore stores structured metadata, not raw image blobs
- Errors surface to UI state

### Phase 3: Google Calendar Sync

Goal:

- Ship one-way sync from app to Google Calendar

Work:

- Connect Google Calendar account
- Sync medication events to calendar
- Save `googleCalendarEventId`
- Show sync status and failure states

Acceptance checks:

- Medication events can be pushed to Google Calendar
- Sync state is visible in the app
- Failure is not silent
- No two-way sync logic is introduced yet

### Phase 4: Intelligence Layer

Goal:

- Improve schedule and recommendation quality

Work:

- Implement `ScheduleEngine`
- Implement `ConflictAnalyzer`
- Implement `AlertGenerator`
- Recalculate timing from routine changes
- Generate recommendations for delay and skip outcomes

Acceptance checks:

- Schedule preview reflects profile routine anchors
- Conflict analysis produces deterministic alerts
- Delay and skip actions can influence later events

## Suggested Next Tasks

1. Create the Flutter feature-first folder skeleton in `lib/`
2. Add shared core models and enums
3. Add local sample repositories and sample fixtures
4. Add app router and bottom navigation shell

## Definition of Done for Each Feature

- Scope is limited to one feature or one thin vertical slice
- Files touched are listed before implementation
- Acceptance checks are explicit
- UI remains consistent with the product spec
- Build or analysis checks run when feasible
- Regressions are called out if any verification is blocked

## Prohibited Shortcuts

- Do not hardcode domain decisions in widgets
- Do not call Firebase directly from presentation code
- Do not store prescription images as base64 in Firestore
- Do not add placeholder buttons that do nothing
- Do not introduce two-way Google Calendar sync in v1

## Notes for the Next Agent

- This app should feel like medication decision support, not a basic reminder list
- Preserve the four-tab information architecture
- Treat schedule recalculation, skip impact, and alert generation as first-class product behavior
- Keep changes small and easy to review
