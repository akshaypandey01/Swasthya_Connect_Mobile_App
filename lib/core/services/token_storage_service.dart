import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TOKEN STORAGE SERVICE PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

// ═══════════════════════════════════════════════════════════════════════════
// TOKEN STORAGE SERVICE
// ═══════════════════════════════════════════════════════════════════════════

/// Secure storage for authentication tokens and sensitive data
/// 
/// Uses flutter_secure_storage for encrypted storage on device.
/// - Android: EncryptedSharedPreferences
/// - iOS: Keychain
class TokenStorageService {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenExpiry = 'token_expiry';
  static const String _keyFirebaseIdToken = 'firebase_id_token';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  final Logger _logger = Logger();

  // ═════════════════════════════════════════════════════════════════════════
  // ACCESS TOKEN
  // ═════════════════════════════════════════════════════════════════════════

  /// Save access token (JWT or Firebase ID token)
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _keyAccessToken, value: token);
      _logger.d('Access token saved');
    } catch (e) {
      _logger.e('Failed to save access token: $e');
      rethrow;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (e) {
      _logger.e('Failed to read access token: $e');
      return null;
    }
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      _logger.d('Access token deleted');
    } catch (e) {
      _logger.e('Failed to delete access token: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // REFRESH TOKEN
  // ═════════════════════════════════════════════════════════════════════════

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
      _logger.d('Refresh token saved');
    } catch (e) {
      _logger.e('Failed to save refresh token: $e');
      rethrow;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      _logger.e('Failed to read refresh token: $e');
      return null;
    }
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _keyRefreshToken);
      _logger.d('Refresh token deleted');
    } catch (e) {
      _logger.e('Failed to delete refresh token: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // TOKEN EXPIRY
  // ═════════════════════════════════════════════════════════════════════════

  /// Save token expiry timestamp
  Future<void> saveTokenExpiry(DateTime expiry) async {
    try {
      await _storage.write(
        key: _keyTokenExpiry,
        value: expiry.toIso8601String(),
      );
      _logger.d('Token expiry saved: $expiry');
    } catch (e) {
      _logger.e('Failed to save token expiry: $e');
      rethrow;
    }
  }

  /// Get token expiry timestamp
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryStr = await _storage.read(key: _keyTokenExpiry);
      if (expiryStr != null) {
        return DateTime.parse(expiryStr);
      }
      return null;
    } catch (e) {
      _logger.e('Failed to read token expiry: $e');
      return null;
    }
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Delete token expiry
  Future<void> deleteTokenExpiry() async {
    try {
      await _storage.delete(key: _keyTokenExpiry);
      _logger.d('Token expiry deleted');
    } catch (e) {
      _logger.e('Failed to delete token expiry: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // FIREBASE ID TOKEN (for backend JWT exchange if needed)
  // ═════════════════════════════════════════════════════════════════════════

  /// Save Firebase ID token
  Future<void> saveFirebaseIdToken(String token) async {
    try {
      await _storage.write(key: _keyFirebaseIdToken, value: token);
      _logger.d('Firebase ID token saved');
    } catch (e) {
      _logger.e('Failed to save Firebase ID token: $e');
      rethrow;
    }
  }

  /// Get Firebase ID token
  Future<String?> getFirebaseIdToken() async {
    try {
      return await _storage.read(key: _keyFirebaseIdToken);
    } catch (e) {
      _logger.e('Failed to read Firebase ID token: $e');
      return null;
    }
  }

  /// Delete Firebase ID token
  Future<void> deleteFirebaseIdToken() async {
    try {
      await _storage.delete(key: _keyFirebaseIdToken);
      _logger.d('Firebase ID token deleted');
    } catch (e) {
      _logger.e('Failed to delete Firebase ID token: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // CLEAR ALL
  // ═════════════════════════════════════════════════════════════════════════

  /// Clear all stored tokens (on logout)
  Future<void> clearAll() async {
    try {
      await deleteAccessToken();
      await deleteRefreshToken();
      await deleteTokenExpiry();
      await deleteFirebaseIdToken();
      _logger.i('All tokens cleared');
    } catch (e) {
      _logger.e('Failed to clear tokens: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═════════════════════════════════════════════════════════════════════════

  /// Check if user has valid tokens
  Future<bool> hasValidTokens() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    final isExpired = await isTokenExpired();
    return !isExpired;
  }
}
