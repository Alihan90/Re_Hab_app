import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../../data/models/patient.dart';
import '../../data/models/irp_plan.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({Key? key}) : super(key: key);

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _searchQuery = "";

  void _showAddPatientDialog(BuildContext context, RehabProvider provider) {
    final nameUkController = TextEditingController();
    final nameEnController = TextEditingController();
    final ageController = TextEditingController();
    final diagnosisUkController = TextEditingController();
    final diagnosisEnController = TextEditingController();
    final mkhController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(provider.locale == 'uk' ? 'Нова картка пацієнта' : 'New Patient Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameUkController, decoration: const InputDecoration(labelText: 'ПІБ (Укр)')),
              TextField(controller: nameEnController, decoration: const InputDecoration(labelText: 'Full Name (Eng)')),
              TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Вік / Age'), keyboardType: TextInputType.number),
              TextField(controller: diagnosisUkController, decoration: const InputDecoration(labelText: 'Клінічний діагноз (Укр)')),
              TextField(controller: diagnosisEnController, decoration: const InputDecoration(labelText: 'Clinical Diagnosis (Eng)')),
              TextField(controller: mkhController, decoration: const InputDecoration(labelText: 'Коди МКХ-10 (через кому), напр: I63.9, M50')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(provider.locale == 'uk' ? 'Скасувати' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameUkController.text.isEmpty) return;
              
              final codes = mkhController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              
              final newPatient = Patient(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                nameUk: nameUkController.text,
                nameEn: nameEnController.text.isEmpty ? nameUkController.text : nameEnController.text,
                age: ageController.text,
                birthDate: "01.01.1980",
                generalDiagnosisUk: diagnosisUkController.text,
                generalDiagnosisEn: diagnosisEnController.text,
                diagnosisMkh10Codes: codes,
                admissionDate: DateTime.now().toLocal().toString().split(' ')[0],
                irp: IrpPlan(),
              );

              provider.addPatient(newPatient);
              Navigator.of(ctx).pop();
            },
            child: Text(provider.locale == 'uk' ? 'Зберегти' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);
    final isUk = provider.locale == 'uk';

    final filteredPatients = provider.patients.where((p) {
      final searchLower = _searchQuery.toLowerCase();
      return p.nameUk.toLowerCase().contains(searchLower) || 
             p.nameEn.toLowerCase().contains(searchLower) ||
             p.diagnosisMkh10Codes.any((c) => c.toLowerCase().contains(searchLower));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isUk ? 'Реєстр пацієнтів' : 'Patient Registry'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                labelText: isUk ? 'Пошук за ПІБ або МКХ-10' : 'Search by name or ICD-10',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPatients.isEmpty
                    ? Center(child: Text(isUk ? 'Пацієнтів не знайдено' : 'No patients found'))
                    : ListView.builder(
                        itemCount: filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = filteredPatients[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 3,
                            child: ListTile(
                              leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.person, color: Colors.white)),
                              title: Text(isUk ? patient.nameUk : patient.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${isUk ? 'Діагноз' : 'Diag'}: ${isUk ? patient.generalDiagnosisUk : patient.generalDiagnosisEn}\nМКХ-10: ${patient.diagnosisMkh10Codes.join(', ')}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => provider.deletePatient(patient.id),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showAddPatientDialog(context, provider),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
