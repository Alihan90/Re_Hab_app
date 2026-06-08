import 'package:flutter/material.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Демонстраційний клінічний список вправ для реабілітації
    final exercises = [
      {'title': 'Мобілізація кисті та пальців', 'subtitle': '3 підходи по 10 повторень', 'icon': Icons.back_hand},
      {'title': 'Тренування балансу та координації', 'subtitle': '5 хвилин на стабільній платформі', 'icon': Icons.accessibility_new},
      {'title': 'Розгинання ліктьового суглоба', 'subtitle': '2 підходи по 12 повторень', 'icon': Icons.fitness_center},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Комплекс вправ пацієнта'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final item = exercises[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(item['icon'] as IconData, color: Theme.of(context).colorScheme.primary),
              title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['subtitle'] as String),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }
}
