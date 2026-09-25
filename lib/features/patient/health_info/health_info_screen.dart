import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';

class HealthInfoScreen extends StatelessWidget {
  const HealthInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Health Info & Services'),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Nearby Facilities'),
                Tab(text: 'Health Tips'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _FacilitiesList(),
                  _HealthTipsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FacilitiesList extends StatelessWidget {
  final _facilities = const [
    _Facility('PHC Rampur', 'Primary Health Centre', '1.2 km',
        ['OPD', 'Maternity', 'Vaccinations']),
    _Facility('CHC Bijnor', 'Community Health Centre', '5.8 km',
        ['Surgery', 'Lab', 'Emergency', 'Dental']),
    _Facility('Jan Aushadhi Store', 'Generic Medicine Store', '0.8 km',
        ['Generic medicines at low cost']),
    _Facility('ASHA Worker Contact', 'Accredited Social Health Activist', '0 km',
        ['Home visits', 'Referrals', 'Counselling']),
  ];

  const _FacilitiesList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _facilities.map((f) => Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                const Icon(Icons.local_hospital_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(f.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                Text(f.distance,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(f.type,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: f.services.map((s) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.primary)),
              )).toList(),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _Facility {
  final String name, type, distance;
  final List<String> services;
  const _Facility(this.name, this.type, this.distance, this.services);
}

class _HealthTipsList extends StatelessWidget {
  final _tips = const [
    _Tip('Drink Clean Water', 'Boil or filter water before drinking to prevent diarrhoea and cholera.', Icons.water_drop_rounded, AppColors.primary),
    _Tip('Hand Hygiene', 'Wash hands with soap for 20 seconds before eating and after toilet use.', Icons.clean_hands_rounded, AppColors.secondary),
    _Tip('Balanced Diet', 'Eat seasonal fruits, vegetables, pulses and milk daily for good nutrition.', Icons.restaurant_rounded, Color(0xFF43A047)),
    _Tip('ORS for Diarrhoea', 'Give ORS (oral rehydration solution) to children immediately if diarrhoea starts.', Icons.local_pharmacy_rounded, Color(0xFF0288D1)),
    _Tip('Breast Feeding', 'Breastfeed exclusively for 6 months. Start solid food after 6 months.', Icons.child_care_rounded, Color(0xFFE91E63)),
    _Tip('Complete Vaccinations', 'Ensure your child follows the national immunization schedule on time.', Icons.vaccines_rounded, Color(0xFF7B2FBE)),
  ];

  const _HealthTipsList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _tips.map((t) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.color.withOpacity(0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: t.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(t.icon, color: t.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: t.color)),
                  const SizedBox(height: 4),
                  Text(t.body,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _Tip {
  final String title, body;
  final IconData icon;
  final Color color;
  const _Tip(this.title, this.body, this.icon, this.color);
}
