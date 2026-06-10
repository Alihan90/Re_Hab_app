import 'package:flutter/material.dart';
import '../../data/scales_presets.dart';
import 'interactive_assessment_screen.dart';

class AssessmentListScreen extends StatelessWidget {
  final String patientId;

  const AssessmentListScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    // Групуємо шкали за категоріями
    final categories = ScalesPresets.allScales.map((e) => e.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Вибір шкали оцінки')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final scalesInCategory = ScalesPresets.allScales.where((s) => s.category == category).toList();

          return ExpansionTile(
            title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: scalesInCategory.map((scale) => ListTile(
              title: Text(scale.name),
              subtitle: Text(scale.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InteractiveAssessmentScreen(scale: scale, patientId: patientId),
                  ),
                );
              },
            )).toList(),
          );
        },
      ),
    );
  }
}
