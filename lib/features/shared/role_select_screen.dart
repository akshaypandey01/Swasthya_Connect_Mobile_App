import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/swasthya_connect_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('SwasthyaConnect',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(height: 4),
                const Text('By HealthSync1 | Team ID: 165109',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 28),
                const Text('Who are you?',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('आप कौन हैं?',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                _RoleTile(
                  icon: Icons.person_rounded,
                  title: 'Patient',
                  titleHi: 'मरीज़',
                  subtitle: 'Access your health records & services',
                  color: AppColors.primary,
                  bgColor: AppColors.primaryContainer,
                  onTap: () => context.go(AppRoutes.patientLogin),
                ),
                const SizedBox(height: 20),
                _RoleTile(
                  icon: Icons.medical_services_rounded,
                  title: 'Frontline Health Worker',
                  titleHi: 'स्वास्थ्य कार्यकर्ता',
                  subtitle: 'Register patients, record vitals & visits',
                  color: AppColors.secondary,
                  bgColor: AppColors.secondaryContainer,
                  onTap: () => context.go(AppRoutes.workerLogin),
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => context.go(AppRoutes.languageSelect),
                  icon: const Icon(Icons.language_rounded),
                  label: const Text('Change Language / भाषा बदलें'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final IconData icon;
  final String title, titleHi, subtitle;
  final Color color, bgColor;
  final VoidCallback onTap;

  const _RoleTile({
    required this.icon,
    required this.title,
    required this.titleHi,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, size: 34, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  Text(titleHi,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
