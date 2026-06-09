import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../../data/database/app_database.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Patient patient;

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
    _irpPlanController = TextEditingController(
      text: widget.patient.irpPlan ?? 'Пов\'язані коди МКФ: не вказано\n\nРозклад реабілітації по днях:\n• День 1-5: Активація рухових стереотипів\n• День 6-10: Збільшення амплітуди рухів (ROM)',
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
                  // Передаємо 3 обов'язкові параметри: пацієнт, цілі (smartGoals) та план (irpPlan)
                  provider.updatePatientPlan(
                    widget.patient, 
                    widget.patient.smartGoals ?? '', 
                    _irpPlanController.text
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('💾 Реабілітаційний план оновлено!')),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🩺 Клінічний діагноз: ${widget.patient.diagnosis}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('📊 Код МКХ-10: ${widget.patient.icdCode}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('📋 Програма реабілітації (ІРП):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _irpPlanController,
              maxLines: 10,
              enabled: _isEditing,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }
}
