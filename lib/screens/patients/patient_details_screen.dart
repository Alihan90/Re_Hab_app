import 'package:re_hab_app/models/rehab_patient.dart';
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
    // Виправлено: прибрано .join(), оскільки mfkCodes - це String
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
                  provider.updatePatientPlan(widget.patient.id, _irpPlanController.text);
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
          children: [
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
