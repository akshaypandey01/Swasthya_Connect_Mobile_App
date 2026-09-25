import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/auth_service.dart';
import '../../shared/widgets/sc_app_bar.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = Hive.box(HiveConstants.settingsBox);
    final uid = box.get(HiveConstants.userIdKey, defaultValue: '') as String;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Profile & Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primaryContainer,
              child: const Icon(Icons.person_rounded,
                  size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            const Text('Patient',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            Text(uid,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 28),
            _Tile(
              icon: Icons.language_rounded,
              title: 'Language / भाषा',
              subtitle:
                  locale.languageCode == 'hi' ? 'हिंदी' : 'English',
              onTap: () => context.push(AppRoutes.languageSelect),
            ),
            _Tile(
              icon: Icons.lock_person_rounded,
              title: 'Data Consent',
              subtitle: 'Manage provider access',
              onTap: () => context.push(AppRoutes.consentManagement),
            ),
            _Tile(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Appointment & medication reminders',
              onTap: () {},
            ),
            _Tile(
              icon: Icons.help_rounded,
              title: 'Help & Support',
              subtitle: 'FAQs and contact',
              onTap: () {},
            ),
            _Tile(
              icon: Icons.info_rounded,
              title: 'About',
              subtitle: 'SwasthyaConnect v1.0.0',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go(AppRoutes.splash);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.triageRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _Tile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
