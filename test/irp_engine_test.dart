import 'package:flutter_test/flutter_test.dart';
import 'package:re_hab_app/services/smart_irp_engine.dart';

void main() {
  group('SmartIrpEngine Tests', () {
    final engine = SmartIrpEngine();

    test('generatePlan should return string for known ICD code', () {
      final plan = engine.generatePlan(icdCode: 'I63.9', category: 'Неврологія');
      expect(plan, isNotNull);
      expect(plan, isA<String>());
    });

    test('generatePlan should return fallback for unknown code', () {
      final plan = engine.generatePlan(icdCode: 'UNKNOWN', category: 'Загальні');
      expect(plan, isNotNull);
    });
  });
}
