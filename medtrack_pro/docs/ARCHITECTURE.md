# MedTrack Pro Architecture Guide

## 1. Architecture Goals

- Keep the widget tree thin and predictable
- Separate product rules from presentation details
- Preserve clear ownership between features, services, repositories, and engines
- Support local sample data first, then cloud integrations
- Make the codebase easy for IDE agents to change in small, low-risk scopes

## 2. Project Structure Baseline

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    constants/
    models/
    services/
    utils/
  features/
    home/
      presentation/
      application/
      domain/
      data/
    calendar/
      presentation/
      application/
      domain/
      data/
    meds/
      presentation/
      application/
      domain/
      data/
    profile/
      presentation/
      application/
      domain/
      data/
    prescription_upload/
      presentation/
      application/
      data/
    google_calendar_sync/
      application/
      data/
  shared/
    widgets/
    dialogs/
    components/
```

## 3. Layer Responsibilities

### `presentation/`

- Screens
- Page-level widgets
- UI state binding
- User input handlers that delegate to application logic
- Visual formatting and rendering rules

### `application/`

- Use cases
- Controllers / notifiers / Riverpod providers
- Coordination between repositories and engines
- Flow orchestration for save, sync, delay, skip, dismiss, and recalculation actions

### `domain/`

- Domain entities if needed beyond shared models
- Enums and value rules specific to the feature
- Core interfaces that are more domain-facing than storage-facing

### `data/`

- Repository implementations
- DTO conversion
- Local sample data sources
- Firebase / API integration adapters

### `core/`

- Shared models
- Cross-feature services
- Shared constants
- Utility helpers
- Engine implementations that are not purely tied to one feature screen

### `shared/`

- Reusable widgets
- Dialogs
- Cross-feature UI components

## 4. Dependency Direction

Allowed direction:

- `presentation -> application`
- `application -> domain`
- `application -> data`
- `data -> core`
- `presentation -> shared`

Avoid:

- `presentation -> Firebase`
- `presentation -> Storage`
- `presentation -> business rule engines`
- `widget -> direct persistence write`

## 5. Core Models

The following models should exist in `lib/core/models/` unless there is a strong reason to localize them:

- `PatientProfile`
- `Prescription`
- `MedicationEvent`
- `CalendarContextEvent`
- `PrescriptionImage`
- `DecisionAlert`

Models should be designed for:

- JSON serialization
- local sample data compatibility
- Firestore compatibility
- deterministic UI rendering

Recommended tooling:

- `freezed`
- `json_serializable`

## 6. Routing Baseline

Recommended primary routes:

- `/home`
- `/calendar`
- `/meds`
- `/profile`

Recommended secondary flows:

- medication detail
- medication delay picker
- skip confirmation
- prescription create or edit
- schedule preview
- prescription image upload
- Google Calendar connect or sync state detail

Use `go_router` and keep route definitions centralized in `lib/app/router.dart`.

## 7. State Management

Recommended baseline:

- `flutter_riverpod`

State rules:

- Screen state should be exposed via providers or controllers
- Sample-data repositories and Firebase repositories should share feature-facing interfaces where practical
- Async states must expose loading, success, and error paths
- Sync failures and upload failures must be represented in UI state, not swallowed

## 8. Business Logic Engines

### ScheduleEngine

Responsibility:

- Build medication events from prescriptions and profile routine anchors
- Recalculate medication timing when routines change
- Produce deterministic preview data before save

Base rules:

- `before_meal = meal - 30m`
- `after_meal = meal + 60m`
- `with_meal = meal time`
- `bedtime = sleep - 30m`
- `twice_daily = wake + dinner`
- `exact_time = explicit time`

### ConflictAnalyzer

Responsibility:

- Evaluate delay or skip impact
- Detect insufficient spacing between doses
- Detect medication crowding
- Detect conflicts caused by profile routine changes

### AlertGenerator

Responsibility:

- Convert analysis output into UI-ready `DecisionAlert` objects
- Always provide `severity`, explanation, recommendation, and actions

These engines must not live inside widgets.

## 9. Repository and Service Rules

### Repository responsibilities

- Feature-friendly CRUD operations
- Mapping between raw storage data and app models
- Hiding persistence details from UI and controllers

### Service responsibilities

- External integrations
- Google Calendar calls
- Firebase Storage upload steps
- Auth/session utilities
- Image-processing helpers if added later

### Required rule

- Widgets never call Firebase, Storage, or Google Calendar APIs directly

## 10. Firebase Design Rules

Firebase usage by concern:

- `Firebase Auth`: authentication
- `Cloud Firestore`: structured entities and metadata
- `Firebase Storage`: prescription image binaries

Mandatory rules:

- Prescription image files go to Storage
- Metadata about uploaded files goes to Firestore
- Do not store large binary content as base64 in Firestore
- Persist upload and sync errors in state that the UI can render

## 11. Google Calendar Sync Design Rules

v1 boundary:

- One-way sync from app to Google Calendar only

Required data:

- `googleCalendarEventId`
- `syncedToGoogleCalendar`
- sync status or error state

Not in v1:

- Two-way sync
- merge conflict resolution
- automatic reconciliation across arbitrary manual calendar edits

## 12. Sample Data Strategy

Before backend integration:

- Provide realistic local sample data for patient profile, prescriptions, medication events, alerts, and context events
- Keep sample logic deterministic
- Avoid random values that make QA inconsistent

Sample data must support:

- Home `Done`, `Delay`, `Skip`
- alert dismiss
- Calendar date switching
- Meds active or inactive toggles
- Profile save and reset

## 13. UI Constraints for Architecture

- All visible action buttons require real handlers
- Avoid placeholder modals that do not update state
- Avoid burying domain decisions inside widget callback lambdas
- Keep layout structure aligned with the agreed spec until the product spec changes

## 14. Suggested First Implementation Sequence

1. App shell, router, theme, bottom navigation
2. Shared models and enums
3. Local sample repositories
4. Home interaction flow
5. Meds CRUD shell and schedule preview
6. Profile form and routine recalculation entry point
7. Calendar display and context event support
8. Firebase integration
9. Google Calendar one-way sync
10. ScheduleEngine, ConflictAnalyzer, AlertGenerator refinements
