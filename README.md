# SwasthyaConnect

**A Comprehensive Healthcare Mobile Application for Rural India**

[![Flutter](https://img.shields.io/badge/Flutter-3.24.3-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.3-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📱 About the Project

**SwasthyaConnect** is a mobile healthcare application designed to bridge the gap between rural communities and quality healthcare services in India. The app provides a dual-interface system catering to both patients and frontline health workers (ASHA workers, ANMs, etc.).

### 🏥 Project Information

- **Team Name:** HealthSync1
- **Team ID:** 165109
- **Developer:** akshaypandey01
- **Platform:** Android (Flutter)
- **Target Audience:** Rural communities and frontline health workers in India

---

## ✨ Key Features

### For Patients 👥

1. **Health Assessment** - AI-powered symptom checker and triage
2. **Health Locker** - Secure storage for medical records and documents
3. **Appointment Booking** - Schedule consultations with healthcare providers
4. **Live Queue Management** - Real-time appointment status tracking
5. **Teleconsultation** - Video/audio consultation with doctors
6. **Family Health Management** - Add and manage family members' health records
7. **Referral Tracking** - Track hospital referrals and status
8. **Follow-up Reminders** - Automated reminders for appointments and medication
9. **Health Trackers:**
   - Menstrual Cycle Tracker
   - Pregnancy Tracker
   - Child Vaccination Tracker
   - General Vaccination Tracker
10. **Medicine Management** - Track prescriptions and medication schedules
11. **Health Information Hub** - Access to health education content
12. **Scheme Eligibility Checker** - Check eligibility for government health schemes
13. **Emergency SOS** - Quick access to emergency services
14. **Feedback & Grievance** - Submit feedback and complaints

### For Frontline Health Workers 🏥

1. **Patient Registration** - Register new patients with ABHA ID integration
2. **Patient Search & Management** - Quick search and access patient records
3. **Vitals Entry** - Record patient vital signs
4. **Symptom Input** - Multi-modal symptom recording (text, voice, photo)
5. **AI-Powered Triage** - Automated risk assessment and prioritization
6. **Referral Management:**
   - Create referrals to higher facilities
   - Track referral status
   - View referral history
7. **Reports & Analytics:**
   - Performance dashboard
   - Assigned patients list
   - Pending tasks management
   - Critical alerts monitoring
8. **Notifications & Alerts:**
   - Patient health alerts
   - Task reminders
   - System notifications
9. **Document Upload** - Upload medical records and reports
10. **Teleconsult Facilitation** - Assist patients in teleconsultations
11. **Emergency Escalation** - Quick escalation of critical cases
12. **Follow-up Management** - Schedule and track patient follow-ups
13. **Sync Status** - Offline-first with background synchronization

---

## 🛠️ Technology Stack

- **Framework:** Flutter 3.24.3
- **Language:** Dart 3.5.3
- **State Management:** Riverpod
- **Local Database:** Hive
- **Backend:** Firebase (Authentication, Firestore, Storage)
- **Navigation:** GoRouter
- **Architecture:** Feature-based modular architecture
- **Data Storage:** Offline-first with sync capabilities

---

## 📦 Dependencies

### Core
- `flutter_riverpod` - State management
- `hive` & `hive_flutter` - Local database
- `go_router` - Navigation and routing

### Firebase
- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Cloud database
- `firebase_storage` - File storage

### UI/UX
- `google_fonts` - Typography
- `lottie` - Animations
- `shimmer` - Loading effects
- `cached_network_image` - Image caching
- `fl_chart` - Data visualization

### Utilities
- `image_picker` - Camera and gallery access
- `camera` - Camera functionality
- `connectivity_plus` - Network status
- `geolocator` - Location services
- `url_launcher` - External link handling
- `share_plus` - Share functionality
- `permission_handler` - Runtime permissions

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.24.3 or higher
- Dart SDK 3.5.3 or higher
- Android Studio / VS Code
- Android SDK (API level 21+)
- Firebase project setup

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/akshaypandey01/Swasthya_Connect.git
   cd Swasthya_Connect
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Add `google-services.json` to `android/app/`
   - Update Firebase configuration in the project

4. **Run the app:**
   ```bash
   flutter run
   ```

5. **Build APK:**
   ```bash
   flutter build apk --release
   ```

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   ├── router/          # Navigation configuration
│   ├── services/        # Core services (auth, sync, connectivity)
│   └── theme/           # App theme and styling
├── data/
│   ├── models/          # Data models
│   └── repositories/    # Data repositories
├── features/
│   ├── patient/         # Patient-side features
│   ├── worker/          # Worker-side features
│   ├── auth/            # Authentication screens
│   └── shared/          # Shared widgets and utilities
└── main.dart            # App entry point
```

---

## 🎨 Design System

- **Primary Color:** Blue (#1976D2)
- **Secondary Color:** Teal (#00897B)
- **Typography:** Roboto (via Google Fonts)
- **Icons:** Material Icons
- **Components:** Custom reusable widgets (ScButton, ScCard, ScAppBar, etc.)

---

## 🔒 Security Features

- Secure local storage with Hive encryption
- Firebase Authentication
- ABHA ID integration
- Role-based access control
- Secure document storage
- Data encryption in transit

---

## 🌐 Offline Capability

- Offline-first architecture
- Local data caching with Hive
- Background synchronization
- Conflict resolution
- Sync status tracking
- Pending operations queue

---

## 📱 Supported Platforms

- ✅ Android (API 21+)
- 🚧 iOS (Planned)
- 🚧 Web (Planned)

---

## 👥 Team HealthSync1

**Team ID:** 165109

This project is developed as part of a healthcare innovation initiative to improve healthcare accessibility in rural India.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📞 Contact

**Developer:** akshaypandey01

**Project Link:** [https://github.com/akshaypandey01/Swasthya_Connect](https://github.com/akshaypandey01/Swasthya_Connect)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Open source community for the dependencies
- Healthcare workers for their valuable insights

---

**Made with ❤️ for improving rural healthcare in India**
