import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';

class PatientDetailsScreen extends StatefulWidget {
  final RehabPatient patient;

  const PatientDetailsScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  late TextEditingController _irpPlanController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Виправлено помилку .join() — тепер просто виводимо стрічку кодів МКФ
    _irpPlanController = TextEditingController(
      text: 'Пов\'язані клінічні коди МКФ: ${widget.patient.irpPlan}\n\nРозклад реабілітаційного інтенсиву по днях:\n• День 1-5: Активація рухових стереотипів\n• День 6-10: Збільшення амплітуди рухів (ROM)',
    );
  }

  @override
  void dispose() {
    _irpPlanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.fullName),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Логіка збереження змін у провайдері
                  provider.updatePatientPlan(widget.patient.id, _irpPlanController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('💾 Індивідуальний реабілітаційний план оновлено!')),
                  );
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🩺 Клінічний діагноз: ${widget.patient.diagnosis}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('📊 Код МКХ-10: ${widget.patient.icdCode}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text('📅 Статус картки: ${widget.patient.isActive ? "Активна (В роботі)" : "В архіві"}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('📋 Індивідуальний реабілітаційний план (ІРП):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _irpPlanController,
              maxLines: 12,
              enabled: _isEditing,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: !_isEditing,
                fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
              ),
              style: const TextStyle(fontSize: 13, height: 1.4, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 20),
            if (widget.patient.isActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Завершити курс та перевести в архів'),
                  onPressed: () {
                    provider.togglePatientStatus(widget.patient.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('📦 Картку пацієнта ${widget.patient.fullName} успішно архівовано.')),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
