import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../shared/widgets/sc_card.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = Hive.box(HiveConstants.settingsBox);
    final name = box.get('patient_name', defaultValue: 'Patient') as String;

    final tiles = [
      _Tile('Health\nAssessment', Icons.monitor_heart_rounded,
          AppColors.primary, AppColors.primaryContainer,
          AppRoutes.healthAssessment),
      _Tile('Health\nLocker', Icons.folder_shared_rounded,
          AppColors.secondary, AppColors.secondaryContainer,
          AppRoutes.healthLocker),
      _Tile('Book\nAppointment', Icons.calendar_month_rounded,
          const Color(0xFF7B2FBE), const Color(0xFFEDE7F6),
          AppRoutes.appointmentBooking),
      _Tile('Live\nQueue', Icons.people_rounded,
          const Color(0xFF0288D1), const Color(0xFFE1F5FE),
          AppRoutes.liveQueue),
      _Tile('Tele-\nconsult', Icons.video_call_rounded,
          const Color(0xFF00897B), const Color(0xFFE0F2F1),
          AppRoutes.teleconsult),
      _Tile('Menstrual\nTracker', Icons.calendar_today_rounded,
          const Color(0xFFE91E63), const Color(0xFFFCE4EC),
          AppRoutes.menstrualTracker),
      _Tile('Pregnancy\nTracker', Icons.pregnant_woman_rounded,
          const Color(0xFFFF6F00), const Color(0xFFFFF8E1),
          AppRoutes.pregnancyTracker),
      _Tile('Child\nVaccination', Icons.child_care_rounded,
          const Color(0xFF43A047), const Color(0xFFE8F5E9),
          AppRoutes.childVaccination),
      _Tile('Vaccination\nRecord', Icons.vaccines_rounded,
          AppColors.secondary, AppColors.secondaryContainer,
          AppRoutes.vaccinationTracker),
      _Tile('Data\nConsent', Icons.lock_person_rounded,
          const Color(0xFF546E7A), const Color(0xFFECEFF1),
          AppRoutes.consentManagement),
      _Tile('My\nMedicines', Icons.medication_rounded,
          const Color(0xFFD84315), const Color(0xFFFBE9E7),
          AppRoutes.myMedicine),
      _Tile('Health\nInfo', Icons.info_rounded,
          AppColors.primary, AppColors.primaryContainer,
          AppRoutes.healthInfo),
      _Tile('Scheme\nEligibility', Icons.card_membership_rounded,
          const Color(0xFF6A1B9A), const Color(0xFFF3E5F5),
          AppRoutes.schemeEligibility),
      _Tile('Feedback', Icons.rate_review_rounded,
          const Color(0xFF00838F), const Color(0xFFE0F7FA),
          AppRoutes.feedbackGrievance),
      _Tile('Referral\nTracker', Icons.local_shipping_rounded,
          const Color(0xFFD84315), const Color(0xFFFBE9E7),
          AppRoutes.referralTracker),
      _Tile('Follow-\nups', Icons.event_note_rounded,
          const Color(0xFF7B2FBE), const Color(0xFFEDE7F6),
          AppRoutes.followUpTracker),
      _Tile('Family\nMembers', Icons.family_restroom_rounded,
          const Color(0xFF00897B), const Color(0xFFE0F2F1),
          AppRoutes.familyMembers),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_rounded, color: Colors.white),
                onPressed: () => context.push(AppRoutes.patientProfile),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(_greeting(),
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8))),
                        Text(name,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Emergency SOS banner ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.emergencySos),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.emergency,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.emergency.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.emergency_rounded,
                          color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Emergency SOS',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            Text('Tap for emergency call & location share',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Service grid ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.80,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final t = tiles[i];
                  return DashboardTile(
                    icon: t.icon,
                    label: t.label,
                    iconColor: t.color,
                    bgColor: t.bg,
                    onTap: () => context.push(t.route),
                  );
                },
                childCount: tiles.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _Tile {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final String route;
  const _Tile(this.label, this.icon, this.color, this.bg, this.route);
}
