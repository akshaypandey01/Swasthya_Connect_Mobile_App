import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/worker_referral_model.dart';
import '../../../data/repositories/dev_worker_referral_repository.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';
import '../../shared/widgets/sc_card.dart';

class WorkerReferralDetailsScreen extends StatefulWidget {
  final String referralId;

  const WorkerReferralDetailsScreen({super.key, required this.referralId});

  @override
  State<WorkerReferralDetailsScreen> createState() => _WorkerReferralDetailsScreenState();
}

class _WorkerReferralDetailsScreenState extends State<WorkerReferralDetailsScreen> {
  final _repository = DevWorkerReferralRepository();
  WorkerReferral? _referral;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferral();
  }

  Future<void> _loadReferral() async {
    setState(() => _isLoading = true);
    try {
      final referral = await _repository.getReferral(widget.referralId);
      setState(() {
        _referral = referral;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(ReferralStatusType newStatus, String? note) async {
    await _repository.updateReferralStatus(
      referralId: widget.referralId,
      newStatus: newStatus,
      note: note,
    );
    _loadReferral();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const ScAppBar(
          title: 'Referral Details',
          backgroundColor: AppColors.secondary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_referral == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const ScAppBar(
          title: 'Referral Details',
          backgroundColor: AppColors.secondary,
        ),
        body: const Center(child: Text('Referral not found')),
      );
    }

    final urgencyColor = _referral!.urgency == ReferralUrgencyLevel.emergency
        ? AppColors.triageRed
        : _referral!.urgency == ReferralUrgencyLevel.urgent
            ? AppColors.triageYellow
            : AppColors.triageGreen;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(
        title: 'Referral Details',
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: urgencyColor.withOpacity(0.15),
              child: Row(
                children: [
                  Icon(Icons.flag_rounded, color: urgencyColor, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    '${_referral!.urgency.name.toUpperCase()} Priority',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: urgencyColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection(
                    'Patient Information',
                    Icons.person_rounded,
                    AppColors.primary,
                    [
                      _InfoRow('Name', _referral!.patientName),
                      _InfoRow('Referred By', _referral!.workerName),
                      _InfoRow('From', _referral!.fromFacility),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    'Destination',
                    Icons.local_hospital_rounded,
                    AppColors.secondary,
                    [
                      _InfoRow('Facility', _referral!.toFacility),
                      _InfoRow('Address', _referral!.toFacilityAddress),
                      if (_referral!.toFacilityPhone != null)
                        _InfoRow('Phone', _referral!.toFacilityPhone!),
                      _InfoRow('Specialization', _referral!.specialization),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    'Clinical Details',
                    Icons.description_rounded,
                    const Color(0xFF7B2FBE),
                    [
                      _InfoRow('Reason', _referral!.reason),
                      if (_referral!.suspectedCondition != null)
                        _InfoRow('Suspected Condition', _referral!.suspectedCondition!),
                      if (_referral!.specialInstructions != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Special Instructions:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _referral!.specialInstructions!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    'Status Timeline',
                    Icons.timeline_rounded,
                    AppColors.secondary,
                    [_StatusTimeline(history: _referral!.statusHistory)],
                  ),
                  const SizedBox(height: 20),
                  if (_referral!.status == ReferralStatusType.pending ||
                      _referral!.status == ReferralStatusType.accepted)
                    ScButton(
                      label: 'Update Status',
                      icon: Icons.update_rounded,
                      onPressed: () => _showStatusDialog(),
                      color: AppColors.secondary,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
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
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
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

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Mark In Transit'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(ReferralStatusType.inTransit, 'Patient en route');
              },
            ),
            ListTile(
              title: const Text('Mark Completed'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(ReferralStatusType.completed, 'Consultation completed');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
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
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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

class _StatusTimeline extends StatelessWidget {
  final List<ReferralStatusHistory> history;
  const _StatusTimeline({required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(history.length, (index) {
        final update = history[index];
        final isLast = index == history.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
                if (!isLast)
                  Container(width: 2, height: 40, color: AppColors.border),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update.status.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(update.timestamp),
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                    if (update.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        update.note!,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
