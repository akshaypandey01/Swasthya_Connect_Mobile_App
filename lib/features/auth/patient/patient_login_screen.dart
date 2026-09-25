import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../shared/widgets/sc_button.dart';
import '../../shared/widgets/sc_text_field.dart';

class PatientLoginScreen extends ConsumerStatefulWidget {
  const PatientLoginScreen({super.key});
  @override
  ConsumerState<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends ConsumerState<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _abhaCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _abhaCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);
    await authService.sendPatientOtp(
      abhaId: _abhaCtrl.text.trim(),
      phoneNumber: '+91${_phoneCtrl.text.trim()}',
      onCodeSent: (_) {
        setState(() => _isLoading = false);
        context.push(AppRoutes.patientOtp, extra: {
          'abhaId': _abhaCtrl.text.trim(),
          'phone': '+91${_phoneCtrl.text.trim()}',
        });
      },
      onError: (err) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient Login'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/role-select'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded,
                          size: 40, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Patient Login',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                          Text('मरीज़ लॉगिन',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                ScTextField(
                  label: 'ABHA ID / ABHA नंबर',
                  hint: '14-digit ABHA Number',
                  controller: _abhaCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 14,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your ABHA ID';
                    if (v.length < 14) return 'ABHA ID must be 14 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ScTextField(
                  label: 'Registered Mobile Number / मोबाइल नंबर',
                  hint: '10-digit mobile number',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Text('+91',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter mobile number';
                    if (v.length < 10) return 'Enter valid 10-digit number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'OTP will be sent to your registered mobile number',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 40),
                ScButton(
                  label: 'Send OTP / OTP भेजें',
                  icon: Icons.sms_rounded,
                  isLoading: _isLoading,
                  onPressed: _sendOtp,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/role-select'),
                    child: const Text('← Back to role selection'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
