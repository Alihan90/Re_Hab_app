import 'package:flutter_test/flutter_test.dart';
import 'package:re_hab_app/services/smart_irp_engine.dart';

void main() {
  group('Тести двигуна генерації ІРП (SmartIrpEngine)', () {
    
    test('Генерація плану для неврологічної реабілітації', () {
      final engine = SmartIrpEngine();
      
      // Викликаємо метод сумісності з правильними параметрами
      final plan = engine.generatePlan(
        icdCode: 'G35', // Неврологічний код (Розсіяний склероз)
        category: 'Неврологія',
      );

      // Перевіряємо структуру текстового звіту за твоїм StringBuffer
      expect(plan.isNotEmpty, true);
      expect(plan.contains('ЦІЛІ SMART:'), true); 
      expect(plan.contains('КЛІНІЧНІ ЗАСТЕРЕЖЕННЯ:'), true);
      
      // Перевіряємо, що спрацював саме неврологічний профіль генерації
      expect(plan.contains('Берга'), true);
    });

    test('Генерація плану для ортопедичної реабілітації', () {
      final engine = SmartIrpEngine();
      
      // Викликаємо метод для ортопедії
      final plan = engine.generatePlan(
        icdCode: 'M17', // Ортопедичний код (Гонартроз)
        category: 'Ортопедія',
      );

      expect(plan.isNotEmpty, true);
      expect(plan.contains('ЦІЛІ SMART:'), true);
      expect(plan.contains('ВАШ'), true); // Перевірка наявності шкали ВАШ для ортопедії
    });
    
  });
}
