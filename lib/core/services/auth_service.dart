import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_role.dart';
import '../constants/hive_constants.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserRoleProvider = StateProvider<UserRole?>((ref) {
  final box = Hive.box(HiveConstants.settingsBox);
  final roleStr = box.get(HiveConstants.userRoleKey) as String?;
  if (roleStr == null) return null;
  return UserRole.fromString(roleStr);
});

// ─── Service ─────────────────────────────────────────────────────────────────

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _verificationId;

  User? get currentUser => _auth.currentUser;

  // ── Patient: ABHA ID + OTP ────────────────────────────────────────────────

  /// Sends OTP to the phone number linked with [abhaId].
  /// In production this would call NHA's ABHA verification API first.
  Future<void> sendPatientOtp({
    required String abhaId,
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential?> verifyPatientOtp(String otp) async {
    if (_verificationId == null) return null;
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ── Worker: RCH ID + OTP ──────────────────────────────────────────────────

  /// Validates RCH ID against Firestore, then triggers phone OTP.
  Future<String?> validateRchId(String rchId) async {
    // TODO: Remove hardcoded demo data in production
    // Demo RCH IDs for testing (bypass Firestore check)
    final demoWorkers = {
      'aakhabba': '+916307334374',
      'demo123': '+919999999999',
      'rch001': '+918888888888',
    };
    
    if (demoWorkers.containsKey(rchId.toLowerCase())) {
      return demoWorkers[rchId.toLowerCase()];
    }

    // Production: Check Firestore
    try {
      final snapshot = await _db
          .collection('frontline_workers')
          .where('worker_id', isEqualTo: rchId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return 'RCH ID not found';
      final phone = snapshot.docs.first.data()['phone'] as String?;
      return phone; // return registered phone for OTP
    } catch (_) {
      return null;
    }
  }

  Future<void> sendWorkerOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) => onError(e.message ?? 'Failed'),
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential?> verifyWorkerOtp(String otp) async {
    if (_verificationId == null) return null;
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ── Persist role after login ──────────────────────────────────────────────

  Future<void> persistRole(UserRole role, String userId) async {
    final box = Hive.box(HiveConstants.settingsBox);
    await box.put(HiveConstants.userRoleKey, role.name);
    await box.put(HiveConstants.userIdKey, userId);
  }

  Future<void> signOut() async {
    final box = Hive.box(HiveConstants.settingsBox);
    await box.delete(HiveConstants.userRoleKey);
    await box.delete(HiveConstants.userIdKey);
    await _auth.signOut();
  }
}
