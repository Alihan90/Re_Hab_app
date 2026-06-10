import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';

class AssessmentHistoryScreen extends StatelessWidget {
  final String patientId;

  const AssessmentHistoryScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Історія тестувань')),
      body: Consumer<RehabProvider>(
        builder: (context, provider, child) {
          final history = provider.getResultsForPatient(patientId);
          
          if (history.isEmpty) {
            return const Center(child: Text('Тестів ще не проводилося'));
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final result = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(result.scaleId.toUpperCase()), // Тут можна дістати назву за ID
                  subtitle: Text(result.date.toString().substring(0, 16)),
                  trailing: Text(
                    '${result.calculatedIndex.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
