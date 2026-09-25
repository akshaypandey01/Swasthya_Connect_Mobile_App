/// API Configuration
/// 
/// IMPORTANT: This file contains configurable API settings.
/// The baseUrl MUST be set to the actual backend deployment URL.
/// 
/// DO NOT commit production URLs or secrets to version control.
/// Use environment variables or build configurations for different environments.

class ApiConfig {
  ApiConfig._();

  // ════════════════════════════════════════════════════════════════════════
  // BACKEND BASE URL - CONFIGURATION REQUIRED
  // ════════════════════════════════════════════════════════════════════════
  
  /// Base URL for REST API
  /// 
  /// **CONFIGURATION REQUIRED:**
  /// Replace this placeholder with the actual backend deployment URL.
  /// 
  /// Examples:
  /// - Development: 'http://localhost:3000'
  /// - Staging: 'https://staging-api.swasthyaconnect.in'
  /// - Production: 'https://api.swasthyaconnect.in'
  /// 
  /// Current: Placeholder (NOT CONFIGURED)
  static const String baseUrl = 'https://api.swasthyaconnect.in'; // ⚠️ CONFIGURE THIS
  
  // ════════════════════════════════════════════════════════════════════════
  // API ENDPOINTS
  // ════════════════════════════════════════════════════════════════════════
  
  // ── Authentication ───────────────────────────────────────────────────────
  static const String authLogin = '/api/auth/login';
  static const String authVerifyOtp = '/api/auth/verify-otp';
  static const String authRefreshToken = '/api/auth/refresh';
  
  // ── Triage ───────────────────────────────────────────────────────────────
  static const String triageStart = '/api/triage/start';
  static const String triageNextQuestion = '/api/triage/next-question';
  static const String triageSubmit = '/api/triage/submit';
  
  // ── Facilities & Doctors ─────────────────────────────────────────────────
  static const String facilities = '/api/facilities';
  static String facilityById(String id) => '/api/facilities/$id';
  static String facilityDoctors(String id) => '/api/facilities/$id/doctors';
  
  // ── Appointments ─────────────────────────────────────────────────────────
  static const String appointments = '/api/appointments';
  static const String appointmentSlots = '/api/appointments/slots';
  static String appointmentById(String id) => '/api/appointments/$id';
  
  // ── Doctors ──────────────────────────────────────────────────────────────
  static const String doctorsAvailable = '/api/doctors/available';
  
  // ── Consultations ────────────────────────────────────────────────────────
  static const String consultations = '/api/consultations';
  static String consultationById(String id) => '/api/consultations/$id';
  
  // ── Health Records ───────────────────────────────────────────────────────
  static String patientRecords(String patientId) => '/api/patients/$patientId/records';
  
  // ── Prescriptions ────────────────────────────────────────────────────────
  static const String prescriptions = '/api/prescriptions';
  static String prescriptionById(String id) => '/api/prescriptions/$id';
  
  // ── Medicine Logs ────────────────────────────────────────────────────────
  static const String medicineLogs = '/api/medicine-logs';
  
  // ── Referrals ────────────────────────────────────────────────────────────
  static const String referrals = '/api/referrals';
  static String referralById(String id) => '/api/referrals/$id';
  
  // ── Follow-ups ───────────────────────────────────────────────────────────
  static const String followUps = '/api/follow-ups';
  static String followUpById(String id) => '/api/follow-ups/$id';
  
  // ── Family Members ───────────────────────────────────────────────────────
  static const String familyMembers = '/api/family-members';
  static String familyMemberById(String id) => '/api/family-members/$id';
  
  // ── Schemes ──────────────────────────────────────────────────────────────
  static const String schemesCheck = '/api/schemes/check';
  
  // ── Consents ─────────────────────────────────────────────────────────────
  static const String consents = '/api/consents';
  static String consentById(String id) => '/api/consents/$id';
  
  // ════════════════════════════════════════════════════════════════════════
  // SOCKET.IO CONFIGURATION
  // ════════════════════════════════════════════════════════════════════════
  
  /// Socket.IO server URL
  /// 
  /// **CONFIGURATION REQUIRED:**
  /// This should point to the Socket.IO server for real-time features.
  /// May be the same as baseUrl or a separate server.
  static const String socketUrl = 'https://api.swasthyaconnect.in'; // ⚠️ CONFIGURE THIS
  
  // ── Socket.IO Events ─────────────────────────────────────────────────────
  static const String socketConnect = 'connect';
  static const String socketDisconnect = 'disconnect';
  static const String socketError = 'error';
  
  // Teleconsultation events
  static const String socketRequestTeleconsult = 'request-teleconsult';
  static const String socketNewConsultationRequest = 'new-consultation-request';
  static const String socketAcceptTeleconsult = 'accept-teleconsult';
  static const String socketJoinRoom = 'join-room';
  static const String socketLeaveRoom = 'leave-room';
  static const String socketOffer = 'offer';
  static const String socketAnswer = 'answer';
  static const String socketIceCandidate = 'ice-candidate';
  
  // Queue events
  static const String socketQueueUpdate = 'queue-update';
  static const String socketYourTurn = 'your-turn';
  
  // Referral events
  static const String socketReferralStatusUpdate = 'referral-status-update';
  
  // Emergency events
  static const String socketEmergencyAlert = 'emergency-alert';
  
  // ════════════════════════════════════════════════════════════════════════
  // WEBRTC CONFIGURATION
  // ════════════════════════════════════════════════════════════════════════
  
  /// STUN/TURN servers for WebRTC
  /// 
  /// **CONFIGURATION REQUIRED:**
  /// Add your STUN/TURN server configuration here.
  /// 
  /// Free STUN servers (public, may have limitations):
  /// - Google: stun:stun.l.google.com:19302
  /// - Twilio: stun:global.stun.twilio.com:3478
  /// 
  /// TURN servers (required for NAT traversal, usually paid):
  /// Contact your backend team for credentials.
  static const Map<String, dynamic> iceServers = {
    'iceServers': [
      {
        'urls': 'stun:stun.l.google.com:19302',
      },
      // Add TURN servers here if available:
      // {
      //   'urls': 'turn:turn.example.com:3478',
      //   'username': 'username',
      //   'credential': 'password',
      // },
    ],
  };
  
  // ════════════════════════════════════════════════════════════════════════
  // REQUEST CONFIGURATION
  // ════════════════════════════════════════════════════════════════════════
  
  /// Request timeout duration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  /// Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // ════════════════════════════════════════════════════════════════════════
  // ENVIRONMENT DETECTION
  // ════════════════════════════════════════════════════════════════════════
  
  /// Check if running against a configured backend
  static bool get isConfigured {
    return !baseUrl.contains('CONFIGURE') && 
           !baseUrl.contains('placeholder') &&
           baseUrl.isNotEmpty;
  }
  
  /// Check if running in development mode
  static bool get isDevelopment {
    return baseUrl.contains('localhost') || 
           baseUrl.contains('127.0.0.1') ||
           baseUrl.contains('staging');
  }
  
  /// Check if running in production mode
  static bool get isProduction {
    return !isDevelopment && 
           !baseUrl.contains('staging') &&
           !baseUrl.contains('dev');
  }
}
