import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../../data/icd10/icd10_local_db.dart';

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
  final _complaintsController = TextEditingController();
  final _expectationsController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 45));
  int _selectedTreatmentDays = 10; 

  final List<int> _daysOptions = [7, 10, 14, 21, 24, 28, 30, 45, 60];

  @override
  void dispose() {
    _fullNameController.dispose();
    _diagnosisController.dispose();
    _icdCodeController.dispose();
    _complaintsController.dispose();
    _expectationsController.dispose();
    super.dispose();
  }

  void _showIcd10Picker() {
    String searchQuery = '';
    final allCodes = Icd10LocalDb.collection;

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
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Класифікатор МКХ-10',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                            Text(
                              'Загальна медицина та супутні патології',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Пошук (напр. Ниркова, Сепсис, M51, R68)...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) {
                        setModalState(() => searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredCodes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.info_outline, size: 48, color: Colors.orange),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Рідкісний або специфічний діагноз',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    child: Text(
                                      'Цього коду немає в базовому списку. Ви можете ввести його вручну прямо в поля форми.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.check),
                                    label: const Text('Внести вручну у форму'),
                                    onPressed: () {
                                      setState(() {
                                        _icdCodeController.text = searchQuery.toUpperCase();
                                        _diagnosisController.text = '';
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCodes.length,
                              itemBuilder: (ctx, index) {
                                final item = filteredCodes[index];
                                return ListTile(
                                  title: Text(item.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                  subtitle: Text(item.value, style: const TextStyle(fontSize: 14)),
                                  leading: const Icon(Icons.medical_information, color: Colors.blue),
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
              // ПІБ Пацієнта
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'ПІБ пацієнта',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Вкажіть ПІБ пацієнта' : null,
              ),
              const SizedBox(height: 16),

              // Поле МКХ-10 з кнопкою пошуку
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _icdCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Код МКХ-10',
                        hintText: 'Наприклад, N18.9 або R68.8',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Оберіть або введіть код' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.manage_search),
                      onPressed: _showIcd10Picker, 
                      label: const Text('МКХ-10'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Клінічний діагноз
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Клінічний діагноз (основний + супутні)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Заповніть клінічний діагноз' : null,
              ),
              const SizedBox(height: 16),

              // Скарги пацієнта
              TextFormField(
                controller: _complaintsController,
                decoration: const InputDecoration(
                  labelText: 'Скарги пацієнта анамнестичні',
                  hintText: 'Біль, задишка, обмеження руху, слабкість, набряки при ХНН...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Очікування від реабілітації
              TextFormField(
                controller: _expectationsController,
                decoration: const InputDecoration(
                  labelText: 'Очікування пацієнта від реабілітації',
                  hintText: 'Відновити безпечне пересування, стабілізувати загальний стан...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.track_changes),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Тривалість лікування
              DropdownButtonFormField<int>(
                value: _selectedTreatmentDays,
                decoration: const InputDecoration(
                  labelText: 'Термін реабілітаційного лікування (днів)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.date_range),
                ),
                items: _daysOptions.map((int day) {
                  return DropdownMenuItem<int>(
                    value: day,
                    child: Text('$day днів лікувального протоколу'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedTreatmentDays = newValue);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Дата народження
              ListTile(
                title: Text('Дата народження: ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1920),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Дані пацієнта захищені локальним шифруванням бази даних.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Provider.of<RehabProvider>(context, listen: false).addPatient(
                      fullName: _fullNameController.text.trim(),
                      diagnosis: _diagnosisController.text.trim(),
                      icdCode: _icdCodeController.text.trim().toUpperCase(),
                      dateOfBirth: _selectedDate,
                      complaints: _complaintsController.text.trim().isEmpty ? null : _complaintsController.text.trim(),
                      expectations: _expectationsController.text.trim().isEmpty ? null : _expectationsController.text.trim(),
                      treatmentDays: _selectedTreatmentDays,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Зберегти картку пацієнта', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
