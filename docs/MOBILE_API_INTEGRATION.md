# Mobile API Integration Guide

**Generated:** September 20, 2026  
**Status:** Backend Foundation Complete (STAGE 2)  
**Purpose:** Document REST API integration architecture for Patient features

---

## Overview

The SwasthyaConnect mobile app now has a **dual-backend architecture**:
1. **Firebase** (existing) - Authentication, Firestore, Storage
2. **REST API** (new) - Advanced features (AI Triage, Teleconsult, Referrals, etc.)

This integration preserves the existing offline-first Firebase architecture while adding REST API capability for web parity features.

---

## Architecture

### Request Flow

```
UI Widget
    ↓
Riverpod Provider
    ↓
Repository
    ↓ (online)
API Client (Dio)
    ↓
REST Backend
```

### Offline Flow

```
UI Widget
    ↓
Riverpod Provider
    ↓
Repository
    ↓ (offline)
Hive Local Storage
    ↓ (when online)
Sync Service → API Client → REST Backend
```

---

## Configuration

### API Base URL

**File:** `lib/core/config/api_config.dart`

```dart
class ApiConfig {
  // ⚠️ CONFIGURE THIS - Replace with actual backend URL
  static const String baseUrl = 'https://api.swasthyaconnect.in';
  
  // ⚠️ CONFIGURE THIS - Socket.IO server URL
  static const String socketUrl = 'https://api.swasthyaconnect.in';
}
```

**Environment-specific configuration:**
- **Development:** `http://localhost:3000` or staging URL
- **Production:** Actual production API URL

**How to configure:**
1. Edit `lib/core/config/api_config.dart`
2. Replace `baseUrl` constant
3. Replace `socketUrl` constant (if different)
4. Rebuild app

### Environment Detection

```dart
ApiConfig.isConfigured   // true if baseUrl is set
ApiConfig.isDevelopment  // true if localhost/staging
ApiConfig.isProduction   // true if production URL
```

---

## API Client

### Usage

**Provider:**
```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  final authService = ref.watch(authServiceProvider);
  final isOnline = ref.watch(isOnlineProvider);
  return ApiClient(authService: authService, isOnline: isOnline);
});
```

**Example GET request:**
```dart
class MyRepository {
  final ApiClient _apiClient;
  
  Future<List<Facility>> getFacilities() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.facilities,
        queryParameters: {'nearby': true},
      );
      
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data!,
        (data) => data as List,
      );
      
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((item) => Facility.fromJson(item))
            .toList();
      }
      
      throw Exception(apiResponse.error ?? 'Failed to fetch facilities');
    } on ApiException catch (e) {
      // Handle API-specific errors
      throw e;
    }
  }
}
```

**Example POST request:**
```dart
Future<TriageSession> startTriage({
  required String patientId,
  required String chiefComplaint,
  required String language,
}) async {
  try {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.triageStart,
      data: {
        'patientId': patientId,
        'chiefComplaint': chiefComplaint,
        'language': language,
      },
    );
    
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data!,
      (data) => data as Map<String, dynamic>,
    );
    
    if (apiResponse.success && apiResponse.data != null) {
      return TriageSession.fromJson(apiResponse.data!);
    }
    
    throw Exception(apiResponse.error ?? 'Failed to start triage');
  } on ApiException catch (e) {
    if (e.type == ApiErrorType.network) {
      // Offline - use fallback triage
      return _startOfflineTriage(patientId, chiefComplaint);
    }
    rethrow;
  }
}
```

---

## Authentication

### Token Strategy

The mobile app uses **Firebase ID tokens** as bearer tokens for REST API authentication.

**Flow:**
1. User logs in with Firebase Phone Auth (existing)
2. Firebase generates ID token
3. API Client automatically adds token to requests:
   ```
   Authorization: Bearer <firebase-id-token>
   ```
4. Backend verifies Firebase ID token using Firebase Admin SDK

### Token Management

**Automatic token refresh:**
```dart
// API Client automatically handles 401 Unauthorized
onError: (error, handler) async {
  if (error.response?.statusCode == 401) {
    // Refresh Firebase ID token
    final user = authService.currentUser;
    await user.getIdToken(true); // Force refresh
    
    // Retry original request with new token
    final retryResponse = await _dio.fetch(options);
    return handler.resolve(retryResponse);
  }
}
```

**Manual token access:**
```dart
final user = authService.currentUser;
if (user != null) {
  final idToken = await user.getIdToken(); // Cached token
  final freshToken = await user.getIdToken(true); // Force refresh
}
```

### Secure Token Storage

**Service:** `TokenStorageService` (flutter_secure_storage)

**Usage:**
```dart
final tokenStorage = ref.read(tokenStorageServiceProvider);

// Save token
await tokenStorage.saveAccessToken(token);

// Read token
final token = await tokenStorage.getAccessToken();

// Check expiry
final isExpired = await tokenStorage.isTokenExpired();

// Clear on logout
await tokenStorage.clearAll();
```

**Storage locations:**
- **Android:** EncryptedSharedPreferences
- **iOS:** Keychain

---

## Error Handling

### API Exception Types

```dart
enum ApiErrorType {
  network,       // No internet / connection failed
  timeout,       // Request timeout
  unauthorized,  // 401 - Token expired, need re-login
  forbidden,     // 403 - No permission
  notFound,      // 404 - Resource not found
  server,        // 500+ - Server error
  cancel,        // Request cancelled
  unknown,       // Other errors
}
```

### Error Handling Pattern

```dart
try {
  final result = await repository.someApiCall();
  // Handle success
} on ApiException catch (e) {
  // API-specific error handling
  if (e.type == ApiErrorType.unauthorized) {
    // Force logout
    await authService.signOut();
    context.go(AppRoutes.patientLogin);
  } else if (e.type == ApiErrorType.network) {
    // Show offline message
    showSnackbar(context, 'No internet connection');
  } else if (e.isRecoverable) {
    // Allow retry
    showSnackbar(context, e.message, actionLabel: 'Retry');
  } else {
    // Show generic error
    showSnackbar(context, e.message);
  }
} catch (e) {
  // Unexpected error
  showSnackbar(context, 'An unexpected error occurred');
}
```

### User-Friendly Messages

API Client automatically converts technical errors to user-friendly messages:

| Status Code | User Message |
|-------------|--------------|
| 0 (network) | "No internet connection" |
| 0 (timeout) | "Request timeout. Please check your connection and try again." |
| 401 | "Session expired. Please login again." |
| 403 | "You do not have permission to perform this action." |
| 404 | "Resource not found." |
| 500+ | "Server error. Please try again later." |

---

## API Endpoints Reference

### Authentication
```dart
POST /api/auth/login              // Login (if backend JWT required)
POST /api/auth/verify-otp         // Verify OTP (if custom backend auth)
POST /api/auth/refresh            // Refresh token
```

### Triage (AI-powered)
```dart
POST /api/triage/start            // Start triage session
POST /api/triage/next-question    // Get adaptive next question
POST /api/triage/submit           // Submit triage, get risk score
```

### Facilities & Doctors
```dart
GET  /api/facilities              // List facilities (?nearby=true)
GET  /api/facilities/:id          // Get facility details
GET  /api/facilities/:id/doctors  // Get doctors for facility
```

### Appointments
```dart
GET  /api/appointments/slots      // Get available slots
POST /api/appointments            // Book appointment
GET  /api/appointments/:id        // Get appointment details
PATCH /api/appointments/:id       // Cancel/reschedule
```

### Doctors
```dart
GET  /api/doctors/available       // Get available doctors for teleconsult
```

### Consultations
```dart
POST /api/consultations           // Create consultation session
GET  /api/consultations/:id       // Get consultation details
```

### Health Records
```dart
GET  /api/patients/:id/records    // Get patient health records (timeline)
```

### Prescriptions
```dart
GET  /api/prescriptions           // Get prescriptions (?patientId=X&status=active)
GET  /api/prescriptions/:id       // Get prescription details
```

### Medicine Logs
```dart
POST /api/medicine-logs           // Log medicine taken
GET  /api/medicine-logs           // Get adherence logs
```

### Referrals
```dart
POST  /api/referrals              // Create referral
PATCH /api/referrals/:id          // Update referral status
GET   /api/referrals/:id          // Get referral details
GET   /api/referrals              // List referrals (?patientId=X)
```

### Follow-ups
```dart
GET   /api/follow-ups             // Get follow-ups (?patientId=X)
PATCH /api/follow-ups/:id         // Update follow-up (mark completed, reschedule)
```

### Family Members
```dart
GET   /api/family-members         // Get family members (?userId=X)
POST  /api/family-members         // Add family member
PATCH /api/family-members/:id     // Update family member
DELETE /api/family-members/:id    // Remove family member
```

### Schemes
```dart
POST /api/schemes/check           // Check eligibility (AI-powered)
```

### Consents
```dart
GET   /api/consents               // Get consent history (?patientId=X)
POST  /api/consents               // Grant consent
PATCH /api/consents/:id           // Revoke consent
```

---

## Socket.IO Events

### Connection
```dart
socket_io_client: ^2.0.3+1

import 'package:socket_io_client/socket_io_client.dart' as IO;

final socket = IO.io(ApiConfig.socketUrl, <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
  'auth': {
    'token': await user.getIdToken(),
  },
});

socket.connect();
```

### Teleconsultation Events

**Client → Server:**
```dart
socket.emit('request-teleconsult', {
  'patientId': patientId,
  'priority': 'routine', // routine | urgent | emergency
});

socket.emit('join-room', {
  'consultationId': consultationId,
});

socket.emit('offer', {
  'consultationId': consultationId,
  'offer': sdpOffer,
});

socket.emit('ice-candidate', {
  'consultationId': consultationId,
  'candidate': iceCandidate,
});
```

**Server → Client:**
```dart
socket.on('new-consultation-request', (data) {
  // Doctor available
});

socket.on('accept-teleconsult', (data) {
  // Doctor accepted consultation
});

socket.on('answer', (data) {
  // SDP answer from doctor
});

socket.on('ice-candidate', (data) {
  // ICE candidate from doctor
});
```

### Queue Events

```dart
socket.on('queue-update', (data) {
  final position = data['position'];
  final estimatedWait = data['estimatedWait'];
  // Update UI
});

socket.on('your-turn', (data) {
  // Show notification: "It's your turn!"
});
```

### Referral Events

```dart
socket.on('referral-status-update', (data) {
  final referralId = data['referralId'];
  final status = data['status'];
  // Update UI
});
```

### Emergency Events

```dart
socket.emit('emergency-alert', {
  'patientId': patientId,
  'location': {'lat': lat, 'lng': lng},
});
```

---

## Response Format

### Standard Response

```json
{
  "success": true,
  "data": { /* actual data */ },
  "message": "Operation successful"
}
```

### Error Response

```json
{
  "success": false,
  "error": "Error message",
  "statusCode": 400
}
```

### Paginated Response

```json
{
  "success": true,
  "data": [ /* items */ ],
  "meta": {
    "currentPage": 1,
    "totalPages": 5,
    "totalCount": 48,
    "pageSize": 10,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

---

## Offline Behavior

### Strategy

```dart
Future<T> fetchData() async {
  final isOnline = ref.read(isOnlineProvider);
  
  if (isOnline) {
    try {
      // Fetch from API
      final data = await _apiClient.get(...);
      // Cache to Hive
      await _saveToHive(data);
      return data;
    } on ApiException catch (e) {
      if (e.type == ApiErrorType.network) {
        // Fallback to cache
        return _loadFromHive();
      }
      rethrow;
    }
  } else {
    // Load from cache
    return _loadFromHive();
  }
}
```

### Pending Operations Queue

```dart
// Save operation for later sync
await _savePendingOperation({
  'type': 'create_referral',
  'payload': referralData,
  'timestamp': DateTime.now().toIso8601String(),
});

// Sync when online
ref.listen(isOnlineProvider, (prev, isOnline) {
  if (isOnline && prev == false) {
    syncPendingOperations();
  }
});
```

---

## Testing

### Mock API Client

For unit testing, create a mock API client:

```dart
class MockApiClient extends Mock implements ApiClient {}

test('should fetch facilities', () async {
  final mockClient = MockApiClient();
  when(mockClient.get(ApiConfig.facilities))
      .thenAnswer((_) async => Response(
        data: {
          'success': true,
          'data': [{'id': '1', 'name': 'PHC Rampur'}],
        },
        requestOptions: RequestOptions(path: ''),
      ));
  
  final repository = FacilityRepository(mockClient);
  final facilities = await repository.getFacilities();
  
  expect(facilities.length, 1);
  expect(facilities[0].name, 'PHC Rampur');
});
```

### Integration Testing

```dart
// Use actual API client with test base URL
ApiConfig.baseUrl = 'http://localhost:3000'; // Test server

testWidgets('should book appointment', (tester) async {
  // Test with real API calls to test server
});
```

---

## Security

### Best Practices

✅ **DO:**
- Use Firebase ID tokens for authentication
- Store tokens in secure storage (flutter_secure_storage)
- Use HTTPS for all API calls
- Validate SSL certificates
- Log errors without exposing sensitive data
- Implement rate limiting on client side
- Clear tokens on logout

❌ **DON'T:**
- Store API keys in client code
- Store passwords or sensitive data unencrypted
- Expose Groq API keys (server-side only)
- Log full request/response bodies in production
- Trust client-side data without server validation

### SSL Pinning (Future Enhancement)

```dart
// Add certificate pinning for production
_dio.httpClientAdapter = IOHttpClientAdapter(
  createHttpClient: () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // Verify certificate
      return cert.pem == expectedCertificate;
    };
    return client;
  },
);
```

---

## Monitoring & Logging

### Production Logging

```dart
// Use logger package for structured logging
final logger = Logger(
  printer: PrettyPrinter(),
  level: ApiConfig.isProduction ? Level.warning : Level.debug,
);

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### Analytics Integration (Future)

```dart
// Log API errors to Firebase Crashlytics
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'API Error: ${error.message}',
);
```

---

## Migration Checklist

### From Firebase-Only to Dual Backend

- [x] Add Dio, socket_io_client, flutter_secure_storage dependencies
- [x] Create ApiConfig with configurable base URL
- [x] Create ApiClient with auth interceptor
- [x] Create TokenStorageService
- [x] Create ApiResponse models
- [ ] Update repositories to use ApiClient where needed
- [ ] Implement offline fallback for each feature
- [ ] Add Socket.IO client for real-time features
- [ ] Test online/offline scenarios
- [ ] Document API contract for each feature

---

## Known Limitations

1. **Base URL not configured:** Replace placeholder in `ApiConfig.baseUrl`
2. **Socket.IO URL not configured:** Replace placeholder in `ApiConfig.socketUrl`
3. **TURN servers not configured:** Add TURN server credentials to `ApiConfig.iceServers`
4. **No retry logic:** Add exponential backoff for failed requests (future enhancement)
5. **No request caching:** Add HTTP caching layer (future enhancement)
6. **No request deduplication:** Multiple identical requests may be sent (future enhancement)

---

## Next Steps

1. **Configure API base URL** in `api_config.dart`
2. **Implement feature-specific API clients:**
   - TriageApiClient (STAGE 3)
   - AppointmentApiClient (STAGE 4)
   - TeleconsultApiClient (STAGE 4)
   - ReferralApiClient (STAGE 5)
   - etc.
3. **Integrate Socket.IO** for real-time features (STAGE 4)
4. **Add WebRTC** for teleconsultation (STAGE 4)
5. **Test end-to-end** with actual backend

---

**END OF API INTEGRATION GUIDE**

This foundation is complete and ready for feature-specific API integration in subsequent stages.
