import '../database/app_database.dart';

abstract class PatientRepository {
  Future<List<Patient>> getAllPatients();
  Future<int> insertPatient(PatientsCompanion patient);
  Future<bool> updatePatient(Patient patient);
  Future<void> deletePatient(int id);
  Future<List<PatientVisit>> getVisitsForPatient(int patientId);
  Future<int> insertVisit(PatientVisitsCompanion visit);
}

class LocalPatientRepository implements PatientRepository {
  final AppDatabase db;
  LocalPatientRepository(this.db);

  @override
  Future<List<Patient>> getAllPatients() => db.select(db.patients).get();

  @override
  Future<int> insertPatient(PatientsCompanion patient) => db.into(db.patients).insert(patient);

  @override
  Future<bool> updatePatient(Patient patient) => db.update(db.patients).replace(patient);

  @override
  Future<void> deletePatient(int id) => (db.delete(db.patients)..where((t) => t.id.equals(id))).go();

  @override
  Future<List<PatientVisit>> getVisitsForPatient(int patientId) =>
      (db.select(db.patientVisits)..where((t) => t.patientId.equals(patientId))).get();

  @override
  Future<int> insertVisit(PatientVisitsCompanion visit) => db.into(db.patientVisits).insert(visit);
}
