# MedTrack Pro

MedTrack Pro is a Flutter-based intelligent medication management application designed to go beyond simple reminders.

It supports dynamic medication scheduling, delay handling with timeline adjustment, and cross-screen state synchronization. The system is built with a feature-first architecture and local state management, preparing for future integrations such as prescription OCR, Firebase backend, and Google Calendar sync.

This project focuses on building a real-world medication workflow that adapts to user behavior rather than enforcing rigid schedules.

---

## 🚀 Current Status

**Version:** Phase 1 Demo (Local-only)

This version is a **fully runnable prototype** with interactive flows and shared state across all screens.

---

## 📱 Implemented Features

### 🏠 Home

* Today’s medication overview
* 7-day adherence summary
* Alert cards (e.g. skipped dose warning)
* Next medication card
* Full timeline of today’s events
* Actions:

  * ✅ Done
  * ⏳ Delay (time-based picker)
  * ❌ Skip
* Delay flow:

  * User selects a target time
  * Event updates to new scheduled time
  * Original time is preserved
  * App automatically navigates to Calendar

---

### 📅 Calendar

* 7-day date selector (centered on selected date)
* Displays medication events by date
* Status indicators:

  * Done
  * Pending
  * Skipped
  * Delayed
* Reflects real-time updates from Home and Meds
* Automatically jumps to selected date after delay

---

### 💊 Meds

* Prescription list
* Active / Inactive toggle
* Immediate effect on Home timeline
* Local demo data (no backend yet)

---

### 👤 Profile

* Editable patient profile
* Includes:

  * Basic info
  * Medical conditions
  * Daily routine
  * Caregiver info
* Save / Reset functionality
* Shared state with entire app

---

## 🧱 Architecture

* **Flutter + Dart**
* **Feature-first structure**
* Clear separation of:

  * presentation (UI)
  * application (controller/state)
  * domain (models)
  * data (local store)

---

## 🧠 State Management

* Shared `LocalDemoStore` at app level
* Controllers listen to store changes
* No business logic inside widgets

---

## 🔄 Key Interaction Flow

### Delay → Timeline Navigation

1. User taps **Delay** on Home
2. Picks a new time via time picker
3. Event updates:

   * `scheduledStart` → new time
   * `originalStart` preserved
   * `status = delayed`
4. App navigates to Calendar
5. Calendar auto-selects target date
6. Date strip centers on selected date

---

## 🧪 Verification

* `flutter analyze` ✅
* `flutter test` ✅ (all passing)
* Runs on Android emulator
* Cross-screen state consistency verified

---

## ❌ Not Yet Implemented

* Firebase / Firestore
* Google Calendar sync
* Prescription image upload
* OCR / automatic medication parsing
* Scheduling engine (ScheduleEngine)
* Conflict analysis / decision support

---

## 🗺️ Roadmap

### Phase 2

* Firebase integration
* Prescription image upload
* Basic data persistence

### Phase 3

* Google Calendar sync (one-way)
* Event syncing and status tracking

### Phase 4

* Intelligent scheduling engine
* Conflict detection
* Decision support alerts

---

## 🎯 Project Goal

MedTrack Pro aims to evolve into a:

> **Personalized Medication Intelligence System**

Not just a reminder app — but a system that understands real-life behavior and supports better medication adherence.

---

## 🧑‍💻 Author

Alan Lin
Artificial Intelligence Student
Flutter / AI / Healthcare Systems

---
