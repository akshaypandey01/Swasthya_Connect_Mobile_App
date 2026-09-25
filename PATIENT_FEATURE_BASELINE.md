# Patient Feature Baseline
**Generated:** September 20, 2026  
**Purpose:** Document existing Patient features BEFORE web integration  
**Status:** Pre-modification baseline - DO NOT REMOVE any feature listed here

---

## Existing Patient Features Inventory

### 1. Patient Home Dashboard
- **Screen:** `lib/features/patient/home/patient_home_screen.dart`
- **Route:** `/patient/home`
- **Status:** ✅ Working
- **Dashboard Entry:** N/A (This IS the dashboard)
- **Service/Repository:** None (static UI)
- **Model:** None
- **Backend Dependency:** None (greeting + navigation hub)
- **Hive Dependency:** `settingsBox` (reads patient name)
- **Description:** Home screen with greeting, 14 feature tiles in grid layout, Emergency SOS banner
- **UI Components:** 
  - AppBar with gradient, profile icon
  - Emergency SOS prominent banner
  - Grid of feature tiles (2 columns on phone, 4 on tablet)
- **Navigation Targets:** All 14 Patient feature routes

---

### 2. Health Assessment
- **Screen:** `lib/features/patient/health_assessment/health_assessment_screen.dart`
- **Route:** `/patient/health-assessment`
- **Status:** ✅ Working (basic symptom checker)
- **Dashboard Entry:** ✅ "Health Assessment" tile
- **Service/Repository:** None (local UI only)
- **Model:** None (local state)
- **Backend Dependency:** None currently
- **Hive Dependency:** None
- **Description:** Symptom checklist (12 symptoms bilingual), pain slider (0-10), duration picker
- **Current Functionality:**
  - 12 symptom FilterChips (Fever, Headache, Cough, Shortness of breath, Chest pain, Nausea, Vomiting, Diarrhoea, Fatigue, Body ache, Rash, Dizziness)
  - Pain level slider (0-10)
  - Duration dropdown (Today, Yesterday, 2-3 days, More than 3 days)
  - Submit button
- **Data Flow:** Local only - does NOT save to Hive/Firebase
- **Upgrade Target:** ➡️ Full AI Triage with backend integration

---

### 3. Health Locker
- **Screen:** `lib/features/patient/health_locker/health_locker_screen.dart`
- **Route:** `/patient/health-locker`
- **Status:** ✅ Working (basic document storage)
- **Dashboard Entry:** ✅ "Health Locker" tile
- **Service/Repository:** Firebase Storage (direct upload)
- **Model:** None (uses Firebase Storage paths)
- **Backend Dependency:** Firebase Storage
- **Hive Dependency:** None
- **Description:** Document upload/viewer for medical records (prescriptions, reports, scans)
- **Current Functionality:**
  - Grid view of uploaded documents
  - Image picker for upload
  - Firebase Storage upload
  - Document display
- **Limitations:**
  - No OCR
  - No categorization
  - No ABDM health record fetch
  - No timeline view
- **Upgrade Target:** ➡️ Full longitudinal Health Records with timeline, filtering, search

---

### 4. Book Appointment
- **Screen:** `lib/features/patient/appointment/appointment_booking_screen.dart`
- **Route:** `/patient/appointment`
- **Status:** ⚠️ Partial (UI complete, backend not fully verified)
- **Dashboard Entry:** ✅ "Book Appointment" tile
- **Service/Repository:** `lib/data/repositories/appointment_repository.dart`
- **Model:** `lib/data/models/appointment_model.dart`
- **Backend Dependency:** Firestore `appointments` collection
- **Hive Dependency:** None
- **Description:** 4-step appointment booking wizard
- **Current Functionality:**
  - Step 1: Select facility (hardcoded: PHC Rampur, CHC Bijnor, District Hospital)
  - Step 2: Select doctor (hardcoded: Dr. Anita Singh, Dr. Ramesh Gupta, Dr. Priya Sharma)
  - Step 3: Select date (calendar picker)
  - Step 4: Select time slot (hardcoded: 9AM, 10AM, 11AM, 2PM, 3PM, 4PM)
  - Confirmation with token number
- **Repository Methods:**
  - `bookAppointment(patientId, facilityId, doctorId, datetime)` → returns appointmentId
  - `streamAppointment(appointmentId)` → Firestore listener
  - `streamPatientAppointments(patientId)` → Firestore query
- **Limitations:**
  - Hardcoded facilities/doctors
  - No real-time slot availability
  - No facility integration
- **Upgrade Target:** ➡️ Real facilities/doctors from backend, slot validation, queue management

---

### 5. Live Queue
- **Screen:** `lib/features/patient/queue/live_queue_screen.dart`
- **Route:** `/patient/queue`
- **Status:** ⚠️ Partial (UI placeholder, mock countdown)
- **Dashboard Entry:** ✅ "Live Queue" tile
- **Service/Repository:** None (mock logic)
- **Model:** Uses `AppointmentModel` (appointmentId passed as route param)
- **Backend Dependency:** None currently
- **Hive Dependency:** None
- **Description:** Real-time queue position display
- **Current Functionality:**
  - Animated queue position (e.g., "You are #5 in queue")
  - Mock countdown timer
  - Static estimated wait time
- **Limitations:**
  - No real queue management system
  - No Firestore listener
  - No push notification on turn
- **PRESERVATION:** ✅ **MUST KEEP** - Approved mobile-only feature
- **Upgrade Target:** ➡️ Real-time Firestore/Socket.IO integration, live wait time, turn notifications

---

### 6. Teleconsult
- **Screen:** `lib/features/patient/teleconsult/teleconsult_screen.dart`
- **Route:** `/patient/teleconsult`
- **Status:** ⚠️ Placeholder only (no WebRTC)
- **Dashboard Entry:** ✅ "Tele-consult" tile
- **Service/Repository:** None
- **Model:** None
- **Backend Dependency:** None currently
- **Hive Dependency:** None
- **Description:** Video call interface (UI only)
- **Current Functionality:**
  - Video call UI (dark theme)
  - Mic/video/chat control buttons
  - Self-preview positioning
  - Chat message list
  - Static "Connecting to doctor..." state
- **Limitations:**
  - No WebRTC integration
  - No signaling server
  - No actual video/audio streaming
- **Upgrade Target:** ➡️ Full WebRTC peer connection, Socket.IO signaling, doctor queue, consultation flow

---

### 7. Menstrual Tracker
- **Screen:** `lib/features/patient/menstrual_tracker/menstrual_tracker_screen.dart`
- **Route:** `/patient/menstrual`
- **Status:** ✅ Working
- **Dashboard Entry:** ✅ "Menstrual Tracker" tile
- **Service/Repository:** `lib/data/repositories/tracker_repository.dart`
- **Model:** `lib/data/models/tracker_entry_model.dart` (type='menstrual')
- **Backend Dependency:** Firestore `tracker_entries` collection
- **Hive Dependency:** `trackerBox` (Box<TrackerEntryModel>)
- **Description:** Period tracking with calendar and symptom logging
- **Current Functionality:**
  - Table calendar with period marking
  - Period start/end date selection
  - Flow intensity (light, moderate, heavy)
  - Symptom checkboxes (cramps, fatigue, mood swings, bloating, headache, nausea, acne)
  - Cycle history
  - Basic cycle prediction
- **Data Structure:**
```dart
{
  "period_start": "2026-09-15",
  "period_end": "2026-09-20",
  "flow": "moderate",
  "symptoms": ["cramps", "fatigue"]
}
```
- **PRESERVATION:** ✅ **MUST KEEP** - Working feature
- **Upgrade:** Expand only if needed for web parity

---

### 8. Pregnancy Tracker
- **Screen:** `lib/features/patient/pregnancy_tracker/pregnancy_tracker_screen.dart`
- **Route:** `/patient/pregnancy`
- **Status:** ✅ Working
- **Dashboard Entry:** ✅ "Pregnancy Tracker" tile
- **Service/Repository:** `lib/data/repositories/tracker_repository.dart`
- **Model:** `lib/data/models/tracker_entry_model.dart` (type='pregnancy')
- **Backend Dependency:** Firestore `tracker_entries` collection
- **Hive Dependency:** `trackerBox` (Box<TrackerEntryModel>)
- **Description:** Pregnancy monitoring with ANC checklist and week-by-week content
- **Current Functionality:**
  - Gestational week display
  - ANC visit checklist (1st ANC, Blood & Urine Test, Ultrasound, 2nd ANC, Glucose Test, 3rd ANC, 4th ANC)
  - Week-by-week pregnancy tips
  - Weight tracking
  - Blood pressure tracking
  - Checkup type logging
  - Notes field
- **Data Structure:**
```dart
{
  "week": 24,
  "weight": 68.5,
  "bp_systolic": 125,
  "bp_diastolic": 82,
  "checkup_type": "2nd ANC Visit",
  "notes": "All tests normal"
}
```
- **PRESERVATION:** ✅ **MUST KEEP** - Working feature

---

### 9. Child Vaccination
- **Screen:** `lib/features/patient/child_vaccination/child_vaccination_screen.dart`
- **Route:** `/patient/child-vaccination`
- **Status:** ✅ Working
- **Dashboard Entry:** ✅ "Child Vaccination" tile
- **Service/Repository:** `lib/data/repositories/tracker_repository.dart`
- **Model:** `lib/data/models/tracker_entry_model.dart` (type='child_vaccination')
- **Backend Dependency:** Firestore `tracker_entries` collection
- **Hive Dependency:** `trackerBox` (Box<TrackerEntryModel>)
- **Description:** Child vaccination schedule with due dates
- **Current Functionality:**
  - Vaccination list (BCG, OPV, DPT, Hepatitis B, MMR, etc.)
  - Scheduled date
  - Administered date
  - Completion status
  - Due date reminders
- **Data Structure:**
```dart
{
  "vaccine_name": "DPT-1",
  "scheduled_date": "2026-10-01",
  "administered_date": "2026-10-01",
  "child_name": "Baby Sharma",
  "dose_number": 1
}
```
- **PRESERVATION:** ✅ **MUST KEEP** - Explicitly approved, merge with Vaccination Record without deletion

---

### 10. Vaccination Record
- **Screen:** `lib/features/patient/vaccination/vaccination_tracker_screen.dart`
- **Route:** `/patient/vaccination`
- **Status:** ✅ Working
- **Dashboard Entry:** ✅ "Vaccination Record" tile
- **Service/Repository:** `lib/data/repositories/tracker_repository.dart`
- **Model:** `lib/data/models/tracker_entry_model.dart` (type='vaccination')
- **Backend Dependency:** Firestore `tracker_entries` collection
- **Hive Dependency:** `trackerBox` (Box<TrackerEntryModel>)
- **Description:** Personal vaccination history (COVID, Typhoid, Tetanus, etc.)
- **Current Functionality:**
  - Vaccination history list
  - Vaccine name
  - Administered date
  - Next due date
  - Status (completed/due)
- **PRESERVATION:** ✅ **MUST KEEP** - Merge with Child Vaccination into unified Vaccination capability

---

### 11. Data Consent
- **Screen:** `lib/features/patient/consent/consent_screen.dart`
- **Route:** `/patient/consent`
- **Status:** ✅ Working (basic consent toggles)
- **Dashboard Entry:** ✅ "Data Consent" tile
- **Service/Repository:** None (stored in PatientModel)
- **Model:** `PatientModel.consentFlags` (Map<String, bool>)
- **Backend Dependency:** Firestore `patients` collection
- **Hive Dependency:** `patientBox` (Box<PatientModel>)
- **Description:** ABDM consent management UI
- **Current Functionality:**
  - Consent category toggles
  - Save to patient profile
  - Consent types: Research, Teleconsult, Data Sharing, etc.
- **Limitations:**
  - No ABDM consent manager integration
  - No audit log
  - No record-level authorization enforcement
- **PRESERVATION:** ✅ **MUST KEEP**
- **Upgrade Target:** ➡️ Backend audit log, record scoping, ABDM integration

---

### 12. My Medicines
- **Screen:** `lib/features/patient/medicine/medicine_screen.dart`
- **Route:** `/patient/medicine`
- **Status:** ⚠️ Partial (UI-only, no backend)
- **Dashboard Entry:** ✅ "My Medicines" tile
- **Service/Repository:** None currently
- **Model:** `lib/data/models/prescription_model.dart` (structure defined but not used)
- **Backend Dependency:** None currently
- **Hive Dependency:** None
- **Description:** Prescription list with dosage, timing, stock tracking
- **Current Functionality:**
  - Static UI showing medicine list
  - Medicine name, dosage, frequency display
  - No actual data persistence
- **Limitations:**
  - No prescription API
  - No reminder notifications
  - No adherence tracking
  - No refill alerts
- **Upgrade Target:** ➡️ Full Medicine Tracker with API, schedule, reminders, adherence, refill

---

### 13. Health Info
- **Screen:** `lib/features/patient/health_info/health_info_screen.dart`
- **Route:** `/patient/health-info`
- **Status:** ✅ Working (hardcoded content)
- **Dashboard Entry:** ✅ "Health Info" tile
- **Service/Repository:** None (static content)
- **Model:** None
- **Backend Dependency:** None currently
- **Hive Dependency:** None
- **Description:** Educational article list (disease prevention, nutrition, hygiene)
- **Current Functionality:**
  - Article cards with icons
  - Hardcoded placeholder text
  - Categories: Disease Prevention, Nutrition, Hygiene, First Aid, etc.
- **Limitations:**
  - No CMS integration
  - No multilingual content system
  - Static placeholder text
- **PRESERVATION:** ✅ **MUST KEEP** - Approved mobile-only feature
- **Upgrade:** Integrate backend content where available without breaking existing

---

### 14. Scheme Eligibility
- **Screen:** `lib/features/patient/scheme_eligibility/scheme_eligibility_screen.dart`
- **Route:** `/patient/scheme`
- **Status:** ⚠️ Partial (hardcoded rules)
- **Dashboard Entry:** ✅ "Scheme Eligibility" tile
- **Service/Repository:** None currently
- **Model:** None
- **Backend Dependency:** None currently
- **Hive Dependency:** None
- **Description:** Government scheme eligibility checker
- **Current Functionality:**
  - Scheme list cards (PMJAY, JSY, JSSK, etc.)
  - Eligibility check form (age, income placeholders)
  - Hardcoded eligibility rules
- **Limitations:**
  - No API verification
  - No AI scheme matching
  - No enrollment flow
  - No 80+ schemes database
- **PRESERVATION:** ✅ **MUST KEEP**
- **Upgrade Target:** ➡️ AI-powered matching with 80+ schemes, eligibility API, document requirements

---

### 15. Feedback & Grievance
- **Screen:** `lib/features/patient/feedback/feedback_screen.dart`
- **Route:** `/patient/feedback-grievance`
- **Status:** ⚠️ Partial (UI-only)
- **Dashboard Entry:** ✅ "Feedback" tile
- **Service/Repository:** None currently
- **Model:** None
- **Backend Dependency:** None currently
- **Hive Dependency:** None
- **Description:** Feedback submission form with rating
- **Current Functionality:**
  - Text feedback form
  - Star rating (1-5)
  - Submit button
  - Static UI only
- **Limitations:**
  - No Firestore collection
  - No submission backend
  - No admin dashboard
- **PRESERVATION:** ✅ **MUST KEEP** - Approved mobile-only feature
- **Upgrade:** Connect to backend API if available

---

### 16. Emergency SOS
- **Screen:** `lib/features/patient/emergency_sos/emergency_sos_screen.dart`
- **Route:** `/patient/sos`
- **Status:** ⚠️ Partial (dialer works, no backend alert)
- **Dashboard Entry:** ✅ Prominent red banner on dashboard + tile
- **Service/Repository:** None (uses url_launcher)
- **Model:** `lib/data/models/emergency_alert_model.dart` (defined but not used)
- **Backend Dependency:** None currently
- **Hive Dependency:** None
- **Description:** Emergency contact dialer and location sharing
- **Current Functionality:**
  - Big red emergency button
  - Emergency contact list (Ambulance 108, Police, Fire)
  - `url_launcher` to dial
  - Location sharing via SMS (geolocator)
- **Limitations:**
  - No Firestore alert logging
  - No automated dispatch
  - No backend emergency tracking
- **PRESERVATION:** ✅ **MUST KEEP** - Approved mobile-only feature
- **Upgrade:** Integrate backend emergency alert system where available

---

### 17. Patient Profile
- **Screen:** `lib/features/patient/profile/patient_profile_screen.dart`
- **Route:** `/patient/profile`
- **Status:** ✅ Working
- **Dashboard Entry:** AppBar profile icon (not a dashboard tile)
- **Service/Repository:** `lib/data/repositories/patient_repository.dart`
- **Model:** `lib/data/models/patient_model.dart`
- **Backend Dependency:** Firestore `patients` collection
- **Hive Dependency:** `patientBox` (Box<PatientModel>), `settingsBox` (session)
- **Description:** Patient profile editor and logout
- **Current Functionality:**
  - Display name, DOB, gender, phone, ABHA ID
  - Language preference toggle
  - Logout button
  - Edit profile (saves to Hive + Firestore)
- **PRESERVATION:** ✅ **MUST KEEP**
- **Security:** Ensure integration doesn't break session/logout behavior

---

## Authentication

### Patient Login
- **Screen:** `lib/features/auth/patient/patient_login_screen.dart`
- **Route:** `/patient/login`
- **Status:** ✅ Working
- **Service:** `lib/core/services/auth_service.dart`
- **Model:** None
- **Backend:** Firebase Phone Authentication
- **Flow:**
  1. Enter ABHA ID
  2. Phone number verification (hardcoded mapping currently, no NHA ABHA API)
  3. Navigate to OTP screen

### Patient OTP
- **Screen:** `lib/features/auth/patient/patient_otp_screen.dart`
- **Route:** `/patient/otp`
- **Status:** ✅ Working (keyboard-aware scroll, no overflow)
- **Service:** `lib/core/services/auth_service.dart`
- **Backend:** Firebase Phone Auth verification
- **Flow:**
  1. Receive SMS OTP
  2. Enter 6-digit code
  3. Verify with Firebase
  4. Persist role to Hive `settingsBox`
  5. Navigate to `/patient/home`

---

## Data Layer

### Models
| Model | File | Status | Hive | Firestore |
|-------|------|--------|------|-----------|
| PatientModel | `lib/data/models/patient_model.dart` | ✅ Active | Box<PatientModel> | `patients` |
| EncounterModel | `lib/data/models/encounter_model.dart` | ✅ Active (Worker-side) | Box<EncounterModel> | `encounters` |
| TrackerEntryModel | `lib/data/models/tracker_entry_model.dart` | ✅ Active | Box<TrackerEntryModel> | `tracker_entries` |
| AppointmentModel | `lib/data/models/appointment_model.dart` | ⚠️ Defined | None | `appointments` |
| PrescriptionModel | `lib/data/models/prescription_model.dart` | ⚠️ Defined, unused | None | `prescriptions` |
| EmergencyAlertModel | `lib/data/models/emergency_alert_model.dart` | ⚠️ Defined, unused | None | None |
| ReferralModel | `lib/data/models/referral_model.dart` | ⚠️ Defined, unused | None | `referrals` |
| FacilityModel | `lib/data/models/facility_model.dart` | ⚠️ Defined, unused | None | `facilities` |

### Repositories
| Repository | File | Used By | Status |
|------------|------|---------|--------|
| PatientRepository | `lib/data/repositories/patient_repository.dart` | Worker (Register Patient, Find Patient) | ✅ Active |
| TrackerRepository | `lib/data/repositories/tracker_repository.dart` | Menstrual, Pregnancy, Child Vaccination, Vaccination | ✅ Active |
| AppointmentRepository | `lib/data/repositories/appointment_repository.dart` | Book Appointment, Live Queue | ⚠️ Partial |
| EncounterRepository | `lib/data/repositories/encounter_repository.dart` | Worker (Vitals, Symptom, Triage) | ✅ Active (Worker-side) |

### Hive Boxes
| Box Name | Type | Purpose | Used By |
|----------|------|---------|---------|
| `settings` | Box<dynamic> | Session, language, user role | All features |
| `patients` | Box<PatientModel> | Patient demographics cache | Worker + Profile |
| `tracker_entries` | Box<TrackerEntryModel> | Menstrual, pregnancy, vaccination data | Patient trackers |
| `encounters` | Box<EncounterModel> | Clinical encounters | Worker-side |
| `pending_sync` | Box<dynamic> | Offline sync queue | Sync service |

---

## Services

### Core Services
| Service | File | Purpose | Used By |
|---------|------|---------|---------|
| AuthService | `lib/core/services/auth_service.dart` | Firebase Phone Auth (Patient + Worker) | Login flows |
| SyncService | `lib/core/services/sync_service.dart` | Offline sync (patients, encounters, trackers) | Worker dashboard, auto-sync |
| ConnectivityService | `lib/core/services/connectivity_service.dart` | Network state monitoring | All features |
| NotificationService | `lib/core/services/notification_service.dart` | ⚠️ Placeholder only | None (disabled) |

---

## Navigation

### Patient Routes (17 total)
```dart
'/patient/home'                  // Dashboard
'/patient/health-assessment'     // Health Assessment → upgrade to AI Triage
'/patient/health-locker'         // Health Locker → upgrade to Health Records
'/patient/appointment'           // Book Appointment → upgrade
'/patient/queue'                 // Live Queue → real-time upgrade
'/patient/teleconsult'           // Teleconsult → WebRTC implementation
'/patient/menstrual'             // Menstrual Tracker → keep
'/patient/pregnancy'             // Pregnancy Tracker → keep
'/patient/child-vaccination'     // Child Vaccination → merge with vaccination
'/patient/vaccination'           // Vaccination Record → merge with child vaccination
'/patient/consent'               // Data Consent → upgrade
'/patient/medicine'              // My Medicines → upgrade to Medicine Tracker
'/patient/health-info'           // Health Info → keep, integrate backend
'/patient/scheme'                // Scheme Eligibility → upgrade with AI
'/patient/feedback'              // Feedback → keep, connect backend
'/patient/sos'                   // Emergency SOS → keep, connect backend
'/patient/profile'               // Profile → keep, preserve session
```

### Shared Routes (3 total)
```dart
'/'                              // Splash screen
'/language-select'               // Language picker (en/hi)
'/role-select'                   // Patient vs Worker role selection
```

### Auth Routes (2 Patient)
```dart
'/patient/login'                 // ABHA ID entry
'/patient/otp'                   // OTP verification
```

---

## UI Components

### Shared Widgets
| Widget | File | Purpose |
|--------|------|---------|
| ScAppBar | `lib/features/shared/widgets/sc_app_bar.dart` | Consistent app bar |
| ScButton | `lib/features/shared/widgets/sc_button.dart` | Primary/secondary buttons |
| ScCard | `lib/features/shared/widgets/sc_card.dart` | DashboardTile, feature cards |
| ScTextField | `lib/features/shared/widgets/sc_text_field.dart` | Consistent text input |
| SyncBadge | `lib/features/shared/widgets/sync_badge.dart` | Sync status indicator |
| EmptyState | `lib/features/shared/widgets/empty_state.dart` | No data placeholder |
| InfoBanner | `lib/features/shared/widgets/info_banner.dart` | Info messages |
| LoadingOverlay | `lib/features/shared/widgets/loading_overlay.dart` | Loading indicator |

### Theme
- **File:** `lib/core/theme/app_theme.dart`
- **Colors:** `lib/core/constants/app_colors.dart`
- **Text Styles:** `lib/core/constants/app_text_styles.dart`
- **Design:** Mobile-first, material design, green/blue theme
- **Responsive:** Text scaling clamped (0.85-1.3), scrollable layouts

---

## Localization

### Current Support
- **English** (en)
- **Hindi** (hi)

### Files
- `lib/core/l10n/app_localizations.dart`
- `lib/l10n/` (generated)

### Target
- Add **Marathi** (mr) for Patient-side

---

## Backend Integration (Current)

### Firebase
- **Auth:** Phone OTP (working)
- **Firestore Collections:**
  - `patients` (active)
  - `encounters` (active, Worker-side)
  - `tracker_entries` (active)
  - `appointments` (partial)
  - `frontline_workers` (Worker auth lookup)
- **Storage:** Firebase Storage (Health Locker uploads)

### No REST API
- ❌ No Dio/HTTP client
- ❌ No REST endpoints
- ❌ All backend via Firebase SDK

---

## Known Limitations (Pre-Integration)

### Backend
1. No ABHA verification API (hardcoded phone mapping)
2. No REST API layer
3. Hardcoded facilities/doctors in appointments
4. No real-time queue management
5. No WebRTC signaling server
6. No notification system
7. No OCR integration
8. No AI/ML triage
9. No medicine prescription API
10. No referral tracking system

### Features
1. Health Assessment: Local-only, no triage scoring
2. Health Locker: Basic upload, no timeline/categorization
3. My Medicines: UI-only, no data
4. Teleconsult: Placeholder UI only
5. Live Queue: Mock countdown
6. Feedback: No submission backend
7. Emergency SOS: No alert logging
8. Scheme Eligibility: Hardcoded rules

### Data
1. No conflict resolution in sync
2. Last-write-wins for offline conflicts
3. No family member support
4. No referral data
5. No consultation records
6. No prescription history

---

## Testing Status

### Working Features
✅ Patient login/OTP  
✅ Patient dashboard  
✅ Menstrual tracker (full cycle)  
✅ Pregnancy tracker (full cycle)  
✅ Child vaccination (full cycle)  
✅ Vaccination record (full cycle)  
✅ Health locker upload  
✅ Patient profile edit  
✅ Emergency SOS dialer  
✅ Offline Hive storage  
✅ Firebase sync when online  

### Partial Features
⚠️ Health Assessment (no backend)  
⚠️ Appointments (hardcoded data)  
⚠️ Live Queue (mock)  
⚠️ Teleconsult (UI only)  
⚠️ My Medicines (UI only)  
⚠️ Consent (no audit)  
⚠️ Scheme Eligibility (hardcoded)  
⚠️ Feedback (no backend)  
⚠️ Health Info (static)  

### Build Status
✅ flutter analyze passes  
✅ Android debug APK builds  
✅ No overflow errors  
✅ No Hive type errors  
✅ Firebase auth working  

---

## Preservation Requirements

### DO NOT REMOVE
1. ✅ Live Queue feature
2. ✅ Health Info feature
3. ✅ Feedback feature
4. ✅ Emergency SOS feature
5. ✅ Profile feature
6. ✅ Child Vaccination feature (merge, don't delete)
7. ✅ Menstrual Tracker
8. ✅ Pregnancy Tracker
9. ✅ Vaccination Record (merge with Child Vaccination)
10. ✅ Data Consent
11. ✅ Scheme Eligibility

### DO NOT BREAK
1. ✅ Worker functionality (protected, out of scope)
2. ✅ Firebase Phone Auth
3. ✅ Offline-first Hive architecture
4. ✅ Existing mobile UI design (colors, typography, spacing)
5. ✅ GoRouter navigation
6. ✅ Riverpod state management
7. ✅ Responsive layouts (no overflow)
8. ✅ Patient session/logout

---

## Integration Targets

### Features to Upgrade
1. **Health Assessment** → **AI Triage** (Groq, XGBoost, adaptive questions)
2. **Health Locker** → **Health Records** (timeline, filtering, search, consultations)
3. **My Medicines** → **Medicine Tracker** (API, reminders, adherence, refill)
4. **Appointments** → Real backend (facilities, doctors, slots, queue)
5. **Live Queue** → Real-time (Firestore listeners / Socket.IO)
6. **Teleconsult** → WebRTC (peer connection, signaling, consultation flow)
7. **Consent** → Backend (audit log, record scoping)
8. **Scheme Eligibility** → AI-powered (80+ schemes, Groq matching)

### Features to Add
1. **Referral Tracker** (new)
2. **Follow-ups** (new)
3. **Family Members** (new)

### Features to Merge
1. **Vaccination Record + Child Vaccination** → Unified Vaccination (preserve both)

---

## Summary Statistics

| Category | Count |
|----------|-------|
| **Total Patient Features** | 17 |
| **Working Features** | 10 |
| **Partial Features** | 7 |
| **Features to Upgrade** | 8 |
| **Features to Add** | 3 |
| **Features to Preserve** | 11 |
| **Patient Screens** | 17 |
| **Auth Screens (Patient)** | 2 |
| **Shared Screens** | 3 |
| **Active Models** | 3 |
| **Defined Models (unused)** | 5 |
| **Active Repositories** | 4 |
| **Active Hive Boxes** | 5 |
| **Firestore Collections Used** | 5 |
| **Languages Supported** | 2 (en, hi) |

---

**END OF BASELINE**

This document represents the complete state of the Patient application BEFORE web integration. Every feature listed here must remain functional after integration unless explicitly removed (current REMOVE list: NONE).
