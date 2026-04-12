# Architecture Rules

## Core Rule

Keep the widget layer thin. Product rules, scheduling logic, persistence, and external integrations must be isolated from UI widgets.

## Required Structure

- Use a feature-first layout
- Prefer `presentation`, `application`, `domain`, and `data` subfolders per feature
- Keep shared models and services in `lib/core/`
- Keep reusable UI elements in `lib/shared/`

## Layer Responsibilities

### Presentation

- Render UI
- Bind state to widgets
- Forward user actions to application logic

### Application

- Coordinate use cases
- Own controller or provider behavior
- Call repositories and engines

### Domain

- Own feature-specific domain rules where needed
- Hold enums or value logic that should not depend on UI or storage

### Data

- Talk to local data sources, Firebase, or external APIs through adapters and repositories
- Map raw data to app models

## Hard Boundaries

- Do not call Firebase from widgets
- Do not place `ScheduleEngine`, `ConflictAnalyzer`, or `AlertGenerator` logic inside screens
- Do not hide repository writes inside reusable widgets
- Do not mix upload logic with presentation formatting code

## Repository Rules

- UI reads and writes should go through repositories or application controllers
- Repositories should present feature-friendly methods instead of raw collection access patterns
- Sample data and Firebase data sources should stay replaceable

## Model Rules

- Core models should be serializable
- Prefer `freezed` and `json_serializable`
- Keep model naming aligned with the product spec

## State Rules

- Prefer `flutter_riverpod`
- Represent loading, success, and error states explicitly
- Sync and upload failures must be renderable by the UI

## Folder Baseline

```text
lib/
  app/
  core/
  features/
  shared/
```
