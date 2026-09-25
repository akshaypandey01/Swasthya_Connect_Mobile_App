// ─────────────────────────────────────────────────────────────────────────────
// TRIAGE ENGINE — Rule-based scoring
//
// TODO: Replace this rule-based implementation with an on-device ONNX or
//       XGBoost model when the ML pipeline is ready.
//       Model input schema:  { vitals: {...}, symptom_flags: {...} }
//       Expected model output: { severity: 'green'|'yellow'|'red'|'critical',
//                                confidence: 0.0–1.0,
//                                model_version: String }
//       Load the model using onnxruntime_flutter or tflite_flutter package.
// ─────────────────────────────────────────────────────────────────────────────

enum TriageSeverity { green, yellow, red, critical }

class TriageResult {
  final TriageSeverity severity;
  final String recommendation;
  final String modelVersion;
  final double confidenceScore;
  final List<String> triggeringFactors;

  const TriageResult({
    required this.severity,
    required this.recommendation,
    required this.modelVersion,
    required this.confidenceScore,
    required this.triggeringFactors,
  });

  String get severityLabel {
    switch (severity) {
      case TriageSeverity.green: return 'Green — Stable';
      case TriageSeverity.yellow: return 'Yellow — Caution';
      case TriageSeverity.red: return 'Red — Urgent';
      case TriageSeverity.critical: return 'Critical — Emergency';
    }
  }

  String get severityLabelHi {
    switch (severity) {
      case TriageSeverity.green: return 'हरा — स्थिर';
      case TriageSeverity.yellow: return 'पीला — सतर्क रहें';
      case TriageSeverity.red: return 'लाल — तत्काल';
      case TriageSeverity.critical: return 'गंभीर — आपातकाल';
    }
  }

  String get severityString {
    switch (severity) {
      case TriageSeverity.green: return 'green';
      case TriageSeverity.yellow: return 'yellow';
      case TriageSeverity.red: return 'red';
      case TriageSeverity.critical: return 'critical';
    }
  }
}

class TriageEngine {
  // Rule-based triage scoring.
  // Score accumulates; highest matched band wins.
  static TriageResult evaluate({
    required Map<String, dynamic> vitals,
    required Map<String, dynamic> symptoms,
  }) {
    int score = 0;
    final factors = <String>[];

    final flags = Map<String, bool>.from(symptoms['flags'] ?? {});

    // ── Vitals rules ─────────────────────────────────────────────────────────

    final bpSys = (vitals['bp_systolic'] as num?)?.toInt() ?? 120;
    final bpDia = (vitals['bp_diastolic'] as num?)?.toInt() ?? 80;
    final spo2 = (vitals['spo2'] as num?)?.toDouble() ?? 98.0;
    final temp = (vitals['temperature'] as num?)?.toDouble() ?? 98.6;
    final pulse = (vitals['pulse'] as num?)?.toInt() ?? 72;

    // SpO2
    if (spo2 < 85) { score += 40; factors.add('SpO₂ critically low (<85%)'); }
    else if (spo2 < 90) { score += 25; factors.add('SpO₂ low (<90%)'); }
    else if (spo2 < 94) { score += 10; factors.add('SpO₂ borderline (<94%)'); }

    // Temperature
    if (temp >= 105) { score += 35; factors.add('Very high fever (≥105°F)'); }
    else if (temp >= 103) { score += 20; factors.add('High fever (≥103°F)'); }
    else if (temp >= 101) { score += 8; factors.add('Fever (≥101°F)'); }
    else if (temp < 96) { score += 20; factors.add('Hypothermia (<96°F)'); }

    // Blood pressure
    if (bpSys >= 180 || bpDia >= 120) { score += 30; factors.add('Hypertensive crisis (≥180/120)'); }
    else if (bpSys >= 160 || bpDia >= 100) { score += 15; factors.add('Severely elevated BP'); }
    else if (bpSys < 90) { score += 25; factors.add('Hypotension (<90 systolic)'); }

    // Pulse
    if (pulse > 150 || pulse < 40) { score += 30; factors.add('Dangerous pulse rate'); }
    else if (pulse > 120 || pulse < 55) { score += 12; factors.add('Abnormal pulse'); }

    // ── Symptom flag rules ────────────────────────────────────────────────────

    if (flags['Unconscious / Unresponsive'] == true) {
      score += 60; factors.add('Unresponsive / unconscious');
    }
    if (flags['Difficulty Breathing'] == true) {
      score += 35; factors.add('Breathing difficulty');
    }
    if (flags['Chest Pain'] == true) {
      score += 30; factors.add('Chest pain');
    }
    if (flags['Bleeding'] == true) {
      score += 25; factors.add('Active bleeding');
    }
    if (flags['Severe Pain'] == true) {
      score += 15; factors.add('Severe pain');
    }
    if (flags['Fever'] == true && score < 8) {
      score += 8; factors.add('Fever reported');
    }
    if (flags['Vomiting'] == true) { score += 5; }
    if (flags['Diarrhoea'] == true) { score += 5; }
    if (flags['Rash / Skin issue'] == true) { score += 3; }

    // ── Score → Severity band ────────────────────────────────────────────────

    TriageSeverity severity;
    String recommendation;
    double confidence;

    if (score >= 60) {
      severity = TriageSeverity.critical;
      recommendation =
          'IMMEDIATE emergency care required. Call ambulance now. Do NOT move patient without medical supervision.';
      confidence = 0.92;
    } else if (score >= 35) {
      severity = TriageSeverity.red;
      recommendation =
          'Urgent referral to nearest PHC/CHC required within 1 hour. Notify facility of incoming patient.';
      confidence = 0.85;
    } else if (score >= 15) {
      severity = TriageSeverity.yellow;
      recommendation =
          'Schedule facility visit today. Monitor vitals every 2 hours. Educate family on warning signs.';
      confidence = 0.78;
    } else {
      severity = TriageSeverity.green;
      recommendation =
          'Stable. Routine follow-up in 7 days. Provide health education and basic medicines if prescribed.';
      confidence = 0.80;
    }

    return TriageResult(
      severity: severity,
      recommendation: recommendation,
      modelVersion: 'rule-based-v1.0',
      confidenceScore: confidence,
      triggeringFactors: factors,
    );
  }
}
