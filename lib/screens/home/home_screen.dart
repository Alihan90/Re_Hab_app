import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../patients/add_patient_screen.dart';
import '../patients/patient_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rehabProvider = Provider.of<RehabProvider>(context);
    // Фільтруємо лише активних пацієнтів для головного екрана
    final activePatients = rehabProvider.patients.where((p) => p.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Реабілітація: Пацієнти'),
      ),
      body: activePatients.isEmpty
          ? const Center(
              child: Text(
                'Активні картки відсутні.\nНатисніть "+", щоб створити нову.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: activePatients.length,
              itemBuilder: (context, index) {
                final patient = activePatients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(patient.fullName.isNotEmpty ? patient.fullName[0] : 'П'),
                    ),
                    title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Діагноз: ${patient.diagnosis}\nМКХ-10: ${patient.icdCode}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientDetailsScreen(patient: patient),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPatientScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
