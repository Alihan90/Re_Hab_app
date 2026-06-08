import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()(); // Один ПІБ для будь-якої розкладки клавіатури
  TextColumn get diagnosis => text()(); // Один опис діагнозу
  TextColumn get icdCode => text()();   // Код МКХ-10 для ручного введення
  DateTimeColumn get dateOfBirth => dateTime()(); // Повна дата народження
  BoolColumn get isActive => boolean().withDefault(const Constant(true))(); // Статус для Архіву
  TextColumn get smartGoals => text().nullable()();
  TextColumn get irpPlan => text().nullable()();
}

class PatientVisits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get visitDate => dateTime()();
  TextColumn get notes => text()();
  TextColumn get assessmentResults => text()(); // Результати тестування за клінічними шкалами
}

@DriftDatabase(tables: [Patients, PatientVisits])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'rehab_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
