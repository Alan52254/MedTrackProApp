# MedTrack Pro Project Specification

## 1. Product Overview

**Project name:** MedTrack Pro

**Platform:** Flutter + Dart, Android-first

**Product positioning:** MedTrack Pro is a personalized medication intelligence system, not a simple reminder app. The app should help patients manage schedules, understand the impact of delay or skip actions, upload prescription images, and sync medication events to Google Calendar.

**Primary demo target:** Android emulator demo with realistic local sample data before cloud integrations.

## 2. Product Goals

- Build a daily medication workflow that feels closer to decision support than a checklist.
- Generate medication events from patient routine and prescription rules.
- Help users safely handle `Done`, `Delay`, and `Skip` actions.
- Support prescription image upload and future structured extraction flow.
- Support one-way Google Calendar sync from app to the user's calendar.

## 3. Users and Scope

### Primary user

**Patient**

- Manages personal medication schedule
- Reviews today's plan
- Marks medication as done
- Delays or skips a dose
- Uploads prescription images
- Updates personal profile and daily routine
- Connects Google Calendar

### Secondary user

**Caregiver**

- Reserved for future expansion
- Keep caregiver-related fields in profile and data models
- Full multi-user collaboration is not required in v1

## 4. Core Navigation

The main app uses bottom navigation with 4 tabs:

1. Home
2. Calendar
3. Meds
4. Profile

## 5. Page Requirements

### Home

Home is the intelligent medication center and the most important screen.

#### Required sections

- Today's Medications header
- Current date
- Adherence summary for the day
- Notification or status entry point
- 7-day adherence card with percentage and progress bar
- Alert area that can render multiple decision alerts
- Next Medication card
- Today's medication timeline or schedule list

#### Alert card requirements

Each alert must include:

- `severity`
- `title`
- `explanation`
- `recommendation`
- `actionButtons`
- `dismiss`

Example alert types:

- Low adherence
- Skip impact from previous dose
- Insufficient interval conflict
- Over-concentrated medication window

#### Next Medication card requirements

- Medication name
- Scheduled time
- Status
- Dose and instruction
- Smart recommendation
- Action buttons: `Done`, `Delay`, `Skip`

#### Timeline requirements

Each medication event should show:

- Time
- Drug name
- Dose
- Instruction
- Status
- Expandable details
- Entry point to detail or edit flow

#### Interaction requirements

- `Done` updates the medication event state
- `Delay` opens a delay picker with `15m`, `30m`, `1h`, `2h`, and `custom`
- `Skip` opens a confirmation step
- Delay or skip actions that affect later events must produce a decision alert
- Every visible button must have real behavior

### Calendar

Calendar displays medication events and contextual day information.

#### Required sections

- `Calendar` title
- Week or Month toggle
- Date selection
- Medication events list for the selected date
- Context events list for the selected date
- Add button for new medication events or context events

#### Medication event display rules

- Clear status color mapping for `Done`, `Pending`, `Skipped`, `Delayed`
- Delayed events must keep `originalTime`
- Skipped events require a visually distinct state

#### Context event examples

- Breakfast
- Lunch
- Location
- Weather
- Fatigue level

#### Interaction requirements

- Changing the selected date refreshes that day's data
- Tapping an event opens details
- Medication events and context events can coexist without corrupting chronology

### Meds

Meds manages prescriptions and prescription-linked artifacts.

#### Required sections

- Prescription list with `Active` and `Inactive` states
- Prescription cards with drug metadata
- Add Medication entry point
- Schedule Preview before save
- Prescription Image Upload status area

#### Prescription card fields

- Drug name
- Dose
- Administration type
- Active state
- Detail chevron or entry point

#### Add or Edit Medication fields

- `drugName`
- `commonFrequency`
- `dose`
- `durationDays`
- `indication`
- `drugInteractions`
- `note`
- `administrationType`
- `frequencyType`
- `frequencyValue`
- `active`

#### Interaction requirements

- Active or inactive state must affect generated daily events
- Creating a prescription generates medication events
- Uploaded prescriptions must preserve source metadata
- Image upload must update UI state, not just show a toast
- Schedule preview is required before final save

### Profile

Profile stores patient baseline data and routine anchors.

#### Required sections

**Basic Information**

- `fullName`
- `gender`
- `dateOfBirth`
- `age`

**Patient Data**

- `patientCode`
- `occupation`
- `comorbidityCount`
- `hasComorbidity`
- `diseaseList`
- `hasCaregiver`

**Medical**

- `allergies`
- `diagnoses`

**Daily Routine**

- `wakeTime`
- `breakfastTime`
- `lunchTime`
- `dinnerTime`
- `sleepTime`

**Emergency / Caregiver**

- `caregiverName`
- `caregiverPhone`

#### Interaction requirements

- `Save`
- `Reset`
- If `wakeTime` changes, the app can prompt to recalculate morning medications or today's schedule
- If `hasComorbidity = false`, `diseaseList` may be empty
- If `hasCaregiver = false`, caregiver fields may be empty

## 6. Core Data Models

### PatientProfile

- `id`
- `authUserId`
- `fullName`
- `gender`
- `dateOfBirth`
- `age`
- `patientCode`
- `occupation`
- `comorbidityCount`
- `hasComorbidity`
- `diseaseList`
- `hasCaregiver`
- `allergies`
- `diagnoses`
- `wakeTime`
- `breakfastTime`
- `lunchTime`
- `dinnerTime`
- `sleepTime`
- `caregiverName`
- `caregiverPhone`
- `createdAt`
- `updatedAt`

### Prescription

- `id`
- `patientId`
- `drugName`
- `commonFrequency`
- `dose`
- `durationDays`
- `indication`
- `drugInteractions`
- `note`
- `administrationType`
- `frequencyType`
- `frequencyValue`
- `active`
- `source`
- `imageId`
- `createdAt`
- `updatedAt`

### MedicationEvent

- `id`
- `patientId`
- `prescriptionId`
- `scheduledStart`
- `scheduledEnd`
- `actualTakenAt`
- `status`
- `originalStart`
- `delayMinutes`
- `googleCalendarEventId`
- `syncedToGoogleCalendar`
- `createdAt`
- `updatedAt`

### CalendarContextEvent

- `id`
- `patientId`
- `date`
- `startTime`
- `endTime`
- `activity`
- `location`
- `weather`
- `fatigueLevel`
- `source`
- `createdAt`
- `updatedAt`

### PrescriptionImage

- `id`
- `patientId`
- `uploadedBy`
- `fileName`
- `fileUrl`
- `filePath`
- `mimeType`
- `fileSize`
- `extractedStatus`
- `linkedPrescriptionIds`
- `createdAt`

### DecisionAlert

- `id`
- `patientId`
- `type`
- `severity`
- `title`
- `explanation`
- `recommendation`
- `actionButtons`
- `dismissed`
- `createdAt`

## 7. Core Intelligence Modules

### ScheduleEngine

Purpose:

- Generate medication events from profile routine and prescription rules

Initial rules:

- `before_meal = meal - 30m`
- `after_meal = meal + 60m`
- `with_meal = meal time`
- `bedtime = sleep - 30m`
- `twice_daily = wake + dinner`
- `exact_time = specified time`

Future upgrade directions:

- Consider recent delay behavior
- Consider meal drift
- Consider fatigue level

### ConflictAnalyzer

Purpose:

- Check skipped dose impact
- Check insufficient interval conflicts
- Check medication clustering in the same window
- Check routine-change impacts

### AlertGenerator

Purpose:

- Convert analysis results into UI-ready alerts

Supported severity:

- `critical`
- `warning`
- `info`

Each alert must include recommendation text and action buttons.

## 8. Persistence and Cloud Requirements

### Phase 1

- Use local sample data so the demo works before backend integration

### Phase 2

Integrate Firebase:

- `Firebase Auth` for login
- `Cloud Firestore` for structured app data
- `Firebase Storage` for prescription images

Rules:

- Images must not remain local-only
- Images must not be stored as base64 inside Firestore
- Firebase access must go through repository or service layers
- Widgets must not call Firebase APIs directly

## 9. Google Calendar Requirements

Goal:

- One-way sync from app medication events to the user's Google Calendar

### v1 scope

- Connect Google Calendar
- Sync medication schedule from app to calendar
- Save `googleCalendarEventId`
- Show sync state in UI
- Show sync errors and never fail silently

### Explicit non-goals for v1

- No two-way sync
- No conflict merge engine
- No advanced resync reconciliation

## 10. Technical Direction

### Recommended packages

- `go_router`
- `flutter_riverpod`
- `freezed`
- `json_serializable`
- `image_picker`
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`
- `google_sign_in`
- Google Calendar API integration
- `intl`

### Architectural direction

- Feature-first structure
- Thin widget layer
- Separated business logic
- Engines and analyzers live outside UI widgets

## 11. Suggested Folder Structure

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

## 12. Delivery Priorities

### Phase 0

- Flutter project skeleton
- Bottom navigation
- Four tab placeholders
- Theme

### Phase 1

- Local sample flow
- Home supports `Done`, `Delay`, `Skip`
- Alert dismiss
- Meds active or inactive toggle
- Profile save and reset

### Phase 2

- Firebase integration
- Firestore repositories
- Storage image upload
- Prescription image metadata flow

### Phase 3

- Google Calendar one-way sync
- Connect flow
- Sync action
- Sync state persistence

### Phase 4

- ScheduleEngine
- ConflictAnalyzer
- AlertGenerator
- Decision recommendations

## 13. Current Instruction for the Codebase

- Rebuild or continue in Flutter only
- Ignore previous React implementation if any exists outside this app
- Preserve product requirements, information architecture, core models, and decision-logic boundaries
- Do not hide incomplete functionality behind fake buttons or fake UI
