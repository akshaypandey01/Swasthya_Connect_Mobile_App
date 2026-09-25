import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/encounter_model.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class SymptomInputScreen extends ConsumerStatefulWidget {
  final String encounterId;
  const SymptomInputScreen({super.key, required this.encounterId});
  @override
  ConsumerState<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends ConsumerState<SymptomInputScreen> {
  final _textCtrl = TextEditingController();
  bool _isRecording = false;
  String? _audioPath;
  List<XFile> _photos = [];
  final _picker = ImagePicker();
  bool _isSaving = false;

  // Structured symptom flags for triage scoring
  final Map<String, bool> _flags = {
    'Fever': false,
    'Difficulty Breathing': false,
    'Chest Pain': false,
    'Unconscious / Unresponsive': false,
    'Bleeding': false,
    'Severe Pain': false,
    'Vomiting': false,
    'Diarrhoea': false,
    'Rash / Skin issue': false,
    'Swelling': false,
  };

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    // Audio recording temporarily disabled
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio recording feature coming soon')),
    );
  }

  Future<void> _capturePhoto() async {
    final camStatus = await Permission.camera.request();
    if (!camStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission needed')));
      return;
    }
    final img = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 70);
    if (img != null) setState(() => _photos.add(img));
  }

  Future<void> _saveAndTriage() async {
    setState(() => _isSaving = true);

    final box = Hive.box<EncounterModel>(HiveConstants.encounterBox);
    EncounterModel? encounter = box.get(widget.encounterId);

    final symptomData = {
      'text': _textCtrl.text.trim(),
      'audio_path': _audioPath,
      'photo_count': _photos.length,
      'flags': _flags,
    };

    if (encounter != null) {
      encounter.symptomInput = symptomData;
      await encounter.save();
    }

    // Pull vitals from saved encounter for triage
    final vitals = encounter?.vitals ?? {};

    setState(() => _isSaving = false);

    if (mounted) {
      context.push(AppRoutes.triageResult, extra: {
        'vitals': vitals,
        'symptoms': symptomData,
        'patientId': encounter?.patientId ?? '',
        'encounterId': widget.encounterId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Symptom Input'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Symptom flags ──────────────────────────────────────────────
                  const Text('Select Symptoms / लक्षण चुनें',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _flags.keys.map((symptom) {
                      final selected = _flags[symptom]!;
                      return FilterChip(
                        label: Text(symptom),
                        selected: selected,
                        onSelected: (v) => setState(() => _flags[symptom] = v),
                        selectedColor: AppColors.triageRed.withOpacity(0.15),
                        checkmarkColor: AppColors.triageRed,
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.triageRed
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(
                          color:
                              selected ? AppColors.triageRed : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // ── Mode 1: Free text ─────────────────────────────────────────
                  _InputModeCard(
                    icon: Icons.edit_rounded,
                    title: 'Type Symptoms',
                    titleHi: 'लक्षण टाइप करें',
                    color: AppColors.primary,
                    child: TextFormField(
                      controller: _textCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe symptoms in detail…\nविस्तार में लक्षण बताएं…',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Mode 2: Voice recording ───────────────────────────────────
                  _InputModeCard(
                    icon: Icons.mic_rounded,
                    title: 'Voice Input (Coming Soon)',
                    titleHi: 'आवाज़ इनपुट (जल्द आ रहा है)',
                    color: const Color(0xFF7B2FBE),
                    child: GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mic_off_rounded,
                              size: 36,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Feature coming soon',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Mode 3: Photo capture ─────────────────────────────────────
                  _InputModeCard(
                    icon: Icons.photo_camera_rounded,
                    title: 'Photo Capture',
                    titleHi: 'फोटो लें',
                    color: AppColors.secondary,
                    child: Column(
                      children: [
                        if (_photos.isNotEmpty)
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _photos.length,
                              itemBuilder: (_, i) => Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(File(_photos[i].path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _photos.removeAt(i)),
                                      child: const CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.black54,
                                        child: Icon(Icons.close,
                                            size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        ScButton(
                          label: 'Capture Photo',
                          icon: Icons.camera_alt_rounded,
                          color: AppColors.secondary,
                          height: 48,
                          onPressed: _capturePhoto,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // ── Bottom Button (outside scroll) ────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ScButton(
                label: 'Save & Get Triage Result →',
                isLoading: _isSaving,
                onPressed: _saveAndTriage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputModeCard extends StatelessWidget {
  final IconData icon;
  final String title, titleHi;
  final Color color;
  final Widget child;

  const _InputModeCard({
    required this.icon,
    required this.title,
    required this.titleHi,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: color)),
                    Text('($titleHi)',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
