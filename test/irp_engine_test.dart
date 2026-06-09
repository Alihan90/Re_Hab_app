import 'package:flutter_test/flutter_test.dart';
import 'package:re_hab_app/services/smart_irp_engine.dart';

void main() {
  group('Тестування Інтелектуального Двигуна SmartIrpEngine', () {
    late SmartIrpEngine engine;

    setUp(() {
      engine = SmartIrpEngine();
    });

    test('Автогенерація плану для неврологічного пацієнта (Stroke / I63.9)', () {
      final plan = engine.generatePlan(icdCode: 'I63.9', category: 'Неврологія');

      // Перевіряємо, що повернулися не порожні рядки з логікою
      expect(plan.goalsSmart.isNotEmpty, true);
      expect(plan.mfkCodes.isNotEmpty, true);
      expect(plan.daysSchedule.isNotEmpty, true);

      // Перевіряємо наявність специфічного контенту для інсульту
      expect(plan.goalsSmart.contains('Берга'), true);
      expect(plan.mfkCodes.contains('b710'), true);
    });

    test('Захисний механізм стійкості при отриманні невідомих кодів МКХ-10', () {
      final plan = engine.generatePlan(icdCode: 'UNKNOWN_CODE', category: 'Загальні');

      expect(plan.goalsSmart.isNotEmpty, true);
      expect(plan.mfkCodes.isNotEmpty, true);
      expect(plan.goalsSmart.contains('ВАШ'), true); // Дефолтний ортопедичний план
    });
  });
}
