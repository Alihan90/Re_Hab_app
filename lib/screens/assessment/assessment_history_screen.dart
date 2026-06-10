import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';

class AssessmentHistoryScreen extends StatelessWidget {
  final String patientId;

  const AssessmentHistoryScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Історія тестувань'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // Тут буде логіка експорту в PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Експорт у PDF розпочато...')),
              );
            },
          ),
        ],
      ),
      body: Consumer<RehabProvider>(
        builder: (context, provider, child) {
          final history = provider.getResultsForPatient(patientId);
          
          if (history.isEmpty) return const Center(child: Text('Тестів ще не проводилося'));

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final result = history[index];
              return Card(
                child: ListTile(
                  title: Text('Шкала: ${result.scaleId.toUpperCase()}'),
                  subtitle: Text('Дата: ${result.date.toString().substring(0, 16)}'),
                  trailing: Text('${result.calculatedIndex.toStringAsFixed(1)}%'),
                  onLongPress: () {
                    // Видалення запису
                    provider.deleteResult(result.id); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Запис видалено')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
