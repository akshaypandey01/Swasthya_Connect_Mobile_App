import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/followup_model.dart';
import '../../../data/repositories/dev_followup_repository.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';

class FollowUpListScreen extends StatefulWidget {
  const FollowUpListScreen({super.key});

  @override
  State<FollowUpListScreen> createState() => _FollowUpListScreenState();
}

class _FollowUpListScreenState extends State<FollowUpListScreen>
    with SingleTickerProviderStateMixin {
  final _repository = DevFollowUpRepository();
  late TabController _tabController;
  List<FollowUp> _upcomingFollowUps = [];
  List<FollowUp> _dueFollowUps = [];
  List<FollowUp> _overdueFollowUps = [];
  List<FollowUp> _pastFollowUps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFollowUps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowUps() async {
    setState(() => _isLoading = true);
    final box = Hive.box(HiveConstants.settingsBox);
    final patientId = box.get(HiveConstants.userIdKey, defaultValue: 'patient_123') as String;

    try {
      final upcoming = await _repository.getUpcomingFollowUps(patientId);
      final due = await _repository.getDueFollowUps(patientId);
      final overdue = await _repository.getOverdueFollowUps(patientId);
      final past = await _repository.getPastFollowUps(patientId);

      setState(() {
        _upcomingFollowUps = upcoming;
        _dueFollowUps = due;
        _overdueFollowUps = overdue;
        _pastFollowUps = past;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int get _activeCount => _upcomingFollowUps.length + _dueFollowUps.length + _overdueFollowUps.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScAppBar(
        title: 'Follow-ups',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadFollowUps,
          ),
        ],
      ),
      body: Column(
        children: [
          // Alert banner for overdue follow-ups
          if (_overdueFollowUps.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.triageRed.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded,
                      color: AppColors.triageRed, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You have ${_overdueFollowUps.length} overdue follow-up${_overdueFollowUps.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.triageRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                      const Text('Upcoming'),
                      if (_activeCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_activeCount',
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
                const Tab(text: 'Due'),
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
                      // Upcoming tab
                      _buildUpcomingTab(),

                      // Due tab
                      _buildDueTab(),

                      // Past tab
                      _pastFollowUps.isEmpty
                          ? _emptyState(
                              icon: Icons.history_rounded,
                              title: 'No Past Follow-ups',
                              subtitle: 'Your completed follow-ups will appear here',
                            )
                          : RefreshIndicator(
                              onRefresh: _loadFollowUps,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _pastFollowUps.length,
                                itemBuilder: (context, index) =>
                                    _FollowUpCard(
                                      followUp: _pastFollowUps[index],
                                      onTap: () => _navigateToDetails(_pastFollowUps[index].id),
                                    ),
                              ),
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    final hasOverdue = _overdueFollowUps.isNotEmpty;
    final hasUpcoming = _upcomingFollowUps.isNotEmpty;

    if (!hasOverdue && !hasUpcoming) {
      return _emptyState(
        icon: Icons.event_available_rounded,
        title: 'No Upcoming Follow-ups',
        subtitle: 'Your scheduled follow-ups will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowUps,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overdue section
          if (hasOverdue) ...[
            Row(
              children: [
                const Icon(Icons.warning_rounded,
                    color: AppColors.triageRed, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'OVERDUE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.triageRed,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._overdueFollowUps.map((f) => _FollowUpCard(
                  followUp: f,
                  isOverdue: true,
                  onTap: () => _navigateToDetails(f.id),
                )),
            const SizedBox(height: 16),
          ],

          // Upcoming section
          if (hasUpcoming) ...[
            const Row(
              children: [
                Icon(Icons.schedule_rounded,
                    color: AppColors.primary, size: 18),
                SizedBox(width: 6),
                Text(
                  'UPCOMING',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._upcomingFollowUps.map((f) => _FollowUpCard(
                  followUp: f,
                  onTap: () => _navigateToDetails(f.id),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildDueTab() {
    if (_dueFollowUps.isEmpty) {
      return _emptyState(
        icon: Icons.event_note_rounded,
        title: 'No Follow-ups Due Soon',
        subtitle: 'Follow-ups due within 3 days will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowUps,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dueFollowUps.length,
        itemBuilder: (context, index) => _FollowUpCard(
          followUp: _dueFollowUps[index],
          isDue: true,
          onTap: () => _navigateToDetails(_dueFollowUps[index].id),
        ),
      ),
    );
  }

  void _navigateToDetails(String followUpId) {
    context.push(AppRoutes.followUpDetails, extra: followUpId);
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

class _FollowUpCard extends StatelessWidget {
  final FollowUp followUp;
  final bool isOverdue;
  final bool isDue;
  final VoidCallback onTap;

  const _FollowUpCard({
    required this.followUp,
    this.isOverdue = false,
    this.isDue = false,
    required this.onTap,
  });

  Color get _typeColor {
    switch (followUp.type) {
      case FollowUpType.postConsultation:
        return AppColors.primary;
      case FollowUpType.postProcedure:
        return AppColors.triageRed;
      case FollowUpType.chronicCare:
        return const Color(0xFF7B2FBE);
      case FollowUpType.labReview:
        return const Color(0xFF0288D1);
      case FollowUpType.medicationReview:
        return const Color(0xFFD84315);
      case FollowUpType.general:
        return AppColors.textSecondary;
    }
  }

  String get _typeText {
    switch (followUp.type) {
      case FollowUpType.postConsultation:
        return 'POST-CONSULT';
      case FollowUpType.postProcedure:
        return 'POST-PROCEDURE';
      case FollowUpType.chronicCare:
        return 'CHRONIC CARE';
      case FollowUpType.labReview:
        return 'LAB REVIEW';
      case FollowUpType.medicationReview:
        return 'MEDICATION';
      case FollowUpType.general:
        return 'GENERAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysUntil = followUp.scheduledDate.difference(now).inDays;
    final isPast = followUp.status == FollowUpStatus.completed ||
        followUp.status == FollowUpStatus.cancelled;

    return ScCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Type indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _typeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _typeColor,
                  ),
                ),
              ),
              const Spacer(),

              // Teleconsult badge
              if (followUp.teleconsultAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.video_call_rounded,
                          size: 12, color: AppColors.secondary),
                      SizedBox(width: 3),
                      Text(
                        'Teleconsult',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Doctor & facility
          Text(
            followUp.doctor,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${followUp.doctorSpecialization ?? 'Specialist'} • ${followUp.facility}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Reason
          Text(
            followUp.reason,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // Footer
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: isOverdue
                    ? AppColors.triageRed
                    : isDue
                        ? AppColors.triageYellow
                        : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM yyyy').format(followUp.scheduledDate),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOverdue
                      ? AppColors.triageRed
                      : isDue
                          ? AppColors.triageYellow
                          : AppColors.textSecondary,
                ),
              ),
              if (followUp.timeSlot != null) ...[
                const SizedBox(width: 4),
                Text(
                  '• ${followUp.timeSlot}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
              const Spacer(),

              // Status text
              if (!isPast && !isOverdue && daysUntil <= 7)
                Text(
                  daysUntil == 0
                      ? 'Today'
                      : daysUntil == 1
                          ? 'Tomorrow'
                          : 'in $daysUntil days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDue ? AppColors.triageYellow : AppColors.textHint,
                  ),
                ),

              if (isPast)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: followUp.status == FollowUpStatus.completed
                        ? AppColors.triageGreen.withOpacity(0.12)
                        : AppColors.textHint.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    followUp.status == FollowUpStatus.completed
                        ? 'COMPLETED'
                        : 'CANCELLED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: followUp.status == FollowUpStatus.completed
                          ? AppColors.triageGreen
                          : AppColors.textHint,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
