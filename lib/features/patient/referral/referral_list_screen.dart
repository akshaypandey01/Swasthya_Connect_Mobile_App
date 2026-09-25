import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/referral_model.dart';
import '../../../data/repositories/dev_referral_repository.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';

class ReferralListScreen extends StatefulWidget {
  const ReferralListScreen({super.key});

  @override
  State<ReferralListScreen> createState() => _ReferralListScreenState();
}

class _ReferralListScreenState extends State<ReferralListScreen>
    with SingleTickerProviderStateMixin {
  final _repository = DevReferralRepository();
  late TabController _tabController;
  List<Referral> _allReferrals = [];
  List<Referral> _activeReferrals = [];
  List<Referral> _completedReferrals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReferrals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReferrals() async {
    setState(() => _isLoading = true);
    final box = Hive.box(HiveConstants.settingsBox);
    final patientId = box.get(HiveConstants.userIdKey, defaultValue: 'patient_123') as String;

    try {
      final all = await _repository.getReferrals(patientId: patientId);
      setState(() {
        _allReferrals = all;
        _activeReferrals = all
            .where((r) =>
                r.status != ReferralStatus.completed &&
                r.status != ReferralStatus.cancelled)
            .toList();
        _completedReferrals = all
            .where((r) =>
                r.status == ReferralStatus.completed ||
                r.status == ReferralStatus.cancelled)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScAppBar(
        title: 'Referral Tracker',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadReferrals,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Active'),
                      if (_activeReferrals.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_activeReferrals.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Past'),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Active referrals
                      _activeReferrals.isEmpty
                          ? _emptyState(
                              icon: Icons.local_hospital_rounded,
                              title: 'No Active Referrals',
                              subtitle: 'Your active referrals will appear here',
                            )
                          : RefreshIndicator(
                              onRefresh: _loadReferrals,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _activeReferrals.length,
                                itemBuilder: (context, index) =>
                                    _ReferralCard(referral: _activeReferrals[index]),
                              ),
                            ),

                      // Completed referrals
                      _completedReferrals.isEmpty
                          ? _emptyState(
                              icon: Icons.check_circle_outline_rounded,
                              title: 'No Past Referrals',
                              subtitle: 'Your completed referrals will appear here',
                            )
                          : RefreshIndicator(
                              onRefresh: _loadReferrals,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _completedReferrals.length,
                                itemBuilder: (context, index) =>
                                    _ReferralCard(referral: _completedReferrals[index]),
                              ),
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
        ],
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final Referral referral;

  const _ReferralCard({required this.referral});

  Color get _urgencyColor {
    switch (referral.urgency) {
      case ReferralUrgency.emergency:
        return AppColors.triageRed;
      case ReferralUrgency.urgent:
        return AppColors.triageYellow;
      case ReferralUrgency.routine:
        return AppColors.triageGreen;
    }
  }

  Color get _statusColor {
    switch (referral.status) {
      case ReferralStatus.pending:
        return AppColors.triageYellow;
      case ReferralStatus.scheduled:
        return AppColors.primary;
      case ReferralStatus.inTransit:
        return AppColors.secondary;
      case ReferralStatus.completed:
        return AppColors.triageGreen;
      case ReferralStatus.cancelled:
        return AppColors.textHint;
    }
  }

  String get _statusText {
    switch (referral.status) {
      case ReferralStatus.pending:
        return 'PENDING';
      case ReferralStatus.scheduled:
        return 'SCHEDULED';
      case ReferralStatus.inTransit:
        return 'IN TRANSIT';
      case ReferralStatus.completed:
        return 'COMPLETED';
      case ReferralStatus.cancelled:
        return 'CANCELLED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScCard(
      onTap: () => context.push(AppRoutes.referralDetails, extra: referral.id),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Urgency indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _urgencyColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Facility info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      referral.toFacility,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      referral.specialization,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Reason
          Text(
            referral.reason,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // Footer info
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                'Referred ${DateFormat('dd MMM yyyy').format(referral.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
              if (referral.scheduledDate != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.event_rounded,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM').format(referral.scheduledDate!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
