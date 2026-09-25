import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';
import '../../shared/widgets/sc_text_field.dart';

class UploadRecordsScreen extends StatefulWidget {
  final String patientId;
  const UploadRecordsScreen({super.key, required this.patientId});
  @override
  State<UploadRecordsScreen> createState() => _UploadRecordsScreenState();
}

class _UploadRecordsScreenState extends State<UploadRecordsScreen> {
  final _picker = ImagePicker();
  final List<XFile> _capturedImages = [];
  final _ocrResultCtrl = TextEditingController();
  bool _isProcessing = false;
  bool _ocrDone = false;

  @override
  void dispose() {
    _ocrResultCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureDocument() async {
    final camStatus = await Permission.camera.request();
    if (!camStatus.isGranted) return;
    final img = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 85);
    if (img != null) {
      setState(() {
        _capturedImages.add(img);
        _ocrDone = false;
      });
    }
  }

  Future<void> _runOcr() async {
    if (_capturedImages.isEmpty) return;
    setState(() => _isProcessing = true);

    // TODO: Replace with real OCR call (Google ML Kit or Tesseract)
    // For now, simulate OCR with a delay + placeholder extracted text
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _ocrDone = true;
      _ocrResultCtrl.text =
          'Patient: [extracted name]\nDiagnosis: [extracted diagnosis]\nMedicines: [extracted medicines]\nDate: [extracted date]\n\n[Edit extracted text as needed before saving]';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Upload Records'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.document_scanner_rounded,
                      color: AppColors.primary, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Capture paper records. OCR will extract text for review.',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Captured images
            if (_capturedImages.isNotEmpty) ...[
              const Text('Captured Documents',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _capturedImages.length,
                  itemBuilder: (_, i) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 100,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                          image: DecorationImage(
                            image: FileImage(
                                File(_capturedImages[i].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 14,
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _capturedImages.removeAt(i)),
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
              const SizedBox(height: 16),
            ],

            ScButton(
              label: 'Capture Document',
              icon: Icons.camera_alt_rounded,
              color: AppColors.primary,
              onPressed: _captureDocument,
            ),
            const SizedBox(height: 12),

            if (_capturedImages.isNotEmpty && !_ocrDone)
              ScButton(
                label: 'Extract Text (OCR)',
                icon: Icons.document_scanner_rounded,
                color: const Color(0xFF7B2FBE),
                isLoading: _isProcessing,
                onPressed: _runOcr,
              ),

            if (_ocrDone) ...[
              const SizedBox(height: 24),
              const Text('Extracted Text (Edit if needed)',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ocrResultCtrl,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'OCR extracted text appears here…',
                ),
              ),
              const SizedBox(height: 24),
              ScButton(
                label: 'Save to Patient Record',
                icon: Icons.save_rounded,
                color: AppColors.secondary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Record saved to patient profile')),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
