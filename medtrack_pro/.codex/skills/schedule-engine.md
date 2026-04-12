# Schedule Engine Rules

## Purpose

The schedule engine generates medication events from patient routine anchors and prescription timing rules. This logic must remain outside the UI layer.

## Base Administration Rules

- `before_meal = meal - 30 minutes`
- `after_meal = meal + 60 minutes`
- `with_meal = meal time`
- `bedtime = sleep time - 30 minutes`
- `twice_daily = wake time + dinner time`
- `exact_time = explicit configured time`

## Inputs

- `PatientProfile`
- `Prescription`
- daily routine anchors such as wake, breakfast, lunch, dinner, and sleep
- existing event state when recalculation is needed

## Outputs

- generated `MedicationEvent` list
- schedule preview data before save
- structured analysis input for downstream conflict or alert modules

## Recalculation Scenarios

- prescription created
- prescription edited
- prescription activated or deactivated
- routine anchor changed, especially `wakeTime`
- delay or skip action requires downstream event adjustment

## Delay and Skip Expectations

- Preserve original scheduled time when an event is delayed
- Track delay minutes explicitly
- Feed changed timing into conflict analysis
- Feed skipped-dose impact into alert generation

## Future Upgrade Direction

- recent delay behavior
- meal drift
- fatigue level
- personalized recommendation weighting

## Guardrails

- Do not hardcode rules in widget callbacks
- Do not make scheduling random
- Keep rule application deterministic for QA and demo stability
