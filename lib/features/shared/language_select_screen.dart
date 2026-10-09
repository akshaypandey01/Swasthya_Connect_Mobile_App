import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../shared/widgets/sc_button.dart';

class LanguageSelectScreen extends ConsumerStatefulWidget {
  const LanguageSelectScreen({super.key});
  @override
  ConsumerState<LanguageSelectScreen> createState() =>
      _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends ConsumerState<LanguageSelectScreen> {
  String _selected = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English', 'native': 'English'},
    {'code': 'hi', 'label': 'Hindi', 'native': 'हिंदी'},
  ];

  @override
  void initState() {
    super.initState();
    _selected = ref.read(localeProvider).languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/swasthya_connect_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('SwasthyaConnect',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              const SizedBox(height: 4),
              const Text('By HealthSync1 | Team ID: 165109',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              const Text('Select Language / भाषा चुनें',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 48),
              ...(_languages.map((lang) => _LanguageTile(
                    code: lang['code']!,
                    label: lang['label']!,
                    native: lang['native']!,
                    isSelected: _selected == lang['code'],
                    onTap: () => setState(() => _selected = lang['code']!),
                  ))),
              const Spacer(),
              ScButton(
                label: 'Continue / आगे बढ़ें',
                onPressed: () async {
                  await ref
                      .read(localeProvider.notifier)
                      .setLocale(Locale(_selected));
                  if (context.mounted) context.go('/role-select');
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code, label, native;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.code,
    required this.label,
    required this.native,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.shadow, blurRadius: 8)]
              : [],
        ),
        child: Row(
          children: [
            Text(code == 'hi' ? '🇮🇳' : '🌐',
                style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary)),
                Text(native,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 26),
          ],
        ),
      ),
    );
  }
}
