import 'package:flutter_test/flutter_test.dart';
// Перевір цей імпорт відповідно до твоєї структури папок:
import 'package:re_hab_app/core/irp_engine.dart'; 

void main() {
  group('Тести двигуна генерації ІРП (IrpEngine)', () {
    
    test('Генерація плану для неврологічної реабілітації', () {
      // Ініціалізація твого енджину (підстав свій метод виклику, якщо він статичний)
      final engine = IrpEngine();
      final plan = engine.generatePlan(
        category: 'Неврологія', 
        scaleScores: {'bbs': 45}, // Наприклад, Шкала Берга
      );

      // ВИПРАВЛЕННЯ: plan є String, перевіряємо вміст напряму
      expect(plan.isNotEmpty, true);
      expect(plan.contains('Цілі SMART'), true); 
      expect(plan.contains('Коди МКФ'), true);
      
      // Перевірка наявності конкретних маркерів у згенерованому тексті
      expect(plan.contains('Берга'), true);
      expect(plan.contains('b710'), true);
    });

    test('Генерація плану для ортопедичної реабілітації', () {
      final engine = IrpEngine();
      final plan = engine.generatePlan(
        category: 'Ортопедія', 
        scaleScores: {'vas': 6}, // Візуально-аналогова шкала болю
      );

      // ВИПРАВЛЕННЯ: перевірка текстового виводу для ортопедії
      expect(plan.isNotEmpty, true);
      expect(plan.contains('Коди МКФ'), true);
      expect(plan.contains('ВАШ'), true); // Дефолтний ортопедичний план
    });
    
  });
}
