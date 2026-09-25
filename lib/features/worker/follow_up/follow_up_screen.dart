import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';

class FollowUpScreen extends StatelessWidget {
  final String patientId;
  const FollowUpScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final trackers = [
      _TrackerItem(
        icon: Icons.calendar_today_rounded,
        title: 'Menstrual Tracker',
        subtitle: 'Log cycle dates and symptoms',
        color: const Color(0xFFE91E63),
        bg: const Color(0xFFFCE4EC),
        route: AppRoutes.menstrualTracker,
      ),
      _TrackerItem(
        icon: Icons.pregnant_woman_rounded,
        title: 'Pregnancy Tracker',
        subtitle: 'Trimester milestones & checkups',
        color: const Color(0xFFFF6F00),
        bg: const Color(0xFFFFF8E1),
        route: AppRoutes.pregnancyTracker,
      ),
      _TrackerItem(
        icon: Icons.child_care_rounded,
        title: 'Child Vaccination',
        subtitle: 'Immunization schedule & dues',
        color: const Color(0xFF43A047),
        bg: const Color(0xFFE8F5E9),
        route: AppRoutes.childVaccination,
      ),
      _TrackerItem(
        icon: Icons.vaccines_rounded,
        title: 'Vaccination Record',
        subtitle: 'Adult immunization history',
        color: AppColors.secondary,
        bg: AppColors.secondaryContainer,
        route: AppRoutes.vaccinationTracker,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Follow-up & Trackers'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  patientId.isNotEmpty
                      ? 'Patient ID: $patientId'
                      : 'Select a patient to log tracker entries',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.primary),
                ),
              ],
            ),
          ),
          ...trackers.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ScCard(
                onTap: () => context.push(t.route),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          color: t.bg, shape: BoxShape.circle),
                      child: Icon(t.icon, color: t.color, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: t.color)),
                          Text(t.subtitle,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackerItem {
  final IconData icon;
  final String title, subtitle, route;
  final Color color, bg;
  const _TrackerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bg,
    required this.route,
  });
}
