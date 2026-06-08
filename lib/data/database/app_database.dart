import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Відносні імпорти моделей
import '../models/irp_plan.dart';
import '../models/vital_signs.dart';

part 'app_database.g.dart';

// --- КОНВЕРТЕРИ ТИПІВ ДЛЯ СКЛАДНИХ ОБ'ЄКТІВ ---

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) => List<String>.from(jsonDecode(fromDb) as List);
  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class IrpPlanConverter extends TypeConverter<IrpPlan, String> {
  const IrpPlanConverter();
  @override
  IrpPlan fromSql(String fromDb) => IrpPlan.fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  @override
  String toSql(IrpPlan value) => jsonEncode(value.toJson());
}

class VitalSignsConverter extends TypeConverter<VitalSigns, String> {
  const VitalSignsConverter();
  @override
  VitalSigns fromSql(String fromDb) => VitalSigns.fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  @override
  String toSql(VitalSigns value) => jsonEncode(value.toJson());
}

class StringMapConverter extends TypeConverter<Map<String, String>, String> {
  const StringMapConverter();
  @override
  Map<String, String> fromSql(String fromDb) => Map<String, String>.from(jsonDecode(fromDb) as Map);
  @override
  String toSql(Map<String, String> value) => jsonEncode(value);
}

class IntMapConverter extends TypeConverter<Map<String, int>, String> {
  const IntMapConverter();
  @override
  Map<String, int> fromSql(String fromDb) => Map<String, int>.from(jsonDecode(fromDb) as Map);
  @override
  String toSql(Map<String, int> value) => jsonEncode(value);
}

// --- ТАБЛИЦІ БАЗИ ДАНИХ ---

class PatientsTable extends Table {
  TextColumn get id => text()();
  TextColumn get nameUk => text()();
  TextColumn get nameEn => text()();
  TextColumn get age => text()();
  TextColumn get birthDate => text()();
  TextColumn get generalDiagnosisUk => text()();
  TextColumn get generalDiagnosisEn => text()();
  TextColumn get diagnosisMkh10Codes => text().map(const StringListConverter())();
  TextColumn get admissionDate => text()();
  TextColumn get irp => text().map(const IrpPlanConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

class VisitsTable extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().customConstraint('REFERENCES patients_table(id) ON DELETE CASCADE')();
  DateTimeColumn get date => dateTime()();
  TextColumn get therapeuticNote => text()();
  TextColumn get vitals => text().map(const VitalSignsConverter())();
  TextColumn get scaleResultsAtVisit => text().map(const StringMapConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

class ScaleHistoriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get patientId => text().customConstraint('REFERENCES patients_table(id) ON DELETE CASCADE')();
  DateTimeColumn get date => dateTime()();
  TextColumn get scaleId => text()();
  TextColumn get scaleNameUk => text()();
  IntColumn get totalScore => integer()();
  TextColumn get interpretationUk => text()();
  TextColumn get selectedAnswers => text().map(const IntMapConverter())();
}

class GoniometryHistoriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get patientId => text().customConstraint('REFERENCES patients_table(id) ON DELETE CASCADE')();
  TextColumn get jointNameUk => text()();
  TextColumn get movementTypeUk => text()();
  IntColumn get measuredValueDegrees => integer()();
  IntColumn get normalValueDegrees => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get conclusionUk => text()();
}

// --- КЛАС ІНІЦІАЛІЗАЦІЇ БД ---

@DriftDatabase(tables: [PatientsTable, VisitsTable, ScaleHistoriesTable, GoniometryHistoriesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 're_hab_local.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
