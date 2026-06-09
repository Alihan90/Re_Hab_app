import 'package:flutter_test/flutter_test.dart';
import 'package:re_hab_app/services/smart_irp_engine.dart'; // Перевірте шлях імпорту
import 'package:re_hab_app/services/smart_irp_engine.dart';

void main() {
  group('Тестування Інтелектуального Двигуна SmartIrpEngine', () {
  group('SmartIrpEngine Tests', () {
    final engine = SmartIrpEngine();

    test('Автогенерація плану для неврологічного пацієнта (Stroke / I63.9)', () {
      // Використовуємо метод, який реально існує у вашому класі
    test('generatePlan should return string for known ICD code', () {
      final plan = engine.generatePlan(icdCode: 'I63.9', category: 'Неврологія');

      expect(plan, isNotNull);
      expect(plan.isNotEmpty, true);
      expect(plan, isA<String>());
    });

    test('Захисний механізм стійкості', () {
      final fallbackPlan = engine.generatePlan(icdCode: 'UNKNOWN', category: 'Загальні');

      expect(fallbackPlan, isNotNull);
    test('generatePlan should return fallback for unknown code', () {
      final plan = engine.generatePlan(icdCode: 'UNKNOWN', category: 'Загальні');
      expect(plan, isNotNull);
    });
  });
}
