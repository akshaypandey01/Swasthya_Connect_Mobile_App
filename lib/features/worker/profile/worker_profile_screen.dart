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

class WorkerProfileScreen extends ConsumerWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = Hive.box(HiveConstants.settingsBox);
    final workerId = box.get(HiveConstants.userIdKey, defaultValue: '') as String;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Profile & Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.secondaryContainer,
              child: const Icon(Icons.medical_services_rounded,
                  size: 40, color: AppColors.secondary),
            ),
            const SizedBox(height: 12),
            const Text('Frontline Health Worker',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            Text(workerId,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 28),

            _SettingsTile(
              icon: Icons.language_rounded,
              title: 'Language / भाषा',
              subtitle:
                  locale.languageCode == 'hi' ? 'हिंदी' : 'English',
              onTap: () => context.push(AppRoutes.languageSelect),
            ),
            _SettingsTile(
              icon: Icons.sync_rounded,
              title: 'Sync Status',
              subtitle: 'View pending & synced records',
              onTap: () => context.push(AppRoutes.workerSyncStatus),
            ),
            _SettingsTile(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Follow-up reminders',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.info_rounded,
              title: 'About SwasthyaConnect',
              subtitle: 'Version 1.0.0',
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
                label: const Text('Logout / लॉगआउट',
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _SettingsTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
