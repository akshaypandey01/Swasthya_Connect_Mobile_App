import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../shared/widgets/patient_bottom_nav.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/empty_state.dart';

class AppointmentsListScreen extends ConsumerStatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  ConsumerState<AppointmentsListScreen> createState() =>
      _AppointmentsListScreenState();
}

class _AppointmentsListScreenState
    extends ConsumerState<AppointmentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock appointments data - replace with actual data source
  final List<Map<String, dynamic>> _mockAppointments = [
    {
      'id': 'APT001',
      'date': DateTime.now().add(const Duration(days: 2)),
      'time': '10:00 AM',
      'doctor': 'Dr. Anita Singh',
      'facility': 'PHC Rampur',
      'type': 'General Consultation',
      'status': 'confirmed',
    },
    {
      'id': 'APT002',
      'date': DateTime.now().add(const Duration(days: 5)),
      'time': '2:30 PM',
      'doctor': 'Dr. Ramesh Gupta',
      'facility': 'CHC Bijnor',
      'type': 'Follow-up',
      'status': 'pending',
    },
    {
      'id': 'APT003',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'time': '11:00 AM',
      'doctor': 'Dr. Priya Sharma',
      'facility': 'District Hospital',
      'type': 'Specialist Consultation',
      'status': 'completed',
    },
    {
      'id': 'APT004',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'time': '9:00 AM',
      'doctor': 'Dr. Suresh Kumar',
      'facility': 'PHC Rampur',
      'type': 'General Consultation',
      'status': 'cancelled',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterAppointments(String status) {
    switch (status) {
      case 'upcoming':
        return _mockAppointments
            .where((apt) =>
                (apt['status'] == 'confirmed' || apt['status'] == 'pending') &&
                (apt['date'] as DateTime).isAfter(DateTime.now()))
            .toList();
      case 'past':
        return _mockAppointments
            .where((apt) =>
                apt['status'] == 'completed' ||
                (apt['date'] as DateTime).isBefore(DateTime.now()))
            .toList();
      case 'cancelled':
        return _mockAppointments
            .where((apt) => apt['status'] == 'cancelled')
            .toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList('upcoming'),
          _buildAppointmentList('past'),
          _buildAppointmentList('cancelled'),
        ],
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.appointmentBooking),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book'),
      ),
    );
  }

  Widget _buildAppointmentList(String status) {
    final appointments = _filterAppointments(status);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appointments.isEmpty) {
      return EmptyState(
        icon: status == 'upcoming'
            ? Icons.calendar_today_rounded
            : status == 'past'
                ? Icons.history_rounded
                : Icons.cancel_rounded,
        title: status == 'upcoming'
            ? 'No upcoming appointments'
            : status == 'past'
                ? 'No past appointments'
                : 'No cancelled appointments',
        subtitle: status == 'upcoming'
            ? 'Book an appointment to get started'
            : null,
        actionLabel: status == 'upcoming' ? 'Book Appointment' : null,
        onAction: status == 'upcoming'
            ? () => context.push(AppRoutes.appointmentBooking)
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(seconds: 1));
        setState(() => _isLoading = false);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _AppointmentCard(
            appointment: appointments[index],
            onTap: () {
              // Navigate to appointment details if needed
            },
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = appointment['date'] as DateTime;
    final status = appointment['status'] as String;
    final isUpcoming = date.isAfter(DateTime.now()) &&
        (status == 'confirmed' || status == 'pending');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUpcoming ? AppColors.primary.withOpacity(0.2) : AppColors.border,
          width: isUpcoming ? 1.5 : 1,
        ),
        boxShadow: isUpcoming
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Date, Time, Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMM yyyy').format(date),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            appointment['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 12),

                // Doctor name
                Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment['doctor'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Facility
                Row(
                  children: [
                    const Icon(
                      Icons.local_hospital_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment['facility'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Consultation type
                Row(
                  children: [
                    const Icon(
                      Icons.medical_services_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment['type'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                // Actions for upcoming appointments
                if (isUpcoming) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Reschedule logic
                          },
                          icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                          label: const Text('Reschedule'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push(AppRoutes.liveQueue,
                                extra: {'appointmentId': appointment['id']});
                          },
                          icon: const Icon(Icons.visibility_rounded, size: 18),
                          label: const Text('View Queue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'confirmed':
        return StatusBadge.success('Confirmed', small: true);
      case 'pending':
        return StatusBadge.pending('Pending', small: true);
      case 'cancelled':
        return StatusBadge.cancelled('Cancelled', small: true);
      case 'completed':
        return StatusBadge.neutral('Completed', small: true);
      default:
        return StatusBadge.neutral(status, small: true);
    }
  }
}
