import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../../services/smart_irp_engine.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({Key? key}) : super(key: key);

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _icdCodeController = TextEditingController();
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 45));

  final SmartIrpEngine _irpEngine = SmartIrpEngine();

  @override
  void dispose() {
    _fullNameController.dispose();
    _diagnosisController.dispose();
    _icdCodeController.dispose();
    super.dispose();
  }

  void _showIcd10Picker() {
    String searchQuery = '';
    final allCodes = _irpEngine.icd10Database;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final filteredCodes = allCodes.entries.where((entry) {
              final searchLower = searchQuery.toLowerCase();
              return entry.key.toLowerCase().contains(searchLower) || entry.value.toLowerCase().contains(searchLower);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 16, right: 16),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Клінічний класифікатор МКХ-10', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Пошук за кодом або назвою...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) {
                        setModalState(() => searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCodes.length,
                        itemBuilder: (ctx, index) {
                          final item = filteredCodes[index];
                          return ListTile(
                            title: Text('${item.key} - ${item.value}'),
                            onTap: () {
                              setState(() {
                                _icdCodeController.text = item.key;
                                _diagnosisController.text = item.value;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Нова медична картка')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'ПІБ пацієнта', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Вкажіть ПІБ' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _icdCodeController,
                      decoration: const InputDecoration(labelText: 'Код МКХ-10', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(onPressed: _showIcd10Picker, child: const Text('Довідник')),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(labelText: 'Клінічний діагноз', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Provider.of<RehabProvider>(context, listen: false).addPatient(
                      fullName: _fullNameController.text.trim(),
                      diagnosis: _diagnosisController.text.trim(),
                      icdCode: _icdCodeController.text.trim().toUpperCase(),
                      dateOfBirth: _selectedDate,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Зберегти картку'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
