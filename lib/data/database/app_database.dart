import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Таблиця користувачів (лікарів/реабілітологів) для багатокористувацького режиму
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().customConstraint('UNIQUE')();
  TextColumn get passwordHash => text()();
  TextColumn get fullName => text()();
  TextColumn get role => text().withDefault(const Constant('Therapist'))(); // Наприклад: Therapist, Admin
}

/// Модернізована таблиця пацієнтів із клінічними полями
class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()();
  TextColumn get diagnosis => text()();
  TextColumn get icdCode => text()();
  DateTimeColumn get dateOfBirth => dateTime()();
  TextColumn get smartGoals => text().nullable()();
  TextColumn get irpPlan => text().nullable()();
  
  // Нові клінічні поля за запитом:
  TextColumn get complaints => text().nullable()();     // Скарги пацієнта
  TextColumn get expectations => text().nullable()();   // Очікування від реабілітації
  IntColumn get treatmentDays => integer().withDefault(const Constant(10))(); // Кількість днів ІРП
  TextColumn get status => text().withDefault(const Constant('Active'))();     // Active або Archived
  
  // Зв'язок з користувачем, який створив або веде картку
  IntColumn get createdByUserId => integer().nullable().references(Users, #id)();
}

/// Таблиця для збереження проведених тестувань за шкалами (Динаміка пацієнта)
class PatientTests extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get scaleId => text()();          // Ідентифікатор шкали (напр. 'bbs', 'mas')
  TextColumn get scaleName => text()();        // Назва шкали для швидкого виведення
  RealColumn get totalScore => real()();       // Отриманий бал
  TextColumn get interpretation => text()();   // Автоматична клінічна інтерпретація результату
  DateTimeColumn get testDate => dateTime()(); // Дата проведення тесту
  IntColumn get conductedByUserId => integer().nullable().references(Users, #id)(); // Хто проводив
}

/// Таблиця для збереження історії вимірювань гоніометрії
class GoniometryMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get jointName => text()();        // Назва суглоба (Колінний, Ліктьовий тощо)
  TextColumn get movementType => text()();     // Тип руху (Згинання, Розгинання)
  TextColumn get side => text()();             // Сторона (Права, Ліва)
  RealColumn get measuredAngle => real()();    // Виміряний кут у градусах
  RealColumn get deficitDegrees => real()();   // Розрахований дефіцит відносно норми
  DateTimeColumn get measurementDate => dateTime()(); // Дата вимірювання
  IntColumn get conductedByUserId => integer().nullable().references(Users, #id)(); // Хто вимірював
}

@DriftDatabase(tables: [Users, Patients, PatientTests, GoniometryMeasurements])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Збільшуємо версію схеми, оскільки структура розширилась

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Автоматично створюємо нові таблиці та додаємо колонки, якщо оновлюємося з версії 1
          await m.createTable(users);
          await m.addColumn(patients, patients.complaints);
          await m.addColumn(patients, patients.expectations);
          await m.addColumn(patients, patients.treatmentDays);
          await m.addColumn(patients, patients.status);
          await m.addColumn(patients, patients.createdByUserId);
          await m.createTable(patientTests);
          await m.createTable(goniometryMeasurements);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'rehab_app_secure.db'));
    return NativeDatabase.createInBackground(file);
  });
}
