import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../shared/widgets/sc_card.dart';
import '../../shared/widgets/patient_bottom_nav.dart';
import '../../shared/widgets/section_header.dart';

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
      // Quick Access
      _Tile('Health\nAssessment', Icons.monitor_heart_rounded, AppRoutes.healthAssessment),
      _Tile('Health\nLocker', Icons.folder_shared_rounded, AppRoutes.healthLocker),
      _Tile('Tele-\nconsult', Icons.video_call_rounded, AppRoutes.teleconsult),
      _Tile('Book\nAppointment', Icons.calendar_month_rounded, AppRoutes.appointmentBooking),
      _Tile('Referral\nTracker', Icons.local_shipping_rounded, AppRoutes.referralTracker),
      _Tile('Follow-\nups', Icons.event_note_rounded, AppRoutes.followUpTracker),
      _Tile('Live\nQueue', Icons.people_rounded, AppRoutes.liveQueue),
      _Tile('My\nMedicines', Icons.medication_rounded, AppRoutes.myMedicine),
      _Tile('Data\nConsent', Icons.lock_person_rounded, AppRoutes.consentManagement),
      
      // Maternal & Child Care
      _Tile('Pregnancy\nTracker', Icons.pregnant_woman_rounded, AppRoutes.pregnancyTracker),
      _Tile('Menstrual\nTracker', Icons.calendar_today_rounded, AppRoutes.menstrualTracker),
      _Tile('Child\nVaccination', Icons.child_care_rounded, AppRoutes.childVaccination),
      _Tile('Vaccination\nRecord', Icons.vaccines_rounded, AppRoutes.vaccinationTracker),
      _Tile('Health\nInfo', Icons.info_rounded, AppRoutes.healthInfo),
      _Tile('Family\nMembers', Icons.family_restroom_rounded, AppRoutes.familyMembers),
      
      // Other Services
      _Tile('Scheme\nEligibility', Icons.card_membership_rounded, AppRoutes.schemeEligibility),
      _Tile('Feedback', Icons.rate_review_rounded, AppRoutes.feedbackGrievance),
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
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Image.asset(
                                  'assets/images/swasthya_connect_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('SwasthyaConnect',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('By HealthSync1 | Team ID: 165109',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.85))),
                        const SizedBox(height: 12),
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

          // ── MediBot Assistant Card ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.medibot),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.smart_toy_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MediBot',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                            SizedBox(height: 2),
                            Text('Your AI health assistant',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.primary, size: 18),
                    ],
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

          // ── Quick Access Section ─────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Quick Access',
              subtitle: 'Essential health services',
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.80,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i >= 9) return const SizedBox.shrink();
                  final t = tiles[i];
                  return DashboardTile(
                    icon: t.icon,
                    label: t.label,
                    iconColor: AppColors.primary,
                    bgColor: AppColors.primaryContainer,
                    onTap: () => context.push(t.route),
                  );
                },
                childCount: 9,
              ),
            ),
          ),

          // ── Maternal & Child Care Section ────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Maternal & Child Care',
              subtitle: 'Track pregnancy, cycles & child health',
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.80,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final tileIndex = i + 9;
                  if (tileIndex >= 15) return const SizedBox.shrink();
                  final t = tiles[tileIndex];
                  return DashboardTile(
                    icon: t.icon,
                    label: t.label,
                    iconColor: AppColors.primary,
                    bgColor: AppColors.primaryContainer,
                    onTap: () => context.push(t.route),
                  );
                },
                childCount: 6,
              ),
            ),
          ),

          // ── Other Services Section ───────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Other Services',
              subtitle: 'Schemes, support & feedback',
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.80,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final tileIndex = i + 15;
                  if (tileIndex >= tiles.length) return const SizedBox.shrink();
                  final t = tiles[tileIndex];
                  return DashboardTile(
                    icon: t.icon,
                    label: t.label,
                    iconColor: AppColors.primary,
                    bgColor: AppColors.primaryContainer,
                    onTap: () => context.push(t.route),
                  );
                },
                childCount: 2,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
    );
  }
}

class _Tile {
  final String label;
  final IconData icon;
  final String route;
  const _Tile(this.label, this.icon, this.route);
}
