import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class EmergencyEscalationScreen extends StatefulWidget {
  final String patientId;
  const EmergencyEscalationScreen({super.key, required this.patientId});
  @override
  State<EmergencyEscalationScreen> createState() =>
      _EmergencyEscalationScreenState();
}

class _EmergencyEscalationScreenState
    extends State<EmergencyEscalationScreen> {
  bool _referralGenerated = false;
  bool _hospitalNotified = false;

  Future<void> _callAmbulance() async {
    final uri = Uri(scheme: 'tel', path: '108');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _generateReferral() {
    setState(() => _referralGenerated = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral generated and sent to CHC'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _notifyHospital() {
    setState(() => _hospitalNotified = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nearest hospital notified of incoming patient'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.emergencyLight,
      appBar: AppBar(
        title: const Text('Emergency Escalation'),
        backgroundColor: AppColors.emergency,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emergency.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.emergency.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emergency_rounded,
                        color: AppColors.emergency, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Emergency Protocol',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emergency)),
                          SizedBox(height: 4),
                          Text(
                            'Activate one or more emergency responses below.',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _EscalationButton(
                icon: Icons.local_taxi_rounded,
                title: 'Call Ambulance',
                titleHi: 'एंबुलेंस बुलाएं',
                subtitle: 'Dial 108 — National Emergency',
                color: AppColors.emergency,
                onTap: _callAmbulance,
              ),
              const SizedBox(height: 16),
              _EscalationButton(
                icon: Icons.assignment_rounded,
                title: 'Generate Referral',
                titleHi: 'रेफरल बनाएं',
                subtitle: 'Send referral slip to CHC/hospital',
                color: AppColors.triageRed,
                isDone: _referralGenerated,
                onTap: _generateReferral,
              ),
              const SizedBox(height: 16),
              _EscalationButton(
                icon: Icons.local_hospital_rounded,
                title: 'Notify Nearby Hospital',
                titleHi: 'अस्पताल को सूचित करें',
                subtitle: 'Alert facility of incoming patient',
                color: const Color(0xFFD84315),
                isDone: _hospitalNotified,
                onTap: _notifyHospital,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.textSecondary, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All escalation actions are logged automatically with timestamp and location.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EscalationButton extends StatelessWidget {
  final IconData icon;
  final String title, titleHi, subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDone;

  const _EscalationButton({
    required this.icon,
    required this.title,
    required this.titleHi,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDone ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDone ? AppColors.secondaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? AppColors.secondary : color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDone ? AppColors.secondary : color).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (isDone ? AppColors.secondary : color).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check_rounded : icon,
                color: isDone ? AppColors.secondary : color,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDone ? AppColors.secondary : color)),
                  Text(titleHi,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
              color: isDone ? AppColors.secondary : color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
