# Patient Web-to-Mobile Parity Matrix

**Generated:** September 20, 2026  
**Purpose:** Map 14 web Patient Portal features to mobile implementation strategy  
**Integration Type:** Functional integration preserving mobile UI

---

## Integration Strategy Overview

### Formula
```
FINAL MOBILE APP = 
  Existing Mobile Features (17)
  + Web Features Merged/Upgraded (8)
  + New Web Features Added (3)
  - Removed Features (0)
  
  = 17 + 3 = 20 Patient Features Total
```

### Categories
- **KEEP:** Preserve existing mobile feature as-is
- **UPGRADE:** Expand existing mobile feature with web functionality
- **MERGE:** Combine multiple features into unified experience
- **ADD:** Create new mobile feature from web

---

## Parity Matrix

| # | Web Feature | Mobile Feature | Action | Existing Screen | New/Modified Screen | Backend/API | Firestore Collection | Offline Support | Real-time Support | Current Status | Remaining Gap |
|---|-------------|----------------|--------|-----------------|---------------------|-------------|---------------------|-----------------|-------------------|----------------|---------------|
| **1** | **Dashboard** | Patient Home | KEEP + ENHANCE | `patient_home_screen.dart` | Same (add tiles for new features) | None | None | N/A | N/A | ✅ Working | Add 3 new feature tiles (Referral, Follow-ups, Family) |
| **2** | **AI Triage** | Health Assessment | UPGRADE | `health_assessment_screen.dart` | Same file + triage flow screens | `POST /api/triage/start`<br>`POST /api/triage/next-question`<br>`POST /api/triage/submit` | `triageSessions` | ✅ Offline fallback (rule-based) | ❌ Not needed | ⚠️ Local symptom checker only | AI integration, adaptive questions, risk scoring, offline triage |
| **3** | **Appointments** | Book Appointment | UPGRADE | `appointment_booking_screen.dart` | Same file (replace hardcoded data) | `GET /api/facilities?nearby=true`<br>`GET /api/facilities/:id/doctors`<br>`GET /api/appointments/slots`<br>`POST /api/appointments` | `appointments`<br>`facilities`<br>`doctors` | ⚠️ Partial (booking queue) | ✅ Queue position | ⚠️ Hardcoded facilities/doctors | Real facilities, slot validation, queue integration |
| **4** | **Health Records** | Health Locker | UPGRADE | `health_locker_screen.dart` | Same file + timeline view | `GET /api/patients/:id/records` | `consultations`<br>`labReports`<br>`prescriptions`<br>`vaccinations` | ✅ Cache records | ❌ Not needed | ⚠️ Upload-only, no timeline | Timeline, filtering, search, consultations, lab reports |
| **5** | **Teleconsultation** | Teleconsult | UPGRADE | `teleconsult_screen.dart` | Same file + WebRTC logic | `GET /api/doctors/available`<br>`POST /api/consultations`<br>Socket.IO events | `consultations` | ❌ Online-only | ✅ Required (WebRTC, queue) | ⚠️ UI placeholder only | WebRTC peer connection, signaling, doctor queue, consultation flow |
| **6** | **Medicine Tracker** | My Medicines | UPGRADE | `medicine_screen.dart` | Same file + schedule/reminders | `GET /api/prescriptions?patientId=X&status=active`<br>`POST /api/medicine-logs` | `prescriptions`<br>`medicineLogs` | ✅ Logs cached | ⚠️ Reminders only | ⚠️ UI-only, no data | Prescription API, dosing schedule, notifications, adherence tracking |
| **7** | **Referral Tracker** | *(New)* | ADD | None | Create `referral_tracker_screen.dart` | `POST /api/referrals`<br>`PATCH /api/referrals/:id`<br>`GET /api/referrals/:id` | `referrals` | ✅ Cache referral state | ✅ Status updates | ❌ Not implemented | Full feature: lifecycle tracking, notifications, status updates |
| **8** | **Follow-ups** | *(New)* | ADD | None | Create `follow_ups_screen.dart` | `GET /api/follow-ups?patientId=X`<br>`PATCH /api/follow-ups/:id` | `followUps` | ✅ Cache follow-up list | ⚠️ Due date reminders | ❌ Not implemented | Full feature: list, reminders, reschedule, mark completed |
| **9** | **Family Members** | *(New)* | ADD | None | Create `family_members_screen.dart` | `GET /api/family-members?userId=X`<br>`POST /api/family-members`<br>`PATCH /api/family-members/:id` | `familyMembers` | ✅ Cache family list | ❌ Not needed | ❌ Not implemented | Full feature: add, link, permissions, shared records, book for dependent |
| **10** | **Menstrual Tracker** | Menstrual Tracker | KEEP | `menstrual_tracker_screen.dart` | Same (no changes needed) | None (may add sync API later) | `tracker_entries` (type='menstrual') | ✅ Working | ❌ Not needed | ✅ Working | None - feature complete for current scope |
| **11** | **Pregnancy Tracker** | Pregnancy Tracker | KEEP | `pregnancy_tracker_screen.dart` | Same (no changes needed) | None (may add sync API later) | `tracker_entries` (type='pregnancy') | ✅ Working | ❌ Not needed | ✅ Working | None - feature complete for current scope |
| **12** | **Vaccination Tracker** | Vaccination Record + Child Vaccination | MERGE | `vaccination_tracker_screen.dart`<br>`child_vaccination_screen.dart` | Create unified `vaccination_screen.dart` or expand existing | `GET /api/vaccinations?patientId=X`<br>`POST /api/vaccinations` | `tracker_entries` (type='vaccination', 'child_vaccination') | ✅ Working | ❌ Not needed | ✅ Both working separately | Unified UI preserving child-specific workflow, adult vaccination history |
| **13** | **Consent Management** | Data Consent | KEEP + ENHANCE | `consent_screen.dart` | Same (add audit trail view) | `GET /api/consents?patientId=X`<br>`POST /api/consents`<br>`PATCH /api/consents/:id` | `consents`<br>`consentAudits` | ✅ Local consent state | ❌ Not needed | ✅ Working (basic toggles) | Backend audit log, record-level authorization, consent history |
| **14** | **Scheme Checker** | Scheme Eligibility | UPGRADE | `scheme_eligibility_screen.dart` | Same file (replace hardcoded) | `POST /api/schemes/check` | `schemes` (80+ scheme database) | ✅ Cache results | ❌ Not needed | ⚠️ Hardcoded rules | AI matching (Groq), 80+ schemes, confidence scores, application tracking |

---

## Mobile-Only Features (Preserved)

These features exist in mobile but NOT in the web Patient Portal. They must be preserved.

| # | Feature | Screen | Route | Status | Backend Integration Plan |
|---|---------|--------|-------|--------|--------------------------|
| **15** | **Live Queue** | `live_queue_screen.dart` | `/patient/queue` | ⚠️ Mock countdown | UPGRADE with Firestore listeners or Socket.IO for real queue position |
| **16** | **Health Info** | `health_info_screen.dart` | `/patient/health-info` | ✅ Hardcoded content | KEEP + integrate backend CMS API if available |
| **17** | **Feedback** | `feedback_screen.dart` | `/patient/feedback-grievance` | ⚠️ UI-only | KEEP + connect to backend submission API if available |
| **18** | **Emergency SOS** | `emergency_sos_screen.dart` | `/patient/sos` | ⚠️ Dialer only | KEEP + integrate backend emergency alert logging if available |
| **19** | **Profile** | `patient_profile_screen.dart` | `/patient/profile` | ✅ Working | KEEP (no changes unless session/auth requires it) |
| **20** | **Child Vaccination** | `child_vaccination_screen.dart` | `/patient/child-vaccination` | ✅ Working | MERGE with Vaccination (see #12) - DO NOT DELETE |

---

## API Integration Requirements

### Required APIs (Critical)

| Priority | Endpoint | Method | Purpose | Mobile Feature |
|----------|----------|--------|---------|----------------|
| **P0** | `/api/triage/start` | POST | Start AI triage session | AI Triage |
| **P0** | `/api/triage/next-question` | POST | Get adaptive next question | AI Triage |
| **P0** | `/api/triage/submit` | POST | Submit triage, get risk score | AI Triage |
| **P0** | `/api/facilities?nearby=true` | GET | Get facility list | Appointments |
| **P0** | `/api/facilities/:id/doctors` | GET | Get doctors for facility | Appointments |
| **P0** | `/api/appointments/slots` | GET | Get available slots | Appointments |
| **P0** | `/api/appointments` | POST | Book appointment | Appointments |
| **P0** | `/api/patients/:id/records` | GET | Get patient health records | Health Records |
| **P0** | `/api/doctors/available` | GET | Get available doctors for teleconsult | Teleconsultation |
| **P0** | `/api/consultations` | POST | Create consultation session | Teleconsultation |
| **P1** | `/api/prescriptions` | GET | Get active prescriptions | Medicine Tracker |
| **P1** | `/api/medicine-logs` | POST | Log medicine taken | Medicine Tracker |
| **P1** | `/api/referrals` | POST | Create referral | Referral Tracker |
| **P1** | `/api/referrals/:id` | PATCH | Update referral status | Referral Tracker |
| **P1** | `/api/referrals/:id` | GET | Get referral details | Referral Tracker |
| **P1** | `/api/follow-ups` | GET | Get patient follow-ups | Follow-ups |
| **P1** | `/api/follow-ups/:id` | PATCH | Update follow-up | Follow-ups |
| **P2** | `/api/family-members` | GET | Get family members | Family Members |
| **P2** | `/api/family-members` | POST | Add family member | Family Members |
| **P2** | `/api/family-members/:id` | PATCH | Update family member | Family Members |
| **P2** | `/api/schemes/check` | POST | Check scheme eligibility (AI) | Scheme Checker |
| **P3** | `/api/consents` | GET | Get consent history | Consent Management |
| **P3** | `/api/consents` | POST | Create consent | Consent Management |
| **P3** | `/api/consents/:id` | PATCH | Update consent | Consent Management |

### Socket.IO Events (Real-time)

| Event | Direction | Purpose | Mobile Feature |
|-------|-----------|---------|----------------|
| `request-teleconsult` | Client → Server | Request teleconsult session | Teleconsultation |
| `new-consultation-request` | Server → Client | Doctor availability | Teleconsultation |
| `accept-teleconsult` | Server → Client | Doctor accepted | Teleconsultation |
| `join-room` | Client ↔ Server | Join video session | Teleconsultation |
| `queue-update` | Server → Client | Queue position changed | Live Queue |
| `referral-status-update` | Server → Client | Referral status changed | Referral Tracker |
| `emergency-alert` | Client → Server | Emergency SOS triggered | Emergency SOS |

---

## Firestore Collections

### Existing Collections (Used)
| Collection | Used By | Schema Status |
|------------|---------|---------------|
| `patients` | Patient Profile, Worker | ✅ Active |
| `tracker_entries` | Menstrual, Pregnancy, Child Vaccination, Vaccination | ✅ Active |
| `appointments` | Book Appointment, Live Queue | ⚠️ Partial (needs schema expansion) |
| `encounters` | Worker triage | ✅ Active (Worker-side) |
| `frontline_workers` | Worker auth | ✅ Active (Worker-side) |

### Collections to Add/Expand
| Collection | Purpose | Schema Needed | Priority |
|------------|---------|---------------|----------|
| `triageSessions` | AI triage sessions | ✅ Define | P0 |
| `facilities` | Healthcare facilities | ✅ Define | P0 |
| `doctors` | Doctor profiles, schedules | ✅ Define | P0 |
| `consultations` | Teleconsult sessions | ✅ Define | P0 |
| `prescriptions` | Medicine prescriptions | ⚠️ Model exists | P1 |
| `medicineLogs` | Medicine adherence logs | ✅ Define | P1 |
| `referrals` | Patient referrals | ⚠️ Model exists | P1 |
| `followUps` | Follow-up appointments | ✅ Define | P1 |
| `familyMembers` | Family/dependent records | ✅ Define | P2 |
| `schemes` | Government schemes database | ✅ Define | P2 |
| `consents` | Consent records | ✅ Define (expand PatientModel) | P2 |
| `consentAudits` | Consent audit trail | ✅ Define | P2 |
| `emergencyAlerts` | Emergency SOS events | ⚠️ Model exists | P3 |
| `labReports` | Lab test results | ✅ Define | P3 |
| `healthRecords` | Consolidated health records view | ✅ Define | P0 |

---

## Offline Support Strategy

| Feature | Online Behavior | Offline Behavior | Sync Strategy | Conflict Resolution |
|---------|-----------------|------------------|---------------|---------------------|
| **AI Triage** | Groq API → adaptive questions | Rule-based fallback | Queue completed triage for upload | Last-write-wins |
| **Appointments** | Real-time slot check → book | Queue booking request | Retry booking on reconnect | Server validation (reject if slot taken) |
| **Health Records** | Fetch + cache | Show cached records | N/A (read-only) | N/A |
| **Teleconsult** | WebRTC live | Not available (online-only) | N/A | N/A |
| **Medicine Tracker** | Fetch prescriptions, log doses | Show cached, queue logs | Upload logs when online | Merge logs by timestamp |
| **Referral Tracker** | Real-time status updates | Show cached state | Upload referral creation | Server authoritative for status |
| **Follow-ups** | Fetch + cache | Show cached list | Upload status changes | Server authoritative |
| **Family Members** | Fetch + CRUD | Show cached list, queue changes | Upload on reconnect | Last-write-wins |
| **Menstrual Tracker** | Sync to cloud | Full offline tracking | Auto-sync entries | Merge by entry_date |
| **Pregnancy Tracker** | Sync to cloud | Full offline tracking | Auto-sync entries | Merge by entry_date |
| **Vaccination** | Sync to cloud | Full offline tracking | Auto-sync entries | Merge by vaccine + date |
| **Consent** | Sync consents | Show cached state | Upload consent changes | Server authoritative + audit trail |
| **Scheme Checker** | AI matching | Cached results only | N/A (query-based) | N/A |
| **Live Queue** | Real-time listener | Not available (requires connection) | N/A | N/A |
| **Emergency SOS** | Immediate dial + alert log | Dial only | Queue alert for upload | Upload on reconnect |

---

## Real-time Features Requirements

| Feature | Real-time Method | Implementation | Library |
|---------|------------------|----------------|---------|
| **Live Queue** | Firestore listener OR Socket.IO | Subscribe to queue position changes | `cloud_firestore` OR `socket_io_client` |
| **Teleconsultation** | Socket.IO + WebRTC | Signaling for peer connection | `socket_io_client` + `flutter_webrtc` |
| **Referral Tracker** | Socket.IO OR Firestore | Status update notifications | `socket_io_client` OR `cloud_firestore` |
| **Appointment Queue** | Firestore listener | Queue token updates | `cloud_firestore` |
| **Emergency Alerts** | Socket.IO | Dispatch acknowledgment | `socket_io_client` |

---

## Notification Requirements

| Notification Type | Trigger | Delivery Method | Priority |
|-------------------|---------|-----------------|----------|
| Appointment reminder | 1 day before + 1 hour before | Local notification | P0 |
| Medicine reminder | Scheduled dose times | Local notification | P0 |
| Queue turn | Position = 1 | FCM + local | P0 |
| Teleconsult accepted | Doctor accepts | FCM | P0 |
| Follow-up due | 1 day before due date | Local notification | P1 |
| Referral accepted | Status change | FCM | P1 |
| Referral in transit | Status change | FCM | P1 |
| Vaccination due | 3 days before due | Local notification | P2 |
| Scheme eligibility result | AI processing complete | Local notification | P3 |

**Package:** Add `flutter_local_notifications` (compatible version) or alternative

---

## Localization Requirements

| Feature | Current Support | Target Support | New Strings Needed |
|---------|----------------|----------------|---------------------|
| All Patient features | en, hi | en, hi, **mr** (Marathi) | ~500 strings |
| AI Triage | N/A | en, hi, mr | ~100 questions + risk categories |
| Appointments | en, hi | en, hi, mr | Facility/doctor info, slot labels |
| Health Records | en, hi | en, hi, mr | Record type labels, timeline |
| Teleconsult | en, hi | en, hi, mr | Connection states, controls |
| Medicine Tracker | en, hi | en, hi, mr | Dosing instructions, reminders |
| Referral Tracker | N/A | en, hi, mr | Status labels, urgency levels |
| Follow-ups | N/A | en, hi, mr | Due states, action labels |
| Family Members | N/A | en, hi, mr | Relation types, permissions |
| Vaccination | en, hi | en, hi, mr | Vaccine names (keep standard names) |
| Scheme Checker | en, hi | en, hi, mr | Scheme names, eligibility criteria |

---

## UI/Visual Strategy

### Principle: Preserve Mobile Identity

| Element | Web Approach | Mobile Approach | Action |
|---------|--------------|-----------------|--------|
| **Layout** | Desktop sidebar + multi-column | Mobile single column + bottom nav | Keep mobile pattern |
| **Colors** | Web theme (unknown) | SwasthyaConnect green/blue | **Keep mobile colors** |
| **Typography** | Web fonts | Google Fonts (existing) | **Keep mobile fonts** |
| **Navigation** | Sidebar | Dashboard tiles + GoRouter | **Keep mobile navigation** |
| **Cards** | Web card style | ScCard component | **Keep mobile cards** |
| **Buttons** | Web buttons | ScButton component | **Keep mobile buttons** |
| **Forms** | Web form style | ScTextField component | **Keep mobile text fields** |
| **Modals** | Desktop modals | Bottom sheets / dialogs | Use mobile patterns |
| **Tables** | Desktop data tables | Card lists / scrollable | Use mobile list views |
| **Charts** | Web charts | fl_chart | Keep existing chart style |
| **Calendar** | Web calendar | table_calendar | Keep existing calendar |
| **Spacing** | Web spacing | Mobile spacing (existing) | **Keep mobile spacing** |

### Dashboard Integration
- **Keep:** Existing patient dashboard design (gradient header, grid tiles)
- **Add:** 3 new tiles (Referral Tracker, Follow-ups, Family Members)
- **Update:** Existing tiles point to upgraded features (no visual change)
- **Layout:** Maintain 2-column grid on phone, 4-column on tablet

---

## Security & Permissions

### Required Permissions (Android)
| Permission | Purpose | Features Using |
|------------|---------|----------------|
| CAMERA | Camera capture | Health Locker, Teleconsult |
| MICROPHONE | Voice input, teleconsult | Teleconsult |
| LOCATION | Emergency SOS, nearby facilities | Emergency SOS, Appointments |
| INTERNET | API calls, Firebase | All features |
| NOTIFICATIONS | Reminders, alerts | Medicine, Appointments, Follow-ups |
| STORAGE | Photo picker, document access | Health Locker |

### Data Security
| Data Type | Sensitivity | Protection Required |
|-----------|-------------|---------------------|
| Patient health records | Critical | Encrypted at rest, HTTPS in transit, patient-scoped access |
| Triage responses | High | Patient-scoped access, consent required |
| Prescriptions | High | Patient-scoped access |
| Family member data | High | Permission-based access |
| Consultation records | Critical | Patient-scoped, consent required |
| Consent records | Critical | Audit trail, immutable log |
| Emergency alerts | High | Immediate dispatch, location privacy |
| Appointment bookings | Medium | Patient-scoped access |
| Tracker data (menstrual, pregnancy) | High | Patient-scoped access, consent required |

### Authentication Updates
- **Current:** Firebase Phone Auth (working)
- **Required:** JWT token management for REST API calls
- **Option 1:** Use Firebase ID token as bearer token
- **Option 2:** Exchange Firebase token for backend JWT
- **Token Storage:** Secure storage (flutter_secure_storage)
- **Token Refresh:** Automatic refresh before expiry
- **Logout:** Clear tokens + Firebase sign out

---

## Dependencies to Add

### Required
| Package | Purpose | Version Constraint |
|---------|---------|-------------------|
| `dio` | HTTP client for REST API | ^5.0.0 |
| `socket_io_client` | Real-time Socket.IO | ^2.0.0 |
| `flutter_webrtc` | WebRTC video calls | ^0.9.0 |
| `flutter_local_notifications` | Local notifications | Compatible with Flutter 3.24.3 |
| `flutter_secure_storage` | Secure token storage | ^9.0.0 |

### Optional (if needed)
| Package | Purpose |
|---------|---------|
| `firebase_messaging` | FCM push notifications (if not using local only) |
| `workmanager` | Background sync (if periodic sync needed) |
| `path` | File path manipulation |
| `mime` | MIME type detection |
| `file_picker` | Document picker (if expanding Health Locker) |

---

## Testing Requirements

### Feature Testing Matrix

| Feature | Online | Offline | Reconnect | Failed Request | Empty Data | Invalid Data | Permission Denied |
|---------|--------|---------|-----------|----------------|------------|--------------|-------------------|
| AI Triage | ✅ | ✅ Fallback | ✅ Sync | ✅ Retry | N/A | ✅ Validation | N/A |
| Appointments | ✅ | ✅ Queue | ✅ Sync | ✅ Retry | ✅ Empty | ✅ Validation | N/A |
| Health Records | ✅ | ✅ Cache | ✅ Refresh | ✅ Cache | ✅ Empty | N/A | ✅ Consent check |
| Teleconsult | ✅ | ❌ Offline msg | ✅ Reconnect | ✅ Retry | ✅ No doctors | N/A | ✅ Cam/mic denied |
| Medicine Tracker | ✅ | ✅ Cache | ✅ Sync logs | ✅ Retry | ✅ Empty | ✅ Validation | ✅ Notification |
| Referral Tracker | ✅ | ✅ Cache | ✅ Sync | ✅ Retry | ✅ Empty | ✅ Validation | N/A |
| Follow-ups | ✅ | ✅ Cache | ✅ Sync | ✅ Retry | ✅ Empty | N/A | N/A |
| Family Members | ✅ | ✅ Cache | ✅ Sync | ✅ Retry | ✅ Empty | ✅ Validation | ✅ Permission |
| Vaccination | ✅ | ✅ Cache | ✅ Sync | ✅ Retry | ✅ Empty | ✅ Validation | N/A |
| Consent | ✅ | ✅ Cache | ✅ Sync | ✅ Retry | N/A | N/A | N/A |
| Scheme Checker | ✅ | ✅ Cache | ✅ | ✅ Retry | ✅ No schemes | ✅ Validation | N/A |

### Worker Regression Testing
After Patient integration, test:
- ✅ Worker login (RCH ID + OTP)
- ✅ Worker dashboard
- ✅ Find Patient
- ✅ Register Patient
- ✅ Vitals Entry
- ✅ Symptom Input
- ✅ Worker Triage Result
- ✅ Worker Sync

**Any regression = critical bug**

---

## Implementation Stages

### STAGE 1: Audit & Planning ✅
- [x] Create PATIENT_FEATURE_BASELINE.md
- [x] Create PATIENT_WEB_MOBILE_PARITY.md
- [ ] Verify routes, screens, repositories

### STAGE 2: Backend Foundation
- [ ] Create API configuration (base URL, environment)
- [ ] Add Dio HTTP client
- [ ] Implement JWT/token handling
- [ ] Create request/response interceptors
- [ ] Create error handling layer
- [ ] Create model mappers (Firestore ↔ API)

### STAGE 3: Core Upgrades
- [ ] Upgrade Health Assessment → AI Triage
- [ ] Upgrade Health Locker → Health Records
- [ ] Upgrade My Medicines → Medicine Tracker

### STAGE 4: Real-time Features
- [ ] Complete Appointments (backend integration)
- [ ] Upgrade Live Queue (real-time)
- [ ] Implement Teleconsultation (WebRTC)

### STAGE 5: New Features
- [ ] Add Referral Tracker
- [ ] Add Follow-ups
- [ ] Add Family Members

### STAGE 6: Remaining Upgrades
- [ ] Unify Vaccination (preserve Child Vaccination)
- [ ] Upgrade Consent Management
- [ ] Upgrade Scheme Checker (AI)
- [ ] Integrate Health Info (backend CMS)
- [ ] Integrate Feedback (backend API)
- [ ] Integrate Emergency SOS (backend alerts)

### STAGE 7: Finalization
- [ ] Implement notifications (local + FCM)
- [ ] Harden offline/sync (conflict detection)
- [ ] Add Marathi localization
- [ ] Comprehensive testing
- [ ] Worker regression testing
- [ ] Documentation

---

## Success Criteria

### Must Have (Blocking)
✅ All 17 existing Patient features preserved  
✅ 3 new features added (Referral, Follow-ups, Family)  
✅ 8 features upgraded (AI Triage, Health Records, Medicine, Appointments, Live Queue, Teleconsult, Consent, Scheme)  
✅ Vaccination unified (Child Vaccination preserved)  
✅ Mobile UI design preserved  
✅ Worker functionality untouched  
✅ No feature removed  
✅ No overflow errors  
✅ flutter analyze passes  
✅ Android debug build succeeds  

### Should Have (High Priority)
✅ API client architecture implemented  
✅ Real-time features working (Live Queue, Teleconsult)  
✅ WebRTC teleconsult working  
✅ Offline support for all capable features  
✅ Notifications implemented  
✅ Marathi localization added  

### Nice to Have (Medium Priority)
✅ Background sync (WorkManager)  
✅ Comprehensive error handling  
✅ Loading states for all features  
✅ Empty states for all lists  
✅ Pull-to-refresh where appropriate  

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking Worker functionality | Medium | Critical | Minimal shared code changes, comprehensive regression testing |
| WebRTC complexity on mobile | High | High | Use proven library (flutter_webrtc), isolate signaling logic, graceful degradation |
| Offline sync conflicts | High | Medium | Implement conflict detection, user notification, manual resolution UI |
| API base URL not available | High | Medium | Centralized configuration, clear documentation of missing values |
| Notification permission denial | High | Low | Graceful degradation, in-app reminders as fallback |
| Schema mismatch (Firestore ↔ API) | Medium | High | Explicit model mappers, schema documentation, staging environment testing |
| Real-time feature battery drain | Medium | Medium | Optimize listener lifecycle, add battery saver mode |
| Large app size (WebRTC) | High | Medium | Dynamic feature modules or web-based fallback |
| AI API latency in rural areas | High | High | Offline rule-based fallback, timeout handling, progress indicators |

---

## Open Questions / Configuration Needed

1. **API Base URL:** Where is the backend deployed? (Required for all API calls)
2. **WebRTC Signaling Server:** URL and authentication method?
3. **Socket.IO Server:** Same as REST API or separate?
4. **JWT vs Firebase ID Token:** Which authentication method does backend accept?
5. **Groq API Key:** Server-side only or client-side? (Must be server-side)
6. **FCM Project:** Use existing Firebase project or separate?
7. **STUN/TURN Servers:** Which servers for WebRTC? (Free or paid?)
8. **Notification Icons:** Android notification icon assets?
9. **Deep Links:** App links / universal links configuration?
10. **Environment Variables:** How to manage dev/staging/prod configs?

---

## Summary

**Total Patient Features After Integration:** 20

**Feature Breakdown:**
- Existing preserved: 11
- Existing upgraded: 8
- New added: 3
- Merged: 2 (into 1 unified Vaccination)
- Removed: 0

**Technical Changes:**
- Add REST API layer (Dio)
- Add real-time layer (Socket.IO + Firestore listeners)
- Add WebRTC peer connection
- Add notifications system
- Add 10+ new Firestore collections
- Add JWT/token management
- Add Marathi localization
- Extend SyncService for new entities
- Preserve all existing Worker functionality
- Preserve mobile UI design

**Integration Approach:**
- Functional integration (NOT visual redesign)
- Incremental implementation (7 stages)
- Worker protection (no unnecessary changes)
- Mobile identity preservation (colors, fonts, spacing, navigation)
- Offline-first architecture maintained
- Real backend integration (no fake data)

---

**END OF PARITY MATRIX**
