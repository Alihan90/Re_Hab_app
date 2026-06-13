import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/clinical_models.dart';
import '../../providers/rehab_provider.dart';

class InteractiveAssessmentScreen extends StatefulWidget {
  final ClinicalScale scale;
  final String patientId;

  const InteractiveAssessmentScreen({
    super.key,
    required this.scale,
    required this.patientId,
  });

  @override
  State<InteractiveAssessmentScreen> createState() => _InteractiveAssessmentScreenState();
}

class _InteractiveAssessmentScreenState extends State<InteractiveAssessmentScreen> {
  final Map<String, double> _answers = {};

  void _submit() {
    // 1. Валідація: перевіряємо, чи всі секції заповнені
    if (_answers.length < widget.scale.sections.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Будь ласка, дайте відповідь на всі запитання')),
      );
      return;
    }

    // 2. Розрахунок результату
    double total = _answers.values.fold(0, (sum, val) => sum + val);

    // 3. Збереження через провайдер (ВИПРАВЛЕНО: Вилучено неіснуючий параметр answers)
    Provider.of<RehabProvider>(context, listen: false).saveAssessmentResult(
      patientId: widget.patientId,
      scaleId: widget.scale.id,
      totalScore: total,
      calculatedIndex: (total / widget.scale.maxRawScore) * 100,
      interpretation: "Результат: $total з ${widget.scale.maxRawScore}. Рівень: ${((total / widget.scale.maxRawScore) * 100).toStringAsFixed(1)}%",
    );

    Navigator.pop(context);
  }

  // Розумний рендерер, який малює різний UI залежно від типу шкали
  Widget _buildSectionInput(ScaleSection section) {
    switch (widget.scale.type) {
      case ScaleType.multiItem:
        return Column(
          children: section.options.map((opt) => RadioListTile<double>(
            title: Text(opt.text),
            subtitle: Text('${opt.score} балів'),
            value: opt.score,
            groupValue: _answers[section.id],
            onChanged: (val) => setState(() => _answers[section.id] = val!),
          )).toList(),
        );

      case ScaleType.selectRow:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<double>(
            isExpanded: true,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Оберіть варіант'),
            value: _answers[section.id],
            items: section.options.map((o) => DropdownMenuItem(value: o.score, child: Text(o.text))).toList(),
            onChanged: (val) => setState(() => _answers[section.id] = val!),
          ),
        );

      case ScaleType.vitalsProtocol:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Введіть значення'),
            onChanged: (val) => setState(() => _answers[section.id] = double.tryParse(val) ?? 0),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.scale.name)),
      body: widget.scale.sections.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Для цієї проби використовується протокол заміру життєвих показників у реальному часі.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.scale.sections.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, sIdx) {
                final section = widget.scale.sections[sIdx];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title, style: Theme.of(context).textTheme.titleMedium),
                    if (section.description.isNotEmpty) Text(section.description),
                    const SizedBox(height: 10),
                    _buildSectionInput(section),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submit,
        label: const Text('Зберегти результат'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
