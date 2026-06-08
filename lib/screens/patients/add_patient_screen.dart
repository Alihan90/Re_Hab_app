import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({Key? key}) : super(key: key);

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _icdController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _diagnosisController.dispose();
    _icdController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime(1980),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Помилка: Заповніть текстові поля та вкажіть дату народження!')),
      );
      return;
    }

    Provider.of<RehabProvider>(context, listen: false).addPatient(
      fullName: _nameController.text,
      diagnosis: _diagnosisController.text,
      icdCode: _icdController.text,
      dateOfBirth: _selectedDate!,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Створення картки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ПІБ пацієнта (будь-якою мовою)',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Вкажіть ПІБ пацієнта' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Клінічний діагноз',
                  prefixIcon: Icon(Icons.healing_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Заповніть опис діагнозу' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _icdController,
                decoration: const InputDecoration(
                  labelText: 'Код за МКХ-10 (вручну)',
                  hintText: 'Наприклад: I63.9 чи M50.1',
                  prefixIcon: Icon(Icons.pin),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Вкажіть код МКХ-10' : null,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(
                    _selectedDate == null
                        ? 'Оберіть дату народження пацієнта'
                        : 'Дата народження: ${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                  ),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _presentDatePicker,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Зберегти та відкрити доступ', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
