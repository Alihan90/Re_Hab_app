import 'package:flutter_test/flutter_test.dart';
import 'package:re_hab_app/services/smart_irp_engine.dart';

void main() {
  group('Тестування Інтелектуального Двигуна SmartIrpEngine', () {
    late SmartIrpEngine engine;

    setUp(() {
      engine = SmartIrpEngine();
    });

    test('Автогенерація плану для неврологічного пацієнта (Stroke / I63.9)', () {
      final plan = engine.autoGeneratePlan(
        mkh10Codes: ['I63.9', 'G20'],
        age: '65',
        plannedDays: 10,
        goalsSmart: 'Збільшити обсяг рухів у кисті до 45 градусів за 10 днів.',
      );

      // Перевірка наявності базових кодів МКФ для неврологічного профілю
      expect(plan.mfkCodes, contains('s750'));
      expect(plan.mfkCodes, contains('b730'));
      
      // Перевірка коректності згенерованого за тривалістю розкладу
      expect(plan.daysSchedule.length, equals(10));
      
      // Перевірка наповнення розкладу першого дня вправами
      expect(plan.daysSchedule[1], isNotEmpty);
    });

    test('Захисний механізм стійкості при отриманні невідомих кодів МКХ-10', () {
      final plan = engine.autoGeneratePlan(
        mkh10Codes: ['XYZ_UNKNOWN_CODE'],
        age: '40',
        plannedDays: 5,
        goalsSmart: 'Загальна підтримка життєдіяльності.',
      );

      // Двигун не повинен впасти, а має надати дефолтний безпечний комплекс
      expect(plan.daysSchedule.length, equals(5));
      expect(plan.daysSchedule[1]!.first.title, isNotEmpty);
    });
  });
}
