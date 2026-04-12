# UI Implementation Rules

## Primary Goal

Implement UI that matches the agreed product structure and always connects visible actions to real state changes.

## Mandatory Rules

- Every visible button must do something real
- Do not ship fake modals, fake sheets, or fake toasts as a substitute for state updates
- Do not invent random data that conflicts with the product spec
- Do not collapse the four-tab structure into a different information architecture
- Do not change screen hierarchy casually while the spec is still stable

## Home-Specific Rules

- `Done`, `Delay`, and `Skip` must update state
- Delay must lead to a real picker or input flow
- Skip must have a real confirmation flow
- Alerts must support dismiss and actionable controls

## Calendar-Specific Rules

- Date selection must refresh visible events
- Delayed events must preserve original timing data
- Skipped events must look distinct

## Meds-Specific Rules

- Active or inactive state must affect medication events
- Schedule preview must exist before final save
- Prescription image upload must change visible UI state

## Profile-Specific Rules

- Save and Reset must be functional
- Routine changes should connect to recalculation entry points when implemented
- Optional caregiver and comorbidity fields must respect boolean gate fields

## Sample Data Rules

- Prefer deterministic fixtures
- Avoid random timestamps that make QA inconsistent
- Use sample logic that reflects actual domain rules

## Visual Consistency

- Stay aligned with the latest agreed screen structure
- Avoid broad visual redesigns unless the task explicitly requests UI redesign
