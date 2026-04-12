# Prompt Template for Future Agents

Use the following template when starting a new implementation task for MedTrack Pro.

```md
Project: MedTrack Pro
Platform: Flutter + Dart, Android-first

Read first:
- docs/PROJECT_SPEC.md
- docs/ARCHITECTURE.md
- docs/TASKS.md
- .codex/skills/project-context.md
- .codex/skills/architecture-rules.md
- .codex/skills/ui-implementation-rules.md
- .codex/skills/qa-regression.md

Task scope:
[Describe one small feature or one thin vertical slice only.]

Constraints:
- Do not change unrelated screens.
- Do not move business logic into widgets.
- All visible buttons in the touched flow must remain functional.
- Preserve the four-tab structure.
- Use deterministic sample data when backend work is not part of this task.

Before coding:
- Summarize the implementation plan.
- List the files you expect to change.
- List acceptance checks.

Implementation expectations:
- Keep changes small and reviewable.
- Use repository/service layers for Firebase and Google Calendar access.
- Treat ScheduleEngine, ConflictAnalyzer, and AlertGenerator as non-UI logic.

After coding:
- Report files changed.
- Report behavior added or changed.
- Report verification performed.
- Report follow-up items or blocked checks.
```
