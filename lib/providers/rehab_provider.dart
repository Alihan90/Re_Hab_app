import 'package:flutter/material.dart';
import '../data/models/patient.dart';
import '../data/models/patient_visit.dart';
import '../data/models/scale_assessment.dart';
import '../data/models/goniometry.dart';
import '../data/repositories/patient_repository.dart';
import '../services/smart_irp_engine.dart';
import '../services/goniometer_service.dart';
import '../services/pdf_generator_service.dart';

class RehabProvider extends ChangeNotifier {
  final PatientRepository _repository;
  final SmartIrpEngine _irpEngine = SmartIrpEngine();
  final GoniometerService _goniometerService = GoniometerService();
  final PdfGeneratorService _pdfService = PdfGeneratorService();

  List<Patient> _patients = [];
  bool _isLoading = false;
  bool _isDarkMode = false;
  String _locale = 'uk'; // 'uk' або 'en'

  RehabProvider(this._repository) {
    loadPatients();
  }

  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  String get locale => _locale;
  GoniometerService get goniometerService => _goniometerService;
  PdfGeneratorService get pdfService => _pdfService;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLocale(String lang) {
    _locale = lang;
    notifyListeners();
  }

  Future<void> loadPatients() async {
    _isLoading = true;
    notifyListeners();
    _patients = await _repository.getAllPatients();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPatient(Patient patient) async {
    await _repository.savePatient(patient);
    await loadPatients();
  }

  Future<void> deletePatient(String id) async {
    await _repository.deletePatient(id);
    await loadPatients();
  }

  Future<void> recordVisit(String patientId, PatientVisit visit) async {
    await _repository.addVisit(patientId, visit);
    await loadPatients();
  }

  Future<void> recordScaleHistory(String patientId, ScaleHistoryPoint point) async {
    await _repository.addScaleHistory(patientId, point);
    await loadPatients();
  }

  Future<void> recordGoniometry(String patientId, GoniometryResult result) async {
    await _repository.addGoniometryResult(patientId, result);
    await loadPatients();
  }

  Future<void> generateSmartIrpForPatient({
    required String patientId,
    required List<String> mkh10Codes,
    required String age,
    required int plannedDays,
    required String goalsSmart,
  }) async {
    final cleanPlan = _irpEngine.autoGeneratePlan(
      mkh10Codes: mkh10Codes,
      age: age,
      plannedDays: plannedDays,
      goalsSmart: goalsSmart,
    );

    final patientIndex = _patients.indexWhere((p) => p.id == patientId);
    if (patientIndex != -1) {
      final currentPatient = _patients[patientIndex];
      
      currentPatient.irp.goalsSmart = cleanPlan.goalsSmart;
      currentPatient.irp.mfkCodes = cleanPlan.mfkCodes;
      currentPatient.irp.interventionPlan = cleanPlan.interventionPlan;
      currentPatient.irp.plannedDays = cleanPlan.plannedDays;
      currentPatient.irp.daysSchedule = cleanPlan.daysSchedule;

      await _repository.savePatient(currentPatient);
      await loadPatients();
    }
  }
}
