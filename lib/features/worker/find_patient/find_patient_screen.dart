import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/patient_model.dart';
import '../../shared/widgets/sc_app_bar.dart';

class FindPatientScreen extends ConsumerStatefulWidget {
  const FindPatientScreen({super.key});
  @override
  ConsumerState<FindPatientScreen> createState() => _FindPatientScreenState();
}

class _FindPatientScreenState extends ConsumerState<FindPatientScreen> {
  final _searchCtrl = TextEditingController();
  List<PatientModel> _results = [];
  bool _isSearching = false;
  String _searchMode = 'name'; // name | abha | phone | temp

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);

    // Search local Hive first
    final box = Hive.box<PatientModel>(HiveConstants.patientBox);
    List<PatientModel> local = box.values.where((p) {
      switch (_searchMode) {
        case 'abha': return p.abhaId?.contains(query) ?? false;
        case 'phone': return p.phone.contains(query);
        case 'temp': return p.tempId?.contains(query) ?? false;
        default: return p.name.toLowerCase().contains(query.toLowerCase());
      }
    }).toList();

    // Also query Firestore
    try {
      final field = _searchMode == 'abha' ? 'abha_id'
          : _searchMode == 'phone' ? 'phone'
          : _searchMode == 'temp' ? 'temp_id'
          : 'name';
      final snap = await FirebaseFirestore.instance
          .collection('patients')
          .where(field, isGreaterThanOrEqualTo: query)
          .where(field, isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();
      final remote = snap.docs
          .map((d) => PatientModel.fromFirestore(d.data()))
          .toList();
      // Merge, deduplicate by patientId
      final ids = local.map((p) => p.patientId).toSet();
      for (final r in remote) {
        if (!ids.contains(r.patientId)) local.add(r);
      }
    } catch (_) {}

    setState(() {
      _results = local;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Find Patient'),
      body: Column(
        children: [
          // Search type selector
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Search by',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Chip('Name', 'name'),
                      _Chip('ABHA ID', 'abha'),
                      _Chip('Phone', 'phone'),
                      _Chip('Temp ID', 'temp'),
                    ].map((c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(c.label),
                            selected: _searchMode == c.value,
                            onSelected: (_) =>
                                setState(() => _searchMode = c.value),
                            selectedColor: AppColors.primaryContainer,
                            checkmarkColor: AppColors.primary,
                          ),
                        )).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _searchCtrl,
                  onChanged: _search,
                  decoration: InputDecoration(
                    hintText: 'Search patient…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _results = []);
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_search_rounded,
                                size: 64, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text(
                              _searchCtrl.text.isEmpty
                                  ? 'Enter name, ABHA ID, phone or Temp ID'
                                  : 'No patients found',
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (_, i) =>
                            _PatientResultTile(_results[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _Chip {
  final String label, value;
  const _Chip(this.label, this.value);
}

class _PatientResultTile extends StatelessWidget {
  final PatientModel patient;
  const _PatientResultTile(this.patient);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryContainer,
          child: Text(
            patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(patient.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${patient.gender} • ${patient.dob}',
                style: const TextStyle(fontSize: 12)),
            Text(patient.displayId,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.primary)),
            if (patient.syncStatus == 'pending')
              const Text('⚠ Offline record',
                  style: TextStyle(fontSize: 11, color: AppColors.syncPending)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: AppColors.textHint),
        onTap: () => context.push(
          AppRoutes.workerPatientProfile,
          extra: {'patientId': patient.patientId},
        ),
      ),
    );
  }
}
