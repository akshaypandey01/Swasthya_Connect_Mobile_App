import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/repositories/dev_worker_report_repository.dart';
import '../../shared/widgets/worker_bottom_nav.dart';
import '../../shared/widgets/empty_state.dart';

class WorkerPatientsScreen extends ConsumerStatefulWidget {
  const WorkerPatientsScreen({super.key});

  @override
  ConsumerState<WorkerPatientsScreen> createState() =>
      _WorkerPatientsScreenState();
}

class _WorkerPatientsScreenState extends ConsumerState<WorkerPatientsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportRepo = ref.read(devWorkerReportRepositoryProvider);
    
    // Get assigned patients with error handling
    List<dynamic> assignedPatients = [];
    try {
      assignedPatients = reportRepo.getAssignedPatients();
    } catch (e) {
      // Log error but continue with empty list
      // In production, this would use proper error reporting
    }

    // Filter patients based on tab and search
    List<dynamic> getFilteredPatients() {
      var patients = assignedPatients;
      
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        patients = patients.where((p) {
          return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (p.abhaId ?? '').contains(_searchQuery) ||
              (p.phone ?? '').contains(_searchQuery) ||
              p.patientId.contains(_searchQuery);
        }).toList();
      }

      // Filter by tab
      switch (_tabController.index) {
        case 0: // All Patients
          return patients;
        case 1: // Recent
          patients.sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
          return patients.take(10).toList();
        case 2: // Follow-ups
          return patients.where((p) => p.hasPendingFollowUp).toList();
        case 3: // High Risk
          return patients.where((p) => p.riskLevel == 'high').toList();
        default:
          return patients;
      }
    }

    final filteredPatients = getFilteredPatients();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppColors.secondary,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                tooltip: 'Register Patient',
                onPressed: () => context.push(AppRoutes.registerPatient),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondaryDark, AppColors.secondaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
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
                                    fontSize: 15,
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
                        const SizedBox(height: 10),
                        const Text('Frontline Worker',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70)),
                        const Text('Patients',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppColors.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: (index) => setState(() {}),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Recent'),
                    Tab(text: 'Follow-ups'),
                    Tab(text: 'High Risk'),
                  ],
                ),
              ),
            ),
          ),

          // ── Search Bar ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, ABHA ID, or phone...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.person_search_rounded),
                          tooltip: 'Advanced Search',
                          onPressed: () => context.push(AppRoutes.findPatient),
                        ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Patient List ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: filteredPatients.isEmpty
                ? SliverToBoxAdapter(
                    child: EmptyState(
                      icon: _tabController.index == 0
                          ? Icons.people_outline_rounded
                          : _tabController.index == 2
                              ? Icons.event_repeat_rounded
                              : Icons.warning_amber_rounded,
                      title: _searchQuery.isNotEmpty
                          ? 'No patients found'
                          : _tabController.index == 2
                              ? 'No pending follow-ups'
                              : _tabController.index == 3
                                  ? 'No high-risk patients'
                                  : 'No patients assigned',
                      subtitle: _searchQuery.isNotEmpty
                          ? 'Try a different search term'
                          : 'Register new patients to get started',
                      actionLabel: 'Register Patient',
                      onAction: () => context.push(AppRoutes.registerPatient),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PatientCard(patient: filteredPatients[index]),
                        );
                      },
                      childCount: filteredPatients.length,
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 2),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.registerPatient),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Register'),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final dynamic patient;

  const _PatientCard({required this.patient});

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'high':
        return AppColors.triageRed;
      case 'medium':
        return AppColors.triageYellow;
      default:
        return AppColors.triageGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFollowUp = patient.hasPendingFollowUp;
    final hasAbnormalVitals = patient.hasAbnormalVitals;
    final riskColor = _getRiskColor(patient.riskLevel);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: patient.riskLevel == 'high'
              ? AppColors.triageRed.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(
            AppRoutes.workerPatientProfile,
            extra: {'patientId': patient.patientId},
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        patient.name.isNotEmpty
                            ? patient.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${patient.gender} • ${patient.age} years • ${patient.village}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        patient.riskLevel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: riskColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Patient details
                if (patient.abhaId != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.badge_rounded,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'ABHA: ${patient.abhaId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    const Icon(Icons.phone_rounded,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      patient.phone ?? 'No phone',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (patient.latestCondition != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.medical_services_rounded,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          patient.latestCondition,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Alerts
                if (hasFollowUp || hasAbnormalVitals) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (hasFollowUp)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.syncPending.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.event_repeat_rounded,
                                size: 12,
                                color: AppColors.syncPending,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Follow-up Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.syncPending,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (hasAbnormalVitals)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.triageRed.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.warning_rounded,
                                size: 12,
                                color: AppColors.triageRed,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Abnormal Vitals',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.triageRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Last Visit: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _formatDate(patient.lastVisit),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No visit';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
