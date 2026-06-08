import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../../data/database/app_database.dart';
import '../../services/smart_irp_engine.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailsScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _visitNotesController = TextEditingController();
  final _smartGoalsController = TextEditingController();
  final _irpPlanController = TextEditingController();
  String _selectedScale = 'Berg Balance Scale';
  double _scaleScore = 45.0;

  @override
  void initState() {
    super.initState();
    _smartGoalsController.text = widget.patient.smartGoals ?? '';
    _irpPlanController.text = widget.patient.irpPlan ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RehabProvider>(context, listen: false).loadVisits(widget.patient.id);
    });
  }

  @override
  void dispose() {
    _visitNotesController.dispose();
    _smartGoalsController.dispose();
    _irpPlanController.dispose();
    super.dispose();
  }

  void _autoGenerateIrpFromEngine() {
    final engine = SmartIrpEngine();
    final plan = engine.autoGeneratePlan(
      mkh10Codes: [widget.patient.icdCode],
      age: (DateTime.now().year - widget.patient.dateOfBirth.year).toString(),
      plannedDays: 14,
      goalsSmart: _smartGoalsController.text.isNotEmpty 
          ? _smartGoalsController.text 
          : 'Збільшити рівень функціональної незалежності та покращити мобільність за 14 днів.',
    );

    setState(() {
      _smartGoalsController.text = plan.goalsSmart;
      _irpPlanController.text = 'Пов\'язані клінічні коди МКФ: ${plan.mfkCodes.join(", ")}\n\nРозклад реабілітаційного інтенсиву по днях:\n' +
          plan.daysSchedule.entries.map((e) => 'День ${e.key}: ' + e.value.map((ex) => ex.title).join(', ')).join('\n');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Двигун успішно розрахував ІРП на основі МКХ-10 та МКФ!')),
    );
  }

  void _saveSmartConstructorData() {
    Provider.of<RehabProvider>(context, listen: false).updatePatientPlan(
      widget.patient,
      _smartGoalsController.text,
      _irpPlanController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Зміни в конструкторі ІРП успішно збережено в локальну БД.')),
    );
  }

  void _submitVisitAndScale() {
    if (_visitNotesController.text.isEmpty) return;
    Provider.of<RehabProvider>(context, listen: false).addVisit(
      patientId: widget.patient.id,
      notes: _visitNotesController.text,
      assessmentResults: '$_selectedScale | Результат: ${_scaleScore.toStringAsFixed(0)} балів',
    );
    _visitNotesController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Дані нового оцінювання та візиту занесені до динаміки.')),
    );
  }

  void _renderMockPdfDocument(String docTitle, String templateBody) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(child: Text(docTitle, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
            child: Text(templateBody, style: const TextStyle(fontFamily: 'Courier', fontSize: 12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Експортувати у PDF-файл')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Закрити')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);
    final age = DateTime.now().year - widget.patient.dateOfBirth.year;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.patient.fullName),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.folder_shared), text: 'Картка & Візити'),
              Tab(icon: Icon(Icons.analytics), text: 'SMART Конструктор'),
              Tab(icon: Icon(Icons.insights), text: 'Динаміка шкал'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Клінічний діагноз: ${widget.patient.diagnosis}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Код за МКХ-10: ${widget.patient.icdCode}   |   Вік пацієнта: $age років'),
                          Text('Дата народження: ${widget.patient.dateOfBirth.day}.${widget.patient.dateOfBirth.month}.${widget.patient.dateOfBirth.year}'),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.print_rounded),
                                  label: const Text('Звіт за ст. МОЗ'),
                                  onPressed: () => _renderMockPdfDocument(
                                    'Медична виписка (Форма № 027/о МОЗ України)',
                                    'ЗАТВЕРДЖЕНО: Наказ МОЗ України\nФОРМА ПЕРВИННОЇ ОБЛІКОВОЇ ДОКУМЕНТАЦІЇ № 027/о\n\nПацієнт: ${widget.patient.fullName}\nДата народження: ${widget.patient.dateOfBirth.day}.${widget.patient.dateOfBirth.month}.${widget.patient.dateOfBirth.year}\nКлінічний діагноз: ${widget.patient.diagnosis}\nКод за МКХ-10: ${widget.patient.icdCode}\nСтатус реабілітації: протокольовано згідно з вимогами НСЗУ.',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.article_outlined),
                                  label: const Text('Окремий док. ІРП'),
                                  onPressed: () => _renderMockPdfDocument(
                                    'Індивідуальний реабілітаційний план пацієнта',
                                    'ЗАТВЕРДЖЕНА СТРУКТУРА ІРП\nПацієнт: ${widget.patient.fullName}\n\n1. ЦІЛІ ЗА SMART:\n${_smartGoalsController.text}\n\n2. ПРОГРАМА НАДАННЯ РЕАБІЛІТАЦІЙНОЇ ДОПОМОГИ:\n${_irpPlanController.text}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.patient.isActive) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade100, foregroundColor: Colors.amber.shade900),
                                icon: const Icon(Icons.done_all),
                                label: const Text('Завершити лікування (Передати в Архів)'),
                                onPressed: () {
                                  provider.completeTreatment(widget.patient);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Провести оцінювання / Новий візит', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedScale,
                    items: ['Berg Balance Scale', 'Ashworth Scale', 'Barthel Index', 'Rivermead Mobility Index']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedScale = v!),
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Клінічна оціночна шкала'),
                  ),
                  const SizedBox(height: 8),
                  Text('Показник за шкалою: ${_scaleScore.toStringAsFixed(0)} балів'),
                  Slider(
                    value: _scaleScore,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: _scaleScore.toStringAsFixed(0),
                    onChanged: (v) => setState(() => _scaleScore = v),
                  ),
                  TextFormField(
                    controller: _visitNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Щоденник візиту / Нотатки терапевта',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _submitVisitAndScale,
                    child: const Text('Зафіксувати новий візит'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Згенерувати ІРП за кодом МКХ-10'),
                    onPressed: _autoGenerateIrpFromEngine,
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _smartGoalsController,
                    decoration: const InputDecoration(
                      labelText: 'Цілі реабілітації (Критерії SMART)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _irpPlanController,
                    decoration: const InputDecoration(
                      labelText: 'Програма та розклад ІРП',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 8,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveSmartConstructorData,
                    child: const Text('Зберегти зміни у конструкторі'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: provider.currentPatientVisits.isEmpty
                  ? const Center(child: Text('Історія візитів та динаміка оцінювання порожня.'))
                  : ListView.builder(
                      itemCount: provider.currentPatientVisits.length,
                      itemBuilder: (context, index) {
                        final visit = provider.currentPatientVisits[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.trending_up, color: Colors.teal),
                            title: Text(visit.assessmentResults, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Дата проведення: ${visit.visitDate.day}.${visit.visitDate.month}.${visit.visitDate.year}\nНотатки: ${visit.notes}'),
                            isThreeLine: true,
                          ),
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
