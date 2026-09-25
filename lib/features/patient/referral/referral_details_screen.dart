import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/referral_model.dart';
import '../../../data/repositories/dev_referral_repository.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';

class ReferralDetailsScreen extends StatefulWidget {
  final String referralId;

  const ReferralDetailsScreen({super.key, required this.referralId});

  @override
  State<ReferralDetailsScreen> createState() => _ReferralDetailsScreenState();
}

class _ReferralDetailsScreenState extends State<ReferralDetailsScreen> {
  final _repository = DevReferralRepository();
  Referral? _referral;
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

  Color get _urgencyColor {
    if (_referral == null) return AppColors.textHint;
    switch (_referral!.urgency) {
      case ReferralUrgency.emergency:
        return AppColors.triageRed;
      case ReferralUrgency.urgent:
        return AppColors.triageYellow;
      case ReferralUrgency.routine:
        return AppColors.triageGreen;
    }
  }

  String get _urgencyText {
    if (_referral == null) return '';
    switch (_referral!.urgency) {
      case ReferralUrgency.emergency:
        return 'EMERGENCY';
      case ReferralUrgency.urgent:
        return 'URGENT';
      case ReferralUrgency.routine:
        return 'ROUTINE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Referral Details'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _referral == null
              ? _errorState()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Urgency banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        color: _urgencyColor.withOpacity(0.15),
                        child: Row(
                          children: [
                            Icon(Icons.flag_rounded,
                                color: _urgencyColor, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              '$_urgencyText Priority',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _urgencyColor,
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
                            // Facility details
                            _SectionCard(
                              title: 'Referral To',
                              icon: Icons.local_hospital_rounded,
                              iconColor: AppColors.primary,
                              children: [
                                _InfoRow('Facility', _referral!.toFacility),
                                _InfoRow('Address', _referral!.toFacilityAddress),
                                if (_referral!.toFacilityPhone != null)
                                  _InfoRow('Phone', _referral!.toFacilityPhone!),
                                _InfoRow('Specialization', _referral!.specialization),
                                if (_referral!.receivingDoctor != null)
                                  _InfoRow('Doctor', _referral!.receivingDoctor!),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Referral reason
                            _SectionCard(
                              title: 'Referral Details',
                              icon: Icons.description_rounded,
                              iconColor: AppColors.secondary,
                              children: [
                                _InfoRow('Reason', _referral!.reason),
                                if (_referral!.diagnosis != null)
                                  _InfoRow('Diagnosis', _referral!.diagnosis!),
                                _InfoRow('Referring Doctor', _referral!.referringDoctor),
                                _InfoRow('From', _referral!.fromFacility),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Schedule info
                            _SectionCard(
                              title: 'Schedule',
                              icon: Icons.event_rounded,
                              iconColor: const Color(0xFF7B2FBE),
                              children: [
                                _InfoRow(
                                  'Referred On',
                                  DateFormat('dd MMMM yyyy, hh:mm a')
                                      .format(_referral!.createdAt),
                                ),
                                if (_referral!.scheduledDate != null)
                                  _InfoRow(
                                    'Scheduled Date',
                                    DateFormat('dd MMMM yyyy')
                                        .format(_referral!.scheduledDate!),
                                  ),
                                if (_referral!.completedAt != null)
                                  _InfoRow(
                                    'Completed On',
                                    DateFormat('dd MMMM yyyy')
                                        .format(_referral!.completedAt!),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Transport section
                            if (_referral!.transportArranged != null)
                              _SectionCard(
                                title: 'Transport',
                                icon: Icons.local_shipping_rounded,
                                iconColor: const Color(0xFF0288D1),
                                children: [
                                  _InfoRow(
                                    'Transport Arranged',
                                    _referral!.transportArranged!,
                                  ),
                                  if (_referral!.transportDetails != null)
                                    _InfoRow(
                                      'Details',
                                      _referral!.transportDetails!,
                                    ),
                                ],
                              ),

                            if (_referral!.transportArranged != null)
                              const SizedBox(height: 12),

                            // Attached documents
                            if (_referral!.attachedDocuments.isNotEmpty)
                              _SectionCard(
                                title: 'Attached Documents',
                                icon: Icons.attach_file_rounded,
                                iconColor: const Color(0xFF00897B),
                                children: [
                                  ..._referral!.attachedDocuments.map(
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

                            if (_referral!.attachedDocuments.isNotEmpty)
                              const SizedBox(height: 12),

                            // Notes
                            if (_referral!.notes != null)
                              _SectionCard(
                                title: 'Notes',
                                icon: Icons.note_rounded,
                                iconColor: AppColors.textSecondary,
                                children: [
                                  Text(
                                    _referral!.notes!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),

                            if (_referral!.notes != null)
                              const SizedBox(height: 12),

                            // Status timeline
                            _SectionCard(
                              title: 'Status Timeline',
                              icon: Icons.timeline_rounded,
                              iconColor: AppColors.primary,
                              children: [
                                _StatusTimeline(
                                    statusHistory: _referral!.statusHistory),
                              ],
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
            'Referral not found',
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

class _StatusTimeline extends StatelessWidget {
  final List<ReferralStatusUpdate> statusHistory;

  const _StatusTimeline({required this.statusHistory});

  Color _getStatusColor(ReferralStatus status) {
    switch (status) {
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

  String _getStatusText(ReferralStatus status) {
    switch (status) {
      case ReferralStatus.pending:
        return 'Pending';
      case ReferralStatus.scheduled:
        return 'Scheduled';
      case ReferralStatus.inTransit:
        return 'In Transit';
      case ReferralStatus.completed:
        return 'Completed';
      case ReferralStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(statusHistory.length, (index) {
        final update = statusHistory[index];
        final isLast = index == statusHistory.length - 1;
        final color = _getStatusColor(update.status);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Status info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(update.status),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(update.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                    if (update.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        update.note!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (update.updatedBy != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'by ${update.updatedBy}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textHint,
                        ),
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
