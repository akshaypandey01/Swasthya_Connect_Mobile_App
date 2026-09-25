# SwasthyaConnect — Setup Guide

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter SDK | ≥ 3.19.0 | https://docs.flutter.dev/get-started/install/windows |
| Dart SDK | ≥ 3.3.0 | Bundled with Flutter |
| Android Studio | Latest | For Android emulator + SDK |
| Firebase CLI | Latest | `npm install -g firebase-tools` |
| FlutterFire CLI | Latest | `dart pub global activate flutterfire_cli` |
| Node.js | ≥ 18 | https://nodejs.org |

---

## Step 1 — Install Flutter

1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your system PATH
4. Run `flutter doctor` to verify all dependencies

---

## Step 2 — Firebase Project Setup

1. Go to https://console.firebase.google.com
2. Create a new project: **swasthya-connect**
3. Enable these services:
   - **Authentication** → Phone provider
   - **Firestore Database** → Start in production mode
   - **Storage** → Default bucket

### Configure Firebase in the app

```bash
# Login to Firebase
firebase login

# In the project root (d:\APP SC\swasthya_connect)
flutterfire configure --project=swasthya-connect
```

This generates `lib/firebase_options.dart`, `android/app/google-services.json`,
and `ios/Runner/GoogleService-Info.plist` — **replace the placeholder file**.

### Deploy Firestore rules & indexes

```bash
firebase deploy --only firestore
```

---

## Step 3 — Get Dependencies

```bash
cd "d:\APP SC\swasthya_connect"
flutter pub get
```

---

## Step 4 — Run the App

```bash
# Android (with emulator or device connected)
flutter run

# Specific device
flutter run -d emulator-5554

# Release build
flutter build apk --release
flutter build appbundle --release
```

---

## Step 5 — Firestore Data Structure

Seed the following collections in Firestore console for testing:

### `frontline_workers` (required for worker login)
```json
{
  "worker_id": "RCH001",
  "name": "Priya ASHA",
  "role": "asha",
  "assigned_facility_id": "FAC001",
  "phone": "+919876543210",
  "visit_type": "field_visit"
}
```

### `facilities`
```json
{
  "facility_id": "FAC001",
  "name": "PHC Rampur",
  "type": "PHC",
  "location": { "lat": 28.8386, "lng": 78.7733 },
  "services": ["OPD", "Maternity", "Vaccinations"],
  "medicine_stock": { "Paracetamol": 500, "ORS": 200 },
  "diagnostic_capability": ["Blood test", "Urine test"]
}
```

---

## Step 6 — Optional: Regenerate Hive Adapters

The Hive `.g.dart` adapter files are pre-written and committed.
Only regenerate if you modify the `@HiveType` model classes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Architecture Overview

```
lib/
├── main.dart                    # App entry, Hive + Firebase init
├── firebase_options.dart        # Firebase config (generated)
├── core/
│   ├── constants/               # Colors, routes, strings, hive keys
│   ├── l10n/                    # EN + HI localization + LocaleNotifier
│   ├── router/                  # GoRouter with role-based redirect
│   ├── services/                # Auth, Connectivity, Sync, Notifications
│   ├── theme/                   # Material 3 theme (Noto Sans)
│   └── utils/                   # Validators, date utils, snackbar helpers
├── data/
│   ├── local/                   # Hive adapter registration
│   ├── models/                  # PatientModel, EncounterModel, etc.
│   └── repositories/            # Patient, Encounter, Tracker, Appointment repos
└── features/
    ├── auth/
    │   ├── patient/             # ABHA + OTP login
    │   └── worker/              # RCH ID + OTP login
    ├── shared/
    │   ├── splash_screen.dart
    │   ├── language_select_screen.dart
    │   ├── role_select_screen.dart
    │   └── widgets/             # ScButton, ScCard, SyncBadge, etc.
    ├── patient/                 # 16 patient-facing screens
    └── worker/                  # 13 worker-facing screens
```

---

## Firestore Collections (Data Model)

| Collection | Key Fields |
|-----------|-----------|
| `patients` | patient_id, name, dob, gender, phone, language_pref, consent_flags |
| `frontline_workers` | worker_id, name, role, assigned_facility_id |
| `doctors` | doctor_id, name, specialty, facility_id |
| `facilities` | facility_id, name, type, location, services, medicine_stock |
| `encounters` | encounter_id, patient_id, worker_id, timestamp, vitals, symptom_input, sync_status |
| `triage_results` | encounter_id, severity, model_version, confidence_score |
| `referrals` | referral_id, encounter_id, from/to_facility_id, status |
| `appointments` | appointment_id, patient_id, facility_id, datetime, queue_token |
| `prescriptions` | prescription_id, encounter_id, medicines, dosage_instructions |
| `tracker_entries` | patient_id, type, entry_date, data, next_due_date |
| `feedback` | feedback_id, patient_id, facility_id, rating, comment, status |
| `emergency_alerts` | alert_id, encounter_id, location, status |

---

## Offline Sync Flow

1. Worker creates patient / encounter / tracker entry
2. Record saved to **Hive** with `sync_status: "pending"`
3. `SyncBadge` in worker dashboard shows pending count
4. When connectivity returns → `SyncService.syncAll()` fires automatically
5. Each record pushed to Firestore → `sync_status` flipped to `"synced"`
6. Badge updates to "Synced ✓"

---

## Triage Engine

Location: `lib/features/worker/triage_result/triage_engine.dart`

Currently **rule-based**. The TODO comment marks where to plug in an ONNX or
XGBoost on-device model. Scoring:

| Input | Critical factor |
|-------|----------------|
| SpO₂ < 85% | +40 pts |
| Unconscious | +60 pts |
| Chest pain | +30 pts |
| Difficulty breathing | +35 pts |
| BP ≥ 180/120 | +30 pts |
| Temp ≥ 105°F | +35 pts |

**Bands:** 0–14 → Green, 15–34 → Yellow, 35–59 → Red, 60+ → Critical

---

## Known TODOs

- [ ] Replace `firebase_options.dart` with real `flutterfire configure` output
- [ ] Replace rule-based triage with ONNX/XGBoost model
- [ ] Add `google-services.json` and `GoogleService-Info.plist`
- [ ] Add real OCR in `upload_records_screen.dart` (Google ML Kit recommended)
- [ ] Implement real video call SDK (Agora, Jitsi, or ZEGOCLOUD)
- [ ] Add push notifications via FCM for queue updates & reminders
- [ ] Implement ABHA API integration (NHA sandbox) for real OTP flow
- [ ] Add Sentry/Crashlytics for production error tracking
- [ ] Write widget + integration tests
