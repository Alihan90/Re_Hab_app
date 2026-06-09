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
  late TextEditingController _smartGoalsController;
  late TextEditingController _irpPlanController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _smartGoalsController = TextEditingController(text: widget.patient.smartGoals ?? '');
    _irpPlanController = TextEditingController(
      text: widget.patient.irpPlan ?? 
          'Пов\'язані коди МКФ: не визначено\n\n'
          'Розклад реабілітації по днях:\n'
          '• День 1-5: Активація рухових стереотипів, зниження больового синдрому.\n'
          '• День 6-10: Збільшення амплітуди рухів (ROM), механотерапія.',
    );
  }

  @override
  void dispose() {
    _smartGoalsController.dispose();
    _irpPlanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Картка реабілітації'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Виправляємо помилку: передаємо 3 обов'язкові параметри (Patient, String, String)
                  provider.updatePatientPlan(
                    widget.patient,
                    _smartGoalsController.text.trim(),
                    _irpPlanController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('💾 Зміни успішно збережено в базі даних!')),
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
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.patient.fullName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text('🩺 Діагноз: ${widget.patient.diagnosis}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('📊 Класифікатор МКХ-10: ${widget.patient.icdCode}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('🎯 Реабілітаційні цілі (SMART)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _smartGoalsController,
              maxLines: 4,
              enabled: _isEditing,
              decoration: InputDecoration(
                hintText: 'Цілі за методологією SMART ще не згенеровані...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('📋 Індивідуальний реабілітаційний план (ІРП)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _irpPlanController,
              maxLines: 8,
              enabled: _isEditing,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
