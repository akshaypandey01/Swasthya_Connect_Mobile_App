import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/worker_referral_model.dart';
import '../../../data/repositories/dev_worker_referral_repository.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';

class WorkerReferralListScreen extends ConsumerStatefulWidget {
  const WorkerReferralListScreen({super.key});

  @override
  ConsumerState<WorkerReferralListScreen> createState() => _WorkerReferralListScreenState();
}

class _WorkerReferralListScreenState extends ConsumerState<WorkerReferralListScreen>
    with SingleTickerProviderStateMixin {
  final _repository = DevWorkerReferralRepository();
  late TabController _tabController;
  List<WorkerReferral> _activeReferrals = [];
  List<WorkerReferral> _pastReferrals = [];
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
    final workerId = box.get(HiveConstants.userIdKey, defaultValue: 'worker_123') as String;

    try {
      final active = await _repository.getActiveReferrals(workerId);
      final all = await _repository.getReferrals(workerId: workerId);
      final past = all.where((r) =>
          r.status == ReferralStatusType.completed ||
          r.status == ReferralStatusType.rejected ||
          r.status == ReferralStatusType.cancelled).toList();

      setState(() {
        _activeReferrals = active;
        _pastReferrals = past;
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
        title: 'Referral Management',
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadReferrals,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.secondary,
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_activeReferrals, true),
                      _buildList(_pastReferrals, false),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.createReferral);
          _loadReferrals();
        },
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Referral'),
      ),
    );
  }

  Widget _buildList(List<WorkerReferral> referrals, bool isActive) {
    if (referrals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.local_shipping_rounded : Icons.check_circle_outline_rounded,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              isActive ? 'No Active Referrals' : 'No Past Referrals',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isActive
                  ? 'Create a referral to get started'
                  : 'Completed referrals will appear here',
              style: const TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReferrals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: referrals.length,
        itemBuilder: (context, index) => _ReferralCard(
          referral: referrals[index],
          onTap: () {
            context.push(AppRoutes.referralDetails, extra: referrals[index].id);
            _loadReferrals();
          },
        ),
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final WorkerReferral referral;
  final VoidCallback onTap;

  const _ReferralCard({required this.referral, required this.onTap});

  Color get _urgencyColor {
    switch (referral.urgency) {
      case ReferralUrgencyLevel.emergency:
        return AppColors.triageRed;
      case ReferralUrgencyLevel.urgent:
        return AppColors.triageYellow;
      case ReferralUrgencyLevel.normal:
        return AppColors.triageGreen;
    }
  }

  Color get _statusColor {
    switch (referral.status) {
      case ReferralStatusType.pending:
        return AppColors.triageYellow;
      case ReferralStatusType.accepted:
        return AppColors.secondary;
      case ReferralStatusType.inTransit:
        return AppColors.primary;
      case ReferralStatusType.completed:
        return AppColors.triageGreen;
      case ReferralStatusType.rejected:
      case ReferralStatusType.cancelled:
        return AppColors.textHint;
    }
  }

  String get _statusText {
    switch (referral.status) {
      case ReferralStatusType.pending:
        return 'PENDING';
      case ReferralStatusType.accepted:
        return 'ACCEPTED';
      case ReferralStatusType.inTransit:
        return 'IN TRANSIT';
      case ReferralStatusType.completed:
        return 'COMPLETED';
      case ReferralStatusType.rejected:
        return 'REJECTED';
      case ReferralStatusType.cancelled:
        return 'CANCELLED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _urgencyColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      referral.patientName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${referral.specialization} • ${referral.toFacility}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
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
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(referral.createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
