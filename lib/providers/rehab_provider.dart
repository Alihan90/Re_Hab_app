import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../data/database/app_database.dart';
import '../data/repositories/patient_repository.dart';

class RehabProvider with ChangeNotifier {
  final PatientRepository _repository;
  List<Patient> _patients = [];
  List<PatientVisit> _currentPatientVisits = [];
  bool _isDarkMode = false;

  RehabProvider(this._repository) {
    loadPatients();
  }

  List<Patient> get patients => _patients;
  List<Patient> get activePatients => _patients.where((p) => p.isActive).toList();
  List<Patient> get inactivePatients => _patients.where((p) => !p.isActive).toList();
  List<PatientVisit> get currentPatientVisits => _currentPatientVisits;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> loadPatients() async {
    _patients = await _repository.getAllPatients();
    notifyListeners();
  }

  Future<void> addPatient({
    required String fullName,
    required String diagnosis,
    required String icdCode,
    required DateTime dateOfBirth,
  }) async {
    final companion = PatientsCompanion(
      fullName: Value(fullName),
      diagnosis: Value(diagnosis),
      icdCode: Value(icdCode),
      dateOfBirth: Value(dateOfBirth),
      isActive: const Value(true),
    );
    await _repository.insertPatient(companion);
    await loadPatients();
  }

  Future<void> completeTreatment(Patient patient) async {
    final updated = patient.copyWith(isActive: false);
    await _repository.updatePatient(updated);
    await loadPatients();
  }

  Future<void> updatePatientPlan(Patient patient, String smartGoals, String irpPlan) async {
    final updated = patient.copyWith(smartGoals: Value(smartGoals), irpPlan: Value(irpPlan));
    await _repository.updatePatient(updated);
    await loadPatients();
  }

  Future<void> loadVisits(int patientId) async {
    _currentPatientVisits = await _repository.getVisitsForPatient(patientId);
    notifyListeners();
  }

  Future<void> addVisit({
    required int patientId,
    required String notes,
    required String assessmentResults,
  }) async {
    final companion = PatientVisitsCompanion(
      patientId: Value(patientId),
      visitDate: Value(DateTime.now()),
      notes: Value(notes),
      assessmentResults: Value(assessmentResults),
    );
    await _repository.insertVisit(companion);
    await loadVisits(patientId);
  }

  Future<void> deletePatient(int id) async {
    await _repository.deletePatient(id);
    await loadPatients();
  }
}
