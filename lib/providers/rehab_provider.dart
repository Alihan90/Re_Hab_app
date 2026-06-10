import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../data/database/app_database.dart';

class RehabProvider extends ChangeNotifier {
  final AppDatabase _db;
  List<Patient> _allPatients = [];
  
  // Для підпису документів зберігаємо ID поточного авторизованого лікаря
  int? _currentUserId;
  String _currentUserFullName = "Неавторизований спеціаліст";

  RehabProvider(this._db) {
    _listenToPatients();
  }

  // Стріми для постійного відстеження змін у базі даних
  void _listenToPatients() {
    _db.select(_db.patients).watch().listen((dynamicPatients) {
      _allPatients = dynamicPatients;
      notifyListeners();
    });
  }

  // Гетери для розділення пацієнтів на екрані вкладки списку
  List<Patient> get patients => _allPatients;
  List<Patient> get activePatients => _allPatients.where((p) => p.status == 'Active').toList();
  List<Patient> get archivedPatients => _allPatients.where((p) => p.status == 'Archived').toList();

  int? get currentUserId => _currentUserId;
  String get currentUserFullName => _currentUserFullName;

  /// Встановлення поточного активного лікаря (викликається при логіні)
  void setCurrentUser(int id, String name) {
    _currentUserId = id;
    _currentUserFullName = name;
    notifyListeners();
  }

  /// Додавання нової картки пацієнта (розширене полями скарг та очікувань)
  Future<void> addPatient({
    required String fullName,
    required String diagnosis,
    required String icdCode,
    required DateTime dateOfBirth,
    String? complaints,
    String? expectations,
    int treatmentDays = 10,
  }) async {
    await _db.into(_db.patients).insert(
          PatientsCompanion.insert(
            fullName: fullName,
            diagnosis: diagnosis,
            icdCode: icdCode,
            dateOfBirth: dateOfBirth,
            complaints: Value(complaints),
            expectations: Value(expectations),
            treatmentDays: Value(treatmentDays),
            status: const Value('Active'),
            createdByUserId: Value(_currentUserId),
          ),
        );
  }

  /// Оновлення плану реабілітації пацієнта (ідеально збігається з екраном деталей пацієнта)
  Future<void> updatePatientPlan(Patient patient, String smartGoals, String irpPlan) async {
    await (_db.update(_db.patients)..where((t) => t.id.equals(patient.id))).write(
      PatientsCompanion(
        smartGoals: Value(smartGoals),
        irpPlan: Value(irpPlan),
      ),
    );
  }

  /// Зміна клінічного статусу картки (Переведення в Архів або повернення в Активні)
  Future<void> updatePatientStatus(int patientId, String newStatus) async {
    await (_db.update(_db.patients)..where((t) => t.id.equals(patientId))).write(
      PatientsCompanion(
        status: Value(newStatus),
      ),
    );
  }

  /// Повне видалення картки з бази даних (якщо лікар підтвердив видалення)
  Future<void> deletePatientPermanently(int patientId) async {
    await (_db.delete(_db.patients)..where((t) => t.id.equals(patientId))).go();
  }

  // ==========================================
  // РОБОТА ЗІ ШКАЛАМИ ТА ОЦІНЮВАННЯМ
  // ==========================================

  /// Отримання історії тестів конкретного пацієнта для побудови графіків динаміки
  Future<List<PatientTest>> getTestsForPatient(int patientId) async {
    return await (_db.select(_db.patientTests)
          ..where((t) => t.patientId.equals(patientId))
          ..orderBy([(t) => OrderingTerm(expression: t.testDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Збереження проведеного інтерактивного тесту
  Future<void> savePatientTest({
    required int patientId,
    required String scaleId,
    required String scaleName,
    required double totalScore,
    required String interpretation,
  }) async {
    await _db.into(_db.patientTests).insert(
          PatientTestsCompanion.insert(
            patientId: patientId,
            scaleId: scaleId,
            scaleName: scaleName,
            totalScore: totalScore,
            interpretation: interpretation,
            testDate: DateTime.now(),
            conductedByUserId: Value(_currentUserId),
          ),
        );
    notifyListeners();
  }

  // ==========================================
  // РОБОТА З ГОНІОМЕТРІЄЮ
  // ==========================================

  /// Отримання історії замірів кутів суглобів для картки пацієнта
  Future<List<GoniometryMeasurement>> getGoniometryForPatient(int patientId) async {
    return await (_db.select(_db.goniometryMeasurements)
          ..where((t) => t.patientId.equals(patientId))
          ..orderBy([(t) => OrderingTerm(expression: t.measurementDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Збереження нового вимірювання суглоба
  Future<void> saveGoniometryMeasurement({
    required int patientId,
    required String jointName,
    required String movementType,
    required String side,
    required double measuredAngle,
    required double deficitDegrees,
  }) async {
    await _db.into(_db.goniometryMeasurements).insert(
          GoniometryMeasurementsCompanion.insert(
            patientId: patientId,
            jointName: jointName,
            movementType: movementType,
            side: side,
            measuredAngle: measuredAngle,
            deficitDegrees: deficitDegrees,
            measurementDate: DateTime.now(),
            conductedByUserId: Value(_currentUserId),
          ),
        );
    notifyListeners();
  }
}
