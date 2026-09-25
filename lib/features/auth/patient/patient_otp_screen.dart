import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/user_role.dart';
import '../../shared/widgets/sc_button.dart';

class PatientOtpScreen extends ConsumerStatefulWidget {
  final String abhaId;
  final String phone;
  const PatientOtpScreen({super.key, required this.abhaId, required this.phone});

  @override
  ConsumerState<PatientOtpScreen> createState() => _PatientOtpScreenState();
}

class _PatientOtpScreenState extends ConsumerState<PatientOtpScreen> {
  String _otp = '';
  bool _isLoading = false;
  bool _canResend = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
        }
      });
      return _countdown > 0;
    });
  }

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter 6-digit OTP')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final cred = await authService.verifyPatientOtp(_otp);
      if (cred != null && cred.user != null) {
        await authService.persistRole(UserRole.patient, cred.user!.uid);
        if (mounted) context.go(AppRoutes.patientHome);
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid OTP. Try again.')));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Verification failed';
        if (e.code == 'invalid-verification-code') {
          message = 'Invalid OTP. Please check and try again.';
        } else if (e.code == 'session-expired') {
          message = 'OTP expired. Please request a new one.';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sms_rounded, size: 60, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text('Enter OTP',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'OTP sent to ${widget.phone}',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 6,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 46,
                  activeFillColor: AppColors.surface,
                  inactiveFillColor: AppColors.surface,
                  selectedFillColor: AppColors.primaryContainer,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  selectedColor: AppColors.primary,
                ),
                enableActiveFill: true,
                onChanged: (val) => setState(() => _otp = val),
                onCompleted: (val) {
                  setState(() => _otp = val);
                  _verify();
                },
              ),
              const SizedBox(height: 32),
              ScButton(
                label: 'Verify OTP / OTP सत्यापित करें',
                isLoading: _isLoading,
                onPressed: _verify,
              ),
              const SizedBox(height: 24),
              if (_canResend)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _canResend = false;
                      _countdown = 60;
                    });
                    _startCountdown();
                    // Re-trigger OTP send
                    ref.read(authServiceProvider).sendPatientOtp(
                          abhaId: widget.abhaId,
                          phoneNumber: widget.phone,
                          onCodeSent: (_) {},
                          onError: (e) => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(e))),
                        );
                  },
                  child: const Text('Resend OTP / OTP पुनः भेजें'),
                )
              else
                Text(
                  'Resend OTP in ${_countdown}s',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 0),
            ],
          ),
        ),
      ),
    );
  }
}
