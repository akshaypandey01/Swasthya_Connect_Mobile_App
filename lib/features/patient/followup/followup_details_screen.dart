import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/followup_model.dart';
import '../../../data/repositories/dev_followup_repository.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';
import '../../shared/widgets/sc_card.dart';

class FollowUpDetailsScreen extends StatefulWidget {
  final String followUpId;

  const FollowUpDetailsScreen({super.key, required this.followUpId});

  @override
  State<FollowUpDetailsScreen> createState() => _FollowUpDetailsScreenState();
}

class _FollowUpDetailsScreenState extends State<FollowUpDetailsScreen> {
  final _repository = DevFollowUpRepository();
  FollowUp? _followUp;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowUp();
  }

  Future<void> _loadFollowUp() async {
    setState(() => _isLoading = true);
    try {
      final followUp = await _repository.getFollowUp(widget.followUpId);
      setState(() {
        _followUp = followUp;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color get _typeColor {
    if (_followUp == null) return AppColors.textHint;
    switch (_followUp!.type) {
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
    if (_followUp == null) return '';
    switch (_followUp!.type) {
      case FollowUpType.postConsultation:
        return 'Post-Consultation Follow-up';
      case FollowUpType.postProcedure:
        return 'Post-Procedure Follow-up';
      case FollowUpType.chronicCare:
        return 'Chronic Care Follow-up';
      case FollowUpType.labReview:
        return 'Lab Results Review';
      case FollowUpType.medicationReview:
        return 'Medication Review';
      case FollowUpType.general:
        return 'General Follow-up';
    }
  }

  Future<void> _showRescheduleDialog() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _followUp!.scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (newDate != null && mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reschedule Follow-up'),
          content: Text(
            'Reschedule to ${DateFormat('dd MMMM yyyy').format(newDate)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        await _repository.rescheduleFollowUp(
          followUpId: widget.followUpId,
          newDate: newDate,
          reason: 'Rescheduled by patient',
        );
        _loadFollowUp();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Follow-up rescheduled successfully')),
          );
        }
      }
    }
  }

  Future<void> _markAsCompleted() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: const Text(
          'Mark this follow-up as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _repository.markAsCompleted(widget.followUpId, null);
      _loadFollowUp();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow-up marked as completed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Follow-up Details'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _followUp == null
              ? _errorState()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        color: _typeColor.withOpacity(0.15),
                        child: Row(
                          children: [
                            Icon(Icons.event_note_rounded,
                                color: _typeColor, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _typeText,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _typeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Appointment details
                            _SectionCard(
                              title: 'Appointment',
                              icon: Icons.calendar_month_rounded,
                              iconColor: AppColors.primary,
                              children: [
                                _InfoRow(
                                  'Date',
                                  DateFormat('dd MMMM yyyy')
                                      .format(_followUp!.scheduledDate),
                                ),
                                if (_followUp!.timeSlot != null)
                                  _InfoRow('Time', _followUp!.timeSlot!),
                                _InfoRow('Doctor', _followUp!.doctor),
                                if (_followUp!.doctorSpecialization != null)
                                  _InfoRow('Specialization',
                                      _followUp!.doctorSpecialization!),
                                _InfoRow('Facility', _followUp!.facility),
                                if (_followUp!.tokenNumber != null)
                                  _InfoRow('Token Number', _followUp!.tokenNumber!),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Reason & instructions
                            _SectionCard(
                              title: 'Details',
                              icon: Icons.info_outline_rounded,
                              iconColor: AppColors.secondary,
                              children: [
                                _InfoRow('Reason', _followUp!.reason),
                                if (_followUp!.instructions != null) ...[
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Instructions:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _followUp!.instructions!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Teleconsult option
                            if (_followUp!.teleconsultAvailable)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.secondary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.video_call_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Teleconsult Available',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Video consultation option available',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (_followUp!.teleconsultAvailable)
                              const SizedBox(height: 12),

                            // Required tests
                            if (_followUp!.requiredTests.isNotEmpty)
                              _SectionCard(
                                title: 'Required Tests',
                                icon: Icons.biotech_rounded,
                                iconColor: const Color(0xFF0288D1),
                                children: [
                                  ..._followUp!.requiredTests.map(
                                    (test) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.science_rounded,
                                            size: 18,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              test,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            if (_followUp!.requiredTests.isNotEmpty)
                              const SizedBox(height: 12),

                            // Documents to carry
                            if (_followUp!.documentsToCarry.isNotEmpty)
                              _SectionCard(
                                title: 'Documents to Carry',
                                icon: Icons.description_rounded,
                                iconColor: const Color(0xFFD84315),
                                children: [
                                  ..._followUp!.documentsToCarry.map(
                                    (doc) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.insert_drive_file_rounded,
                                            size: 18,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              doc,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            if (_followUp!.documentsToCarry.isNotEmpty)
                              const SizedBox(height: 12),

                            // Notes
                            if (_followUp!.notes != null)
                              _SectionCard(
                                title: 'Notes',
                                icon: Icons.note_rounded,
                                iconColor: AppColors.textSecondary,
                                children: [
                                  Text(
                                    _followUp!.notes!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),

                            if (_followUp!.notes != null)
                              const SizedBox(height: 20),

                            // Action buttons
                            if (_followUp!.status == FollowUpStatus.scheduled) ...[
                              ScButton(
                                label: 'Reschedule',
                                icon: Icons.schedule_rounded,
                                onPressed: _showRescheduleDialog,
                              ),
                              const SizedBox(height: 10),
                              ScOutlineButton(
                                label: 'Mark as Completed',
                                icon: Icons.check_circle_outline_rounded,
                                onPressed: _markAsCompleted,
                              ),
                            ],

                            if (_followUp!.status == FollowUpStatus.completed)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.triageGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppColors.triageGreen, size: 22),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Follow-up Completed',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.triageGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text(
            'Follow-up not found',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ScCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
