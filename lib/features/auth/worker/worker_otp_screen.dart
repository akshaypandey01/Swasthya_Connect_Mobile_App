import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/user_role.dart';
import '../../shared/widgets/sc_button.dart';

class WorkerOtpScreen extends ConsumerStatefulWidget {
  final String rchId;
  final String phone;
  const WorkerOtpScreen(
      {super.key, required this.rchId, required this.phone});

  @override
  ConsumerState<WorkerOtpScreen> createState() => _WorkerOtpScreenState();
}

class _WorkerOtpScreenState extends ConsumerState<WorkerOtpScreen> {
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
        if (_countdown > 0) _countdown--;
        else _canResend = true;
      });
      return _countdown > 0;
    });
  }

  Future<void> _verify() async {
    if (_otp.length < 6) return;
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final cred = await authService.verifyWorkerOtp(_otp);
      if (cred != null) {
        await authService.persistRole(
            UserRole.frontlineWorker, cred.user!.uid);
        if (mounted) context.go(AppRoutes.workerHome);
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid OTP. Try again.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: AppColors.secondary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sms_rounded, size: 60, color: AppColors.secondary),
              const SizedBox(height: 20),
              const Text('Enter OTP',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('OTP sent to ${widget.phone}',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.info_outline, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Sample OTP: 212121',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                  selectedFillColor: AppColors.secondaryContainer,
                  activeColor: AppColors.secondary,
                  inactiveColor: AppColors.border,
                  selectedColor: AppColors.secondary,
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
                label: 'Verify OTP',
                color: AppColors.secondary,
                isLoading: _isLoading,
                onPressed: _verify,
              ),
              const SizedBox(height: 24),
              if (_canResend)
                TextButton(
                  onPressed: () {
                    setState(() { _canResend = false; _countdown = 60; });
                    _startCountdown();
                    ref.read(authServiceProvider).sendWorkerOtp(
                          phoneNumber: widget.phone,
                          onCodeSent: (_) {},
                          onError: (e) => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(e))),
                        );
                  },
                  child: const Text('Resend OTP'),
                )
              else
                Text('Resend in ${_countdown}s',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 0),
            ],
          ),
        ),
      ),
    );
  }
}
