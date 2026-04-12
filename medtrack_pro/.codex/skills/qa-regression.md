# QA Regression Checklist

## Core Goal

Prevent demo regressions while features are added in small increments.

## Global Checks

- App still builds when feasible
- Main navigation still works
- No visible button has become non-functional
- Error states are visible instead of silent

## Home Checks

- Today's summary renders
- 7-day adherence card renders
- Alert cards render and dismiss
- `Done`, `Delay`, and `Skip` still work
- Timeline still reflects state changes

## Calendar Checks

- Date selection updates the event list
- Medication event statuses render clearly
- Delayed events preserve original time display
- Skipped events remain visually distinct

## Meds Checks

- Prescription list renders
- Active or inactive toggle still affects schedule-related state
- Schedule preview remains reachable
- Prescription image upload state is visible

## Profile Checks

- Save works
- Reset works
- Optional caregiver and comorbidity fields respect their gate values

## Integration Checks

- Firebase failures are surfaced if Firebase paths are active
- Google Calendar sync failures are surfaced if sync paths are active

## Regression Rule

- Do not claim a feature is done if the primary action button still does nothing
