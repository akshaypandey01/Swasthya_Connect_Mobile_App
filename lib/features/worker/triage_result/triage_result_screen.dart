import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/encounter_model.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';
import 'triage_engine.dart';

class TriageResultScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> vitals;
  final Map<String, dynamic> symptoms;
  final String patientId;
  final String encounterId;

  const TriageResultScreen({
    super.key,
    required this.vitals,
    required this.symptoms,
    required this.patientId,
    required this.encounterId,
  });

  @override
  ConsumerState<TriageResultScreen> createState() => _TriageResultScreenState();
}

class _TriageResultScreenState extends ConsumerState<TriageResultScreen>
    with SingleTickerProviderStateMixin {
  late TriageResult _result;
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _result = TriageEngine.evaluate(
      vitals: widget.vitals,
      symptoms: widget.symptoms,
    );
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
    _persistResult();
  }

  Future<void> _persistResult() async {
    final box = Hive.box<EncounterModel>(HiveConstants.encounterBox);
    final encounter = box.get(widget.encounterId);
    if (encounter != null) {
      encounter.triageSeverity = _result.severityString;
      await encounter.save();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _severityColor {
    switch (_result.severity) {
      case TriageSeverity.green: return AppColors.triageGreen;
      case TriageSeverity.yellow: return AppColors.triageYellow;
      case TriageSeverity.red: return AppColors.triageRed;
      case TriageSeverity.critical: return AppColors.triageCritical;
    }
  }

  IconData get _severityIcon {
    switch (_result.severity) {
      case TriageSeverity.green: return Icons.check_circle_rounded;
      case TriageSeverity.yellow: return Icons.warning_rounded;
      case TriageSeverity.red: return Icons.priority_high_rounded;
      case TriageSeverity.critical: return Icons.emergency_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Triage Result'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Severity banner ────────────────────────────────────────────
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(_severityIcon, color: Colors.white, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      _result.severityLabel,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _result.severityLabelHi,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Confidence: ${(_result.confidenceScore * 100).toStringAsFixed(0)}%  •  ${_result.modelVersion}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Recommendation ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_rounded, color: color, size: 20),
                      const SizedBox(width: 8),
                      Text('Recommended Action',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_result.recommendation,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Triggering factors ─────────────────────────────────────────
            if (_result.triggeringFactors.isNotEmpty) ...[
              const Text('Flagged Factors',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              ..._result.triggeringFactors.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.fiber_manual_record,
                          size: 8, color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(f,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Vitals summary ─────────────────────────────────────────────
            const Text('Recorded Vitals',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            _VitalsSummary(vitals: widget.vitals),
            const SizedBox(height: 32),

            // ── Action buttons ─────────────────────────────────────────────
            if (_result.severity == TriageSeverity.critical ||
                _result.severity == TriageSeverity.red) ...[
              ScButton(
                label: 'Emergency Escalation',
                icon: Icons.emergency_rounded,
                color: AppColors.emergency,
                onPressed: () => context.push(
                  AppRoutes.emergencyEscalation,
                  extra: {'patientId': widget.patientId},
                ),
              ),
              const SizedBox(height: 12),
            ],
            ScButton(
              label: 'Start Tele-consultation',
              icon: Icons.video_call_rounded,
              color: _result.severity == TriageSeverity.critical
                  ? AppColors.triageRed
                  : AppColors.primary,
              onPressed: () => context.push(
                AppRoutes.workerTeleconsult,
                extra: {
                  'priority': _result.severity == TriageSeverity.critical
                      ? 'urgent'
                      : _result.severity == TriageSeverity.red
                          ? 'priority'
                          : 'routine'
                },
              ),
            ),
            const SizedBox(height: 12),
            ScButton(
              label: 'Back to Patient Profile',
              icon: Icons.person_rounded,
              color: AppColors.secondary,
              onPressed: () => context.push(
                AppRoutes.workerPatientProfile,
                extra: {'patientId': widget.patientId},
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _VitalsSummary extends StatelessWidget {
  final Map<String, dynamic> vitals;
  const _VitalsSummary({required this.vitals});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('BP', '${vitals['bp_systolic'] ?? '--'}/${vitals['bp_diastolic'] ?? '--'} mmHg', Icons.monitor_heart_rounded),
      ('SpO₂', '${vitals['spo2'] ?? '--'}%', Icons.air_rounded),
      ('Temp', '${vitals['temperature'] ?? '--'}°F', Icons.thermostat_rounded),
      ('Pulse', '${vitals['pulse'] ?? '--'} bpm', Icons.favorite_rounded),
      ('Weight', '${vitals['weight'] ?? '--'} kg', Icons.monitor_weight_rounded),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        return Container(
          width: (MediaQuery.of(context).size.width - 60) / 2,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(item.$3, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$1,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  Text(item.$2,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
