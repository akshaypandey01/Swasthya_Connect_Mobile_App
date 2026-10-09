import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/user_role.dart';
import '../../shared/widgets/sc_button.dart';
import '../../shared/widgets/sc_text_field.dart';

class WorkerLoginScreen extends ConsumerStatefulWidget {
  const WorkerLoginScreen({super.key});
  @override
  ConsumerState<WorkerLoginScreen> createState() => _WorkerLoginScreenState();
}

class _WorkerLoginScreenState extends ConsumerState<WorkerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rchCtrl = TextEditingController();
  bool _isLoading = false;
  WorkerVisitType _visitType = WorkerVisitType.fieldVisit;

  @override
  void dispose() {
    _rchCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);
    final phone = await authService.validateRchId(_rchCtrl.text.trim());
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (phone == null || phone.startsWith('RCH')) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RCH ID not found. Please check and retry.')));
      return;
    }

    setState(() => _isLoading = true);
    await authService.sendWorkerOtp(
      phoneNumber: phone,
      onCodeSent: (_) {
        setState(() => _isLoading = false);
        context.push(AppRoutes.workerOtp, extra: {
          'rchId': _rchCtrl.text.trim(),
          'phone': phone,
          'visitType': _visitType.name,
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
        title: const Text('Worker Login'),
        backgroundColor: AppColors.secondary,
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/images/swasthya_connect_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('SwasthyaConnect',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondary)),
                            Text('By HealthSync1 | Team ID: 165109',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary)),
                            SizedBox(height: 4),
                            Text('Frontline Worker Login',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondary)),
                            Text('स्वास्थ्य कार्यकर्ता लॉगिन',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline, size: 18, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Sample Test Credentials',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'RCH ID: aakhabba\nOTP: 212121',
                        style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ScTextField(
                  label: 'RCH Portal ID',
                  hint: 'Enter your RCH Worker ID',
                  controller: _rchCtrl,
                  keyboardType: TextInputType.text,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your RCH ID';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                const Text('Visit Type / विज़िट प्रकार',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: WorkerVisitType.values.map((type) {
                    final selected = _visitType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _visitType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.secondary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.secondary
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                type == WorkerVisitType.fieldVisit
                                    ? Icons.directions_walk_rounded
                                    : Icons.local_hospital_rounded,
                                color: selected
                                    ? Colors.white
                                    : AppColors.secondary,
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                type == WorkerVisitType.fieldVisit
                                    ? 'Field Visit'
                                    : 'Center Visit',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                ScButton(
                  label: 'Send OTP / OTP भेजें',
                  icon: Icons.sms_rounded,
                  color: AppColors.secondary,
                  isLoading: _isLoading,
                  onPressed: _sendOtp,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/role-select'),
                    child: const Text('← Back'),
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
