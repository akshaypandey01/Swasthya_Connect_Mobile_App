import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/hive_constants.dart';

// ─── Locale provider ────────────────────────────────────────────────────────

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadSaved();
  }

  void _loadSaved() {
    final box = Hive.box(HiveConstants.settingsBox);
    final code = box.get(HiveConstants.languageKey, defaultValue: 'en') as String;
    state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final box = Hive.box(HiveConstants.settingsBox);
    await box.put(HiveConstants.languageKey, locale.languageCode);
  }
}

// ─── Localizations delegate glue ────────────────────────────────────────────

class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

// ─── Strings map ────────────────────────────────────────────────────────────
// Extend this map as the app grows; use AppL10n.of(context).t('key') pattern.

class AppL10n {
  final Locale locale;
  AppL10n(this.locale);

  static AppL10n of(BuildContext context) {
    return AppL10n(Localizations.localeOf(context));
  }

  String t(String key) {
    final map = locale.languageCode == 'hi' ? _hi : _en;
    return map[key] ?? key;
  }

  static const Map<String, String> _en = {
    'app_name': 'SwasthyaConnect',
    'tagline': 'Your Health, Our Priority',
    'select_language': 'Select Language',
    'continue': 'Continue',
    'patient': 'Patient',
    'frontline_worker': 'Frontline Health Worker',
    'enter_abha': 'Enter ABHA ID',
    'enter_rch': 'Enter RCH ID',
    'enter_otp': 'Enter 6-digit OTP',
    'send_otp': 'Send OTP',
    'verify_otp': 'Verify OTP',
    'resend_otp': 'Resend OTP',
    'hello': 'Hello',
    'good_morning': 'Good morning',
    'good_afternoon': 'Good afternoon',
    'good_evening': 'Good evening',
    'health_assessment': 'Health Assessment',
    'health_locker': 'Health Locker',
    'appointments': 'Appointments',
    'live_queue': 'Live Queue',
    'teleconsult': 'Tele-consultation',
    'menstrual': 'Menstrual Tracker',
    'pregnancy': 'Pregnancy Tracker',
    'child_vaccination': 'Child Vaccination',
    'vaccination': 'Vaccination Record',
    'consent': 'Data Consent',
    'medicine': 'My Medicines',
    'health_info': 'Health Info',
    'scheme': 'Scheme Eligibility',
    'feedback': 'Feedback',
    'sos': 'Emergency SOS',
    'find_patient': 'Find Patient',
    'register_patient': 'Register Patient',
    'vitals': 'Record Vitals',
    'symptoms': 'Symptom Input',
    'triage': 'Triage Result',
    'upload_records': 'Upload Records',
    'emergency': 'Emergency',
    'sync_status': 'Sync Status',
    'pending': 'Pending',
    'synced': 'Synced',
    'sync_now': 'Sync Now',
    'offline_saved': 'Saved offline. Will sync when connected.',
    'save': 'Save',
    'cancel': 'Cancel',
    'submit': 'Submit',
    'next': 'Next',
    'back': 'Back',
    'loading': 'Loading…',
    'error': 'Something went wrong',
    'no_data': 'No records found',
    'search': 'Search',
    'call_ambulance': 'Call Ambulance',
    'generate_referral': 'Generate Referral',
    'notify_hospital': 'Notify Nearby Hospital',
    'sos_hold': 'Press and hold for Emergency SOS',
    'green': 'Stable',
    'yellow': 'Caution',
    'red': 'Urgent',
    'critical': 'Critical',
    'bp': 'Blood Pressure',
    'spo2': 'SpO₂',
    'temperature': 'Temperature',
    'weight': 'Weight',
    'voice_input': 'Voice Input',
    'text_input': 'Type Symptoms',
    'photo_input': 'Capture Photo',
    'abha_id': 'ABHA ID',
    'temp_id': 'Temporary ID',
    'register_abha': 'Register via ABHA ID',
    'register_temp': 'Register Offline (Temp ID)',
    'name': 'Full Name',
    'dob': 'Date of Birth',
    'gender': 'Gender',
    'phone': 'Phone Number',
    'address': 'Address',
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'profile': 'Profile',
    'settings': 'Settings',
    'logout': 'Logout',
    'language': 'Language',
  };

  static const Map<String, String> _hi = {
    'app_name': 'स्वास्थ्यकनेक्ट',
    'tagline': 'आपका स्वास्थ्य, हमारी प्राथमिकता',
    'select_language': 'भाषा चुनें',
    'continue': 'आगे बढ़ें',
    'patient': 'मरीज़',
    'frontline_worker': 'स्वास्थ्य कार्यकर्ता',
    'enter_abha': 'ABHA आईडी दर्ज करें',
    'enter_rch': 'RCH आईडी दर्ज करें',
    'enter_otp': '6 अंकों का OTP दर्ज करें',
    'send_otp': 'OTP भेजें',
    'verify_otp': 'OTP सत्यापित करें',
    'resend_otp': 'OTP पुनः भेजें',
    'hello': 'नमस्ते',
    'good_morning': 'सुप्रभात',
    'good_afternoon': 'शुभ अपराह्न',
    'good_evening': 'शुभ संध्या',
    'health_assessment': 'स्वास्थ्य जांच',
    'health_locker': 'स्वास्थ्य लॉकर',
    'appointments': 'अपॉइंटमेंट',
    'live_queue': 'लाइव कतार',
    'teleconsult': 'टेली-परामर्श',
    'menstrual': 'मासिक धर्म ट्रैकर',
    'pregnancy': 'गर्भावस्था ट्रैकर',
    'child_vaccination': 'बाल टीकाकरण',
    'vaccination': 'टीकाकरण रिकॉर्ड',
    'consent': 'डेटा सहमति',
    'medicine': 'मेरी दवाइयां',
    'health_info': 'स्वास्थ्य जानकारी',
    'scheme': 'योजना पात्रता',
    'feedback': 'प्रतिक्रिया',
    'sos': 'आपातकाल SOS',
    'find_patient': 'मरीज़ खोजें',
    'register_patient': 'मरीज़ पंजीकरण',
    'vitals': 'जीवन संकेत दर्ज करें',
    'symptoms': 'लक्षण दर्ज करें',
    'triage': 'ट्रायज परिणाम',
    'upload_records': 'रिकॉर्ड अपलोड करें',
    'emergency': 'आपातकाल',
    'sync_status': 'सिंक स्थिति',
    'pending': 'लंबित',
    'synced': 'सिंक हो गया',
    'sync_now': 'अभी सिंक करें',
    'offline_saved': 'ऑफलाइन सहेजा गया। कनेक्ट होने पर सिंक होगा।',
    'save': 'सहेजें',
    'cancel': 'रद्द करें',
    'submit': 'जमा करें',
    'next': 'अगला',
    'back': 'वापस',
    'loading': 'लोड हो रहा है…',
    'error': 'कुछ गलत हो गया',
    'no_data': 'कोई रिकॉर्ड नहीं मिला',
    'search': 'खोजें',
    'call_ambulance': 'एंबुलेंस बुलाएं',
    'generate_referral': 'रेफरल बनाएं',
    'notify_hospital': 'नजदीकी अस्पताल को सूचित करें',
    'sos_hold': 'आपातकालीन SOS के लिए दबाए रखें',
    'green': 'स्थिर',
    'yellow': 'सतर्कता',
    'red': 'तत्काल',
    'critical': 'गंभीर',
    'bp': 'रक्तचाप',
    'spo2': 'SpO₂',
    'temperature': 'तापमान',
    'weight': 'वजन',
    'voice_input': 'आवाज़ इनपुट',
    'text_input': 'लक्षण टाइप करें',
    'photo_input': 'फोटो लें',
    'abha_id': 'ABHA आईडी',
    'temp_id': 'अस्थायी आईडी',
    'register_abha': 'ABHA आईडी से पंजीकरण',
    'register_temp': 'ऑफलाइन पंजीकरण (अस्थायी आईडी)',
    'name': 'पूरा नाम',
    'dob': 'जन्म तिथि',
    'gender': 'लिंग',
    'phone': 'फोन नंबर',
    'address': 'पता',
    'male': 'पुरुष',
    'female': 'महिला',
    'other': 'अन्य',
    'profile': 'प्रोफ़ाइल',
    'settings': 'सेटिंग्स',
    'logout': 'लॉगआउट',
    'language': 'भाषा',
  };
}
