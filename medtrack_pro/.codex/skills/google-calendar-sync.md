# Google Calendar Sync Rules

## v1 Scope

Implement one-way sync from app medication events to Google Calendar.

## Required Behavior

- Allow the user to connect Google Calendar
- Sync medication events from the app into Google Calendar
- Persist `googleCalendarEventId`
- Persist sync state on the medication event or related sync model
- Surface sync failure in UI state

## Explicit Non-Goals

- No two-way sync
- No merge conflict resolution
- No complex reconciliation for manual calendar edits
- No calendar-to-app authoritative overwrite flow in v1

## Design Rules

- Keep Google API calls in a service or repository layer
- Application layer coordinates sync requests and state updates
- Widgets only trigger sync actions and render resulting state

## Minimum Sync Metadata

- `googleCalendarEventId`
- `syncedToGoogleCalendar`
- last known sync result if tracked by the implementation

## Failure Rules

- Do not fail silently
- Show clear error or retry state
- Preserve enough metadata for future troubleshooting
