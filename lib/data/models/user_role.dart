enum UserRole {
  patient,
  frontlineWorker;

  String get name {
    switch (this) {
      case UserRole.patient:
        return 'patient';
      case UserRole.frontlineWorker:
        return 'frontline_worker';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'frontline_worker':
        return UserRole.frontlineWorker;
      default:
        return UserRole.patient;
    }
  }
}

enum WorkerVisitType {
  fieldVisit,  // app-based
  centerVisit; // web-based

  String get label {
    switch (this) {
      case WorkerVisitType.fieldVisit:
        return 'Field Visit (App)';
      case WorkerVisitType.centerVisit:
        return 'Center Visit (Web)';
    }
  }
}
