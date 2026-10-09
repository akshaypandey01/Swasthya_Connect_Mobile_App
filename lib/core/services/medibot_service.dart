import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'api_client.dart';
import 'connectivity_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MEDIBOT SERVICE PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final medibotServiceProvider = Provider<MedibotService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final isOnline = ref.watch(isOnlineProvider);
  return MedibotService(apiClient: apiClient, isOnline: isOnline);
});

// ═══════════════════════════════════════════════════════════════════════════
// MEDIBOT MESSAGE MODEL
// ═══════════════════════════════════════════════════════════════════════════

enum MessageSender { user, medibot }

class MedibotMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isError;

  MedibotMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isError = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'sender': sender.name,
        'timestamp': timestamp.toIso8601String(),
        'isError': isError,
      };

  factory MedibotMessage.fromJson(Map<String, dynamic> json) {
    return MedibotMessage(
      id: json['id'],
      content: json['content'],
      sender: MessageSender.values.firstWhere((e) => e.name == json['sender']),
      timestamp: DateTime.parse(json['timestamp']),
      isError: json['isError'] ?? false,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MEDIBOT SERVICE
// ═══════════════════════════════════════════════════════════════════════════

class MedibotService {
  final ApiClient apiClient;
  final bool isOnline;
  final Logger _logger = Logger();

  MedibotService({
    required this.apiClient,
    required this.isOnline,
  });

  /// Send message to MediBot and get response
  /// 
  /// This method handles the AI interaction. In MVP, it can:
  /// - Call a real AI backend API endpoint
  /// - Use a placeholder response system for demo purposes
  /// - Handle offline gracefully
  Future<MedibotMessage> sendMessage({
    required String userMessage,
    Map<String, dynamic>? context,
  }) async {
    _logger.d('Sending message to MediBot: $userMessage');

    if (!isOnline) {
      throw MedibotException(
        message: 'MediBot requires internet connection',
        type: MedibotErrorType.offline,
      );
    }

    try {
      // TODO: Replace with actual AI backend endpoint when available
      // Example: POST /api/medibot/chat
      //
      // final response = await apiClient.post(
      //   '/medibot/chat',
      //   data: {
      //     'message': userMessage,
      //     'context': context,
      //   },
      // );
      //
      // return MedibotMessage(
      //   id: response.data['id'],
      //   content: response.data['response'],
      //   sender: MessageSender.medibot,
      //   timestamp: DateTime.now(),
      // );

      // TEMPORARY: Mock response for MVP demonstration
      // This should be replaced with real AI backend integration
      await Future.delayed(const Duration(milliseconds: 1500));

      final mockResponse = _generateMockResponse(userMessage, context);

      return MedibotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: mockResponse,
        sender: MessageSender.medibot,
        timestamp: DateTime.now(),
      );
    } on ApiException catch (e) {
      _logger.e('MediBot API error: ${e.message}');
      throw MedibotException(
        message: e.message,
        type: MedibotErrorType.apiError,
        originalError: e,
      );
    } catch (e) {
      _logger.e('MediBot error: $e');
      throw MedibotException(
        message: 'Failed to get response from MediBot',
        type: MedibotErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Process voice input and convert to text
  /// Returns transcribed text that can be sent as a message
  Future<String> transcribeVoice({required String audioFilePath}) async {
    _logger.d('Transcribing voice input');

    if (!isOnline) {
      throw MedibotException(
        message: 'Voice input requires internet connection',
        type: MedibotErrorType.offline,
      );
    }

    try {
      // TODO: Implement voice transcription API call
      // Example: POST /api/medibot/transcribe
      //
      // FormData formData = FormData.fromMap({
      //   'audio': await MultipartFile.fromFile(audioFilePath),
      // });
      //
      // final response = await apiClient.post(
      //   '/medibot/transcribe',
      //   data: formData,
      // );
      //
      // return response.data['text'];

      // TEMPORARY: Mock transcription
      await Future.delayed(const Duration(milliseconds: 800));
      return 'Tell me about my health records';
    } catch (e) {
      _logger.e('Voice transcription error: $e');
      throw MedibotException(
        message: 'Failed to transcribe voice input',
        type: MedibotErrorType.transcriptionError,
        originalError: e,
      );
    }
  }

  /// Get suggested quick actions based on context
  List<String> getSuggestedActions({Map<String, dynamic>? context}) {
    return [
      'Explain my health record',
      'Explain my report',
      'Check my appointments',
      'Check my follow-ups',
      'Find health schemes',
      'Ask a health question',
    ];
  }

  // ═════════════════════════════════════════════════════════════════════════
  // MOCK RESPONSE GENERATOR (TEMPORARY - FOR MVP DEMONSTRATION)
  // ═════════════════════════════════════════════════════════════════════════
  //
  // This generates contextual mock responses for demonstration purposes.
  // Replace this entire method with real AI backend integration.
  //
  // The mock system demonstrates:
  // - Healthcare-appropriate language
  // - Safety disclaimers
  // - Contextual responses
  // - Guiding users to existing app features
  //
  String _generateMockResponse(String userMessage, Map<String, dynamic>? context) {
    final msg = userMessage.toLowerCase();

    // Emergency detection
    if (_containsEmergencyKeywords(msg)) {
      return '''I understand this may be an urgent situation.

For immediate emergency assistance:
• Tap "Emergency SOS" on your home screen
• Call emergency services: 108 or 112
• Contact your nearest healthcare facility

I can provide general health information, but emergency situations require immediate professional medical attention.

Is there anything else I can help you with?''';
    }

    // Health record queries
    if (msg.contains('record') || msg.contains('health record')) {
      return '''Your health records contain important medical information including:
• Past consultations and diagnoses
• Test results and reports
• Vaccination history
• Current medications

To view your complete health records:
→ Tap "Health Locker" on your home screen

I can help explain specific items in your records if you'd like. What would you like to know more about?

*AI-generated information. For medical decisions, consult a healthcare professional.*''';
    }

    // Appointment queries
    if (msg.contains('appointment')) {
      return '''I can help you with appointments!

**To check your appointments:**
→ Tap "Book Appointment" on your home screen

**To check your queue status:**
→ Tap "Live Queue" for real-time updates

You can book appointments with healthcare facilities, check waiting times, and track your queue position.

Need help booking an appointment or want to know about upcoming visits?''';
    }

    // Follow-up queries
    if (msg.contains('follow') || msg.contains('followup')) {
      return '''To check your scheduled follow-ups:
→ Tap "Follow-ups" on your home screen

Your follow-ups track:
• Scheduled revisits
• Pending check-ups
• Treatment progress reviews
• Vaccination schedules

Would you like me to explain how to schedule or manage your follow-ups?''';
    }

    // Report/test result queries
    if (msg.contains('report') || msg.contains('result') || msg.contains('test')) {
      return '''Your medical reports are available in your Health Locker.

**To access reports:**
→ Go to "Health Locker" → "Reports & Documents"

I can help you understand:
• Common medical terms
• Test result ranges
• Report categories

*Important: Lab results and reports should be reviewed with your doctor. I provide general information only.*

Which report would you like help understanding?''';
    }

    // Scheme/eligibility queries
    if (msg.contains('scheme') || msg.contains('eligibility') || msg.contains('benefit')) {
      return '''Let me help you discover government health schemes!

**Check your eligibility:**
→ Tap "Scheme Eligibility" on your home screen

Available schemes may include:
• Ayushman Bharat
• State health insurance
• Maternal health programs
• Child vaccination programs
• Senior citizen benefits

The eligibility checker will show schemes based on your profile, income, age, and location.

Would you like help with a specific scheme?''';
    }

    // Medicine queries
    if (msg.contains('medicine') || msg.contains('medication') || msg.contains('drug')) {
      return '''Your medicine information is organized in the app.

**To view your medicines:**
→ Tap "My Medicines" on your home screen

You can:
• Track current medications
• Set medication reminders
• View dosage instructions
• Check medication history

*Always take medications as prescribed by your doctor. Never adjust doses without medical advice.*

Need help understanding a specific medication?''';
    }

    // Pregnancy/menstrual queries
    if (msg.contains('pregnan') || msg.contains('menstrual') || msg.contains('period')) {
      if (msg.contains('pregnan')) {
        return '''Pregnancy care is an important part of your health journey.

**Pregnancy Tracker:**
→ Tap "Pregnancy Tracker" on your home screen

Features include:
• Week-by-week pregnancy information
• Antenatal care reminders
• Nutrition guidance
• Warning signs to watch

*For medical advice during pregnancy, always consult your doctor or ANM (Auxiliary Nurse Midwife).*

How can I assist you with pregnancy information?''';
      } else {
        return '''**Menstrual Tracker** helps you track your cycle.

→ Tap "Menstrual Tracker" on your home screen

Track:
• Period dates
• Cycle patterns
• Symptoms
• Fertility window

This helps you better understand your reproductive health and share accurate information with healthcare providers.

Would you like tips on using the tracker?''';
      }
    }

    // Vaccination queries
    if (msg.contains('vaccin') || msg.contains('immuniz')) {
      return '''**Vaccination Records** keep track of immunizations.

→ Tap "Vaccination Record" on your home screen
→ For children: "Child Vaccination"

You can:
• View completed vaccinations
• See upcoming vaccination schedule
• Set reminders
• Download vaccination certificates

Vaccination protects against serious diseases. Keep your records up-to-date!

Need information about a specific vaccine?''';
    }

    // Teleconsultation queries
    if (msg.contains('teleconsult') || msg.contains('video') || msg.contains('online consult')) {
      return '''**Teleconsult** lets you consult doctors remotely.

→ Tap "Tele-consult" on your home screen

Benefits:
• Video/audio consultation
• Save travel time
• Get medical advice from home
• Suitable for follow-ups and non-emergency issues

*Teleconsultation is not suitable for emergencies. For urgent care, visit a healthcare facility or use Emergency SOS.*

Ready to book a teleconsultation?''';
    }

    // General health questions
    if (msg.contains('symptom') || msg.contains('fever') || msg.contains('pain') || 
        msg.contains('headache') || msg.contains('cough') || msg.contains('cold')) {
      return '''I understand you have health concerns.

**For symptom assessment:**
→ Use "Health Assessment" on your home screen

**For persistent or severe symptoms:**
• Consult a healthcare professional
• Visit your nearest health center
• Use "Tele-consult" for non-emergency advice

**When to seek immediate care:**
• Difficulty breathing
• Severe chest pain
• Uncontrolled bleeding
• Loss of consciousness
• High fever with confusion

*I provide general health information only. I cannot diagnose conditions or prescribe treatment.*

What specific health information can I help you with?''';
    }

    // Family member queries
    if (msg.contains('family') || msg.contains('relative') || msg.contains('child') || msg.contains('parent')) {
      return '''You can manage health information for your entire family!

**Family Members:**
→ Tap "Family Members" on your home screen

You can:
• Add family members
• Manage their health records
• Book appointments for them
• Track their vaccinations
• Access their reports

Each family member has their own secure health profile.

Would you like help adding or managing family members?''';
    }

    // Data privacy/consent queries
    if (msg.contains('data') || msg.contains('privacy') || msg.contains('consent') || msg.contains('share')) {
      return '''Your health data privacy is important.

**Data Consent Management:**
→ Tap "Data Consent" on your home screen

You control:
• Who can access your health data
• What information is shared
• How long consent remains valid
• Ability to revoke consent anytime

Your health information is protected and only shared with your explicit consent.

Need help managing your data sharing preferences?''';
    }

    // Default helpful response
    return '''Hello! I'm MediBot, your AI health assistant.

I can help you:
• Understand your health records
• Explain medical reports
• Find information about appointments and follow-ups
• Discover government health schemes
• Navigate Swasthya Connect features
• Answer general health questions

**Quick tip:** Use the suggestion buttons below for common tasks!

*AI-generated information. For diagnosis or treatment, consult a qualified healthcare professional.*

How can I assist you today?''';
  }

  bool _containsEmergencyKeywords(String msg) {
    final emergencyWords = [
      'emergency',
      'urgent',
      'critical',
      'serious',
      'dying',
      'can\'t breathe',
      'cannot breathe',
      'chest pain',
      'heart attack',
      'stroke',
      'bleeding',
      'accident',
      'unconscious',
      'suicide',
      'help me'
    ];

    return emergencyWords.any((word) => msg.contains(word));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MEDIBOT EXCEPTION
// ═══════════════════════════════════════════════════════════════════════════

enum MedibotErrorType {
  offline,
  apiError,
  transcriptionError,
  unknown,
}

class MedibotException implements Exception {
  final String message;
  final MedibotErrorType type;
  final dynamic originalError;

  MedibotException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => message;

  bool get isRecoverable {
    return type == MedibotErrorType.offline || type == MedibotErrorType.apiError;
  }
}
