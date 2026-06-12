import 'package:flutter_test/flutter_test.dart';
// 1. ПРАВИЛЬНИЙ ІМПОРТ: вказуємо точний шлях до твого файлу
import 'package:re_hab_app/services/smart_irp_engine.dart';

void main() {
  group('Тести двигуна генерації ІРП (SmartIrpEngine)', () {
    
    test('Генерація плану для неврологічної реабілітації', () {
      // Примітка: Якщо всередині файлу сам клас називається IrpEngine (а не SmartIrpEngine),
      // просто зміни назву нижче на: final engine = IrpEngine();
      final engine = SmartIrpEngine(); 
      final plan = engine.generatePlan(
        category: 'Неврологія', 
        scaleScores: {'bbs': 45},
      );

      expect(plan.isNotEmpty, true);
      expect(plan.contains('Цілі SMART'), true); 
      expect(plan.contains('Коди МКФ'), true);
      expect(plan.contains('Берга'), true);
      expect(plan.contains('b710'), true);
    });

    test('Генерація плану для ортопедичної реабілітації', () {
      final engine = SmartIrpEngine();
      final plan = engine.generatePlan(
        category: 'Ортопедія', 
        scaleScores: {'vas': 6},
      );

      expect(plan.isNotEmpty, true);
      expect(plan.contains('Коди МКФ'), true);
      expect(plan.contains('ВАШ'), true);
    });
    
  });
}
