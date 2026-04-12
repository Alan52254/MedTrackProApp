# MedTrack Pro Project Context

## Identity

MedTrack Pro is a Flutter-based, Android-first medication intelligence app. It is not a generic reminder app and should not be reduced to a checklist UX.

## Core Product Framing

- Personalized medication intelligence system
- Daily medication planning anchored to the patient's routine
- Decision support for `Done`, `Delay`, and `Skip`
- Prescription image upload
- One-way Google Calendar sync

## Primary Navigation

The app uses four bottom tabs:

1. Home
2. Calendar
3. Meds
4. Profile

## Product Principles

- The Home tab is the intelligence center
- Delay or skip actions can affect later medication events
- Alerts are part of the core workflow, not a decorative extra
- Caregiver support is future-facing but some related fields should already exist

## Vocabulary

- `Prescription`: a medication instruction source
- `MedicationEvent`: a scheduled or completed dose instance
- `CalendarContextEvent`: a routine or environmental context item
- `DecisionAlert`: a recommendation or warning derived from schedule analysis
- `ScheduleEngine`: creates medication events
- `ConflictAnalyzer`: inspects timing and skip/delay conflicts
- `AlertGenerator`: converts analysis into UI alerts

## Fixed Constraints

- Flutter + Dart only
- Android emulator demo comes first
- Preserve the four-tab structure
- Preserve decision logic boundaries outside the widget layer
- Do not randomly rewrite product structure without an explicit spec change

## Demo Strategy

- Use deterministic local sample data first
- Make every visible action control functional
- Prefer realistic state changes over placeholder interactions
