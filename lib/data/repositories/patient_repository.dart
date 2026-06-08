import 'package:drift/drift.dart';
// Відносні імпорту моделей та бази даних
import '../database/app_database.dart';
import '../models/patient.dart';
import '../models/irp_plan.dart';
import '../models/patient_visit.dart';
import '../models/scale_assessment.dart';
import '../models/goniometry.dart';

abstract class PatientRepository {
  Future<void> savePatient(Patient patient);
  Future<List<Patient>> getAllPatients();
  Future<Patient?> getPatientById(String id);
  Future<void> deletePatient(String id);
  Future<void> addVisit(String patientId, PatientVisit visit);
  Future<void> addScaleHistory(String patientId, ScaleHistoryPoint point);
  Future<void> addGoniometryResult(String patientId, GoniometryResult result);
}

class LocalPatientRepository implements PatientRepository {
  final AppDatabase _db;

  LocalPatientRepository(this._db);

  @override
  Future<void> savePatient(Patient patient) async {
    await _db.into(_db.patientsTable).insertOnConflictUpdate(
          PatientsTableCompanion(
            id: Value(patient.id),
            nameUk: Value(patient.nameUk),
            nameEn: Value(patient.nameEn),
            age: Value(patient.age),
            birthDate: Value(patient.birthDate),
            generalDiagnosisUk: Value(patient.generalDiagnosisUk),
            generalDiagnosisEn: Value(patient.generalDiagnosisEn),
            diagnosisMkh10Codes: Value(patient.diagnosisMkh10Codes),
            admissionDate: Value(patient.admissionDate),
            irp: Value(patient.irp),
          ),
        );
  }

  @override
  Future<List<Patient>> getAllPatients() async {
    final patientsData = await _db.select(_db.patientsTable).get();
    final List<Patient> patientsList = [];

    for (var patientRow in patientsData) {
      final fullPatient = await getPatientById(patientRow.id);
      if (fullPatient != null) {
        patientsList.add(fullPatient);
      }
    }
    return patientsList;
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    final patientQuery = _db.select(_db.patientsTable)..where((t) => t.id.equals(id));
    final patientRow = await patientQuery.getSingleOrNull();

    if (patientRow == null) return null;

    final visitsRows = await (_db.select(_db.visitsTable)..where((t) => t.patientId.equals(id))).get();
    final scalesRows = await (_db.select(_db.scaleHistoriesTable)..where((t) => t.patientId.equals(id))).get();
    final gonioRows = await (_db.select(_db.goniometryHistoriesTable)..where((t) => t.patientId.equals(id))).get();

    return Patient(
      id: patientRow.id,
      nameUk: patientRow.nameUk,
      nameEn: patientRow.nameEn,
      age: patientRow.age,
      birthDate: patientRow.birthDate,
      generalDiagnosisUk: patientRow.generalDiagnosisUk,
      generalDiagnosisEn: patientRow.generalDiagnosisEn,
      diagnosisMkh10Codes: patientRow.diagnosisMkh10Codes,
      admissionDate: patientRow.admissionDate,
      irp: patientRow.irp,
      visits: visitsRows
          .map((v) => PatientVisit(
                id: v.id,
                date: v.date,
                therapeuticNote: v.therapeuticNote,
                vitals: v.vitals,
                scaleResultsAtVisit: v.scaleResultsAtVisit,
              ))
          .toList(),
      scaleHistory: scalesRows
          .map((s) => ScaleHistoryPoint(
                date: s.date,
                scaleId: s.scaleId,
                scaleNameUk: s.scaleNameUk,
                totalScore: s.totalScore,
                interpretationUk: s.interpretationUk,
                selectedAnswers: s.selectedAnswers,
              ))
          .toList(),
      goniometryHistory: gonioRows
          .map((g) => GoniometryResult(
                jointNameUk: g.jointNameUk,
                movementTypeUk: g.movementTypeUk,
                measuredValueDegrees: g.measuredValueDegrees,
                normalValueDegrees: g.normalValueDegrees,
                date: g.date,
                conclusionUk: g.conclusionUk,
              ))
          .toList(),
    );
  }

  @override
  Future<void> deletePatient(String id) async {
    await (_db.delete(_db.patientsTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> addVisit(String patientId, PatientVisit visit) async {
    await _db.into(_db.visitsTable).insert(
          VisitsTableCompanion(
            id: Value(visit.id),
            patientId: Value(patientId),
            date: Value(visit.date),
            therapeuticNote: Value(visit.therapeuticNote),
            vitals: Value(visit.vitals),
            scaleResultsAtVisit: Value(visit.scaleResultsAtVisit),
          ),
        );
  }

  @override
  Future<void> addScaleHistory(String patientId, ScaleHistoryPoint point) async {
    await _db.into(_db.scaleHistoriesTable).insert(
          ScaleHistoriesTableCompanion.insert(
            patientId: patientId,
            date: point.date,
            scaleId: point.scaleId,
            scaleNameUk: point.scaleNameUk,
            totalScore: point.totalScore,
            interpretationUk: point.interpretationUk,
            selectedAnswers: point.selectedAnswers,
          ),
        );
  }

  @override
  Future<void> addGoniometryResult(String patientId, GoniometryResult result) async {
    await _db.into(_db.goniometryHistoriesTable).insert(
          GoniometryHistoriesTableCompanion.insert(
            patientId: patientId,
            jointNameUk: result.jointNameUk,
            movementTypeUk: result.movementTypeUk,
            measuredValueDegrees: result.measuredValueDegrees,
            normalValueDegrees: result.normalValueDegrees,
            date: result.date,
            conclusionUk: result.conclusionUk,
          ),
        );
  }
}
