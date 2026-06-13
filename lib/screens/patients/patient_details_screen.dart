import 'package:flutter/material.dart';

class PatientDetailsScreen extends StatelessWidget {
  final dynamic patient; // Приймає об'єкт пацієнта з RehabProvider

  const PatientDetailsScreen({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Картка пацієнта'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основна інформація
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        patient.fullName.isNotEmpty ? patient.fullName[0] : 'П',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.fullName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: patient.isActive ? Colors.green.shade100 : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              patient.isActive ? 'Активна картка' : 'Архів',
                              style: TextStyle(
                                fontSize: 12,
                                color: patient.isActive ? Colors.green.shade800 : Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Медичні дані
            const Text(
              'Клінічний статус',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Діагноз:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.diagnosis,
                      style: const TextStyle(fontSize: 15, height: 1.3),
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Код МКХ-10:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.icdCode,
                      style: const TextStyle(fontSize: 16, letterSpacing: 1.1, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
