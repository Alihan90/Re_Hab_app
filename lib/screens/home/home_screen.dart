import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../patient/add_patient_screen.dart';
import '../patient/patient_details_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Клінічний Конструктор ІРП'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assignment_ind), text: 'Активні'),
              Tab(icon: Icon(Icons.archive), text: 'Архів (Неактивні)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPatientList(context, provider.activePatients),
            _buildPatientList(context, provider.inactivePatients),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPatientScreen()),
          ),
          icon: const Icon(Icons.person_add),
          label: const Text('Реєстрація пацієнта'),
        ),
      ),
    );
  }

  Widget _buildPatientList(BuildContext context, List<dynamic> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('Записів не виявлено.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final patient = list[index];
        final age = DateTime.now().year - patient.dateOfBirth.year;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: ListTile(
            // Оновлено іконку пацієнта на звичайний силует чоловічка
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('МКХ-10: ${patient.icdCode} • $age років\nДіагноз: ${patient.diagnosis}'),
            isThreeLine: true,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Відкриття повноцінної картки пацієнта
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
    );
  }
}
