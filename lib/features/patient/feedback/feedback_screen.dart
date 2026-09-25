import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  String _category = 'Service Quality';
  bool _submitted = false;

  // Past feedback (would come from Firestore)
  final _pastFeedback = [
    _Feedback('PHC Rampur', 3, 'Long waiting time', 'Under Review', '12 Sep 2026'),
    _Feedback('CHC Bijnor', 5, 'Excellent service', 'Resolved', '01 Aug 2026'),
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Feedback & Grievance'),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Submit Feedback'),
                Tab(text: 'My Submissions'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ── Submit tab ───────────────────────────────────────────
                  _submitted
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 72,
                                  color: AppColors.secondary),
                              const SizedBox(height: 16),
                              const Text('Feedback Submitted!',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              const Text(
                                  'We will review and respond shortly.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 24),
                              TextButton(
                                onPressed: () => setState(() {
                                  _submitted = false;
                                  _rating = 0;
                                  _commentCtrl.clear();
                                }),
                                child: const Text('Submit Another'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rate your experience',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: List.generate(
                                  5,
                                  (i) => GestureDetector(
                                    onTap: () =>
                                        setState(() => _rating = i + 1),
                                    child: Icon(
                                      i < _rating
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: 44,
                                      color: i < _rating
                                          ? AppColors.triageYellow
                                          : AppColors.border,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text('Category',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  'Service Quality',
                                  'Wait Time',
                                  'Staff Behaviour',
                                  'Facility Cleanliness',
                                  'Medicine Availability',
                                  'Other',
                                ].map((c) => ChoiceChip(
                                      label: Text(c,
                                          style: const TextStyle(
                                              fontSize: 12)),
                                      selected: _category == c,
                                      onSelected: (_) =>
                                          setState(() => _category = c),
                                      selectedColor:
                                          AppColors.primaryContainer,
                                    )).toList(),
                              ),
                              const SizedBox(height: 20),
                              const Text('Comments / Grievance',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _commentCtrl,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Describe your experience or issue…',
                                ),
                              ),
                              const SizedBox(height: 32),
                              ScButton(
                                label: 'Submit Feedback',
                                icon: Icons.send_rounded,
                                onPressed: _rating > 0
                                    ? () =>
                                        setState(() => _submitted = true)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                  // ── Past submissions ─────────────────────────────────────
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: _pastFeedback.map((f) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(f.facility,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Row(
                                children: List.generate(
                                  f.rating,
                                  (_) => const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: AppColors.triageYellow),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(f.comment,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(f.date,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textHint)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: f.status == 'Resolved'
                                      ? AppColors.secondaryContainer
                                      : AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(f.status,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: f.status == 'Resolved'
                                            ? AppColors.secondary
                                            : AppColors.primary)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )).toList(),
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

class _Feedback {
  final String facility, comment, status, date;
  final int rating;
  const _Feedback(this.facility, this.rating, this.comment, this.status, this.date);
}
