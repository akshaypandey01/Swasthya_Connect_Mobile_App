import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';

class LiveQueueScreen extends StatefulWidget {
  final String appointmentId;
  const LiveQueueScreen({super.key, required this.appointmentId});
  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen>
    with SingleTickerProviderStateMixin {
  int _myToken = 42;
  int _currentToken = 36;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    // Simulate queue moving
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 8));
      if (!mounted) return false;
      setState(() {
        if (_currentToken < _myToken) _currentToken++;
      });
      return _currentToken < _myToken + 2;
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  int get _ahead => (_myToken - _currentToken).clamp(0, 100);
  int get _waitMinutes => _ahead * 5;

  @override
  Widget build(BuildContext context) {
    final isNext = _ahead <= 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Live Queue Status'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // My token
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isNext
                      ? AppColors.triageGreen
                      : AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (isNext
                              ? AppColors.triageGreen
                              : AppColors.primary)
                          .withOpacity(0.3 + _pulseCtrl.value * 0.2),
                      blurRadius: 20 + _pulseCtrl.value * 20,
                      spreadRadius: _pulseCtrl.value * 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Your Token',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    Text('$_myToken',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isNext
                    ? AppColors.secondaryContainer
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isNext
                        ? AppColors.secondary
                        : AppColors.border),
              ),
              child: Column(
                children: [
                  if (isNext)
                    const Text('Your turn is next!',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary)),
                  if (!isNext)
                    Text('$_ahead patient(s) ahead of you',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  if (!isNext)
                    Text('Estimated wait: ~$_waitMinutes minutes',
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Current serving
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Now Serving',
                    value: '$_currentToken',
                    icon: Icons.person_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Ahead of You',
                    value: '$_ahead',
                    icon: Icons.people_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.notifications_rounded,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You will receive a notification when your turn is near.',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
