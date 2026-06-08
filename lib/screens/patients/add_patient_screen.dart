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
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 45)); // Дефолтно ~45 років

  final SmartIrpEngine _irpEngine = SmartIrpEngine();

  @override
  void dispose() {
    _fullNameController.dispose();
    _diagnosisController.dispose();
    _icdCodeController.dispose();
    super.dispose();
  }

  // Вікно вибору кодів МКХ-10 з живим пошуком
  void _showIcd10Picker() {
    String searchQuery = '';
    final allCodes = _irpEngine.icd10Database;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Фільтрація бази кодів за запитом користувача
            final filteredCodes = allCodes.entries.where((entry) {
              final searchLower = searchQuery.toLowerCase();
              return entry.key.toLowerCase().contains(searchLower) ||
                     entry.value.toLowerCase().contains(searchLower);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        const Text(
                          'Клінічний класифікатор МКХ-10',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Пошук за кодом або назвою хвороби...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredCodes.isEmpty
                          ? const Center(child: Text('Нічого не знайдено. Ви можете ввести код вручну.'))
                          : ListView.builder(
                              itemCount: filteredCodes.length,
                              itemBuilder: (ctx, index) {
                                final item = filteredCodes[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: Chip(
                                      label: Text(
                                        item.key,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                      ),
                                      backgroundColor: Colors.blue.shade50,
                                    ),
                                    title: Text(item.value),
                                    trailing: const Icon(Icons.chevron_right, size: 18),
                                    onTap: () {
                                      // Автоматичне підтягування даних у форму
                                      setState(() {
                                        _icdCodeController.text = item.key;
                                        _diagnosisController.text = item.value;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<RehabProvider>(context, listen: false).addPatient(
      fullName: _fullNameController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      icdCode: _icdCodeController.text.trim().toUpperCase(),
      dateOfBirth: _selectedDate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Картку пацієнта успішно створено!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Нова медична картка'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        style: TextStyle(), // Для чистоти стилістики
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Прізвище, Ім\'я, По батькові пацієнта',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Вкажіть ПІБ' : null,
              ),
              const SizedBox(height: 16),
              
              // Рядок з МКХ-10 полем та інтелектуальною кнопкою-підборщиком
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _icdCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Код за МКХ-10',
                        border: OutlineInputBorder(),
                        hintText: 'Наприклад: Z89.2',
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Вкажіть код' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: const Text('Довідник'),
                        onPressed: _showIcd10Picker,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Клінічний діагноз / Опис стану',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment_turned_in),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Опишіть діагноз пацієнта' : null,
              ),
              const SizedBox(height: 16),
              
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: const Text('Дата народження пацієнта'),
                  subtitle: Text(
                    '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  trailing: const Icon(Icons.edit, size: 18),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Зберегти та відкрити карту', style: TextStyle(fontSize: 16)),
                  onPressed: _saveForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
