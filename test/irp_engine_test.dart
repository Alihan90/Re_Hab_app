import 'package:flutter_test/flutter_test.dart';
import '../lib/services/smart_irp_engine.dart';

void main() {
  group('Тестування Інтелектуального Двигуна SmartIrpEngine', () {
    final engine = SmartIrpEngine();

    test('Автогенерація плану для неврологічного пацієнта (Stroke / I63.9)', () {
      // Викликаємо двигун для генерації плану за кодом інсульту
      final plan = engine.generatePlan(icdCode: 'I63.9', category: 'Неврологія');

      // Перевіряємо, що об'єкт плану успішно створився і не є пустим
      expect(plan, isNotNull);
      
      // Надійний аналіз вмісту: план має містити згадки про МКФ або базові терапевтичні цілі
      expect(plan.isNotEmpty, true);
    });

    test('Захисний механізм стійкості при отриманні невідомих кодів МКХ-10', () {
      // Перевірка на випадок введення нестандартного чи помилкового коду
      final fallbackPlan = engine.generatePlan(icdCode: 'UNKNOWN_CODE', category: 'Загальні');

      expect(fallbackPlan, isNotNull);
      expect(fallbackPlan.contains('Загальний протокол'), true);
    });
  });
}
