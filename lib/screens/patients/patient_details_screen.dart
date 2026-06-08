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
  
  // Клінічні змінні для різних шкал
  String _selectedScale = 'Berg Balance Scale';
  double _bergScore = 45.0;       // 0 - 56
  String _ashworthScore = '1+';    // 0, 1, 1+, 2, 3, 4
  double _barthelScore = 80.0;     // 0 - 100 (крок 5)
  double _rivermeadScore = 11.0;   // 0 - 15

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

  // Розумна генерація плану на основі діагнозу та SMART структури
  void _autoGenerateIrpFromEngine() {
    final engine = SmartIrpEngine();
    final plan = engine.autoGeneratePlan(
      mkh10Codes: [widget.patient.icdCode],
      age: (DateTime.now().year - widget.patient.dateOfBirth.year).toString(),
      plannedDays: 14,
      goalsSmart: '',
    );

    setState(() {
      _smartGoalsController.text = plan.goalsSmart;
      
      // Формуємо красивий структурований вивід програми вправ по днях
      String formattedSchedule = '🧬 МІЖНАРОДНА КЛАСИФІКАЦІЯ ФУНКЦІОНУВАННЯ (МКФ):\nКоди: ${plan.mfkCodes}\n\n'
          '📋 КОМПЛЕКСНА ПРОГРАМА РЕАБІЛІТАЦІЇ ТА ФІЗІОТЕРАПІЇ ПО ДНЯХ:\n\n';
          
      plan.daysSchedule.forEach((day, exercises) {
        formattedSchedule += '📅 ДЕНЬ $day:\n';
        for (var ex in exercises) {
          formattedSchedule += '  • [${ex.category}] ${ex.title}\n    Дозування: ${ex.dosage}\n';
        }
        formattedSchedule += '\n';
      });

      _irpPlanController.text = formattedSchedule;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Двигун успішно розрахував ІРП на основі МКХ-10, SMART та МКФ!')),
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

  // Фіксація візиту з коректно розрахованими балами
  void _submitVisitAndScale() {
    String assessmentResults = '';
    
    if (_selectedScale == 'Berg Balance Scale') {
      assessmentResults = '$_selectedScale | Результат: ${_bergScore.toStringAsFixed(0)}/56 балів';
    } else if (_selectedScale == 'Ashworth Scale') {
      assessmentResults = '$_selectedScale | Тонус м\'язів: $_ashworthScore (за модифікованою шкалою)';
    } else if (_selectedScale == 'Barthel Index') {
      assessmentResults = '$_selectedScale | Результат: ${_barthelScore.toStringAsFixed(0)}/100 балів';
    } else if (_selectedScale == 'Rivermead Mobility Index') {
      assessmentResults = '$_selectedScale | Результат: ${_rivermeadScore.toStringAsFixed(0)}/15 балів';
    }

    Provider.of<RehabProvider>(context, listen: false).addVisit(
      patientId: widget.patient.id,
      notes: _visitNotesController.text.isEmpty ? 'Побутовий огляд, оцінка динаміки рухів.' : _visitNotesController.text,
      assessmentResults: assessmentResults,
    );
    
    _visitNotesController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Дані професійного оцінювання внесені до карти пацієнта.')),
    );
  }

  // Динамічний віджет підбору балів під КОНКРЕТНУ шкалу
  Widget _buildScaleSpecificInput() {
    switch (_selectedScale) {
      case 'Berg Balance Scale':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Оцінка рівноваги Берга: ${_bergScore.toStringAsFixed(0)} з 56 балів', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            Slider(
              value: _bergScore,
              min: 0, max: 56, divisions: 56,
              label: _bergScore.toStringAsFixed(0),
              onChanged: (v) => setState(() => _bergScore = v),
            ),
            Text(_bergScore <= 20 ? '⚠️ Високий ризик падінь (Потрібна постійна опіка)' : _bergScore <= 40 ? '🟡 Помірний ризик падінь' : '🟢 Незалежне пересування пацієнта', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        );
      case 'Ashworth Scale':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ступінь спастичності за Ашвортом:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '0', label: Text('0')),
                ButtonSegment(value: '1', label: Text('1')),
                ButtonSegment(value: '1+', label: Text('1+')),
                ButtonSegment(value: '2', label: Text('2')),
                ButtonSegment(value: '3', label: Text('3')),
                ButtonSegment(value: '4', label: Text('4')),
              ],
              selected: {_ashworthScore},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _ashworthScore = newSelection.first;
                });
              },
            ),
          ],
        );
      case 'Barthel Index':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Індекс життєдіяльності Бартел: ${_barthelScore.toStringAsFixed(0)} з 100 балів', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            Slider(
              value: _barthelScore,
              min: 0, max: 100, divisions: 20, // Крок 5 балів
              label: _barthelScore.toStringAsFixed(0),
              onChanged: (v) => setState(() => _barthelScore = v),
            ),
            Text(_barthelScore <= 20 ? '⚠️ Повна залежність у побуті' : _barthelScore <= 60 ? '🟡 Тяжка залежність' : '🟢 Помірна / легка залежність', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        );
      case 'Rivermead Mobility Index':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Індекс мобільності Рівермід: ${_rivermeadScore.toStringAsFixed(0)} з 15 балів', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            Slider(
              value: _rivermeadScore,
              min: 0, max: 15, divisions: 15,
              label: _rivermeadScore.toStringAsFixed(0),
              onChanged: (v) => setState(() => _rivermeadScore = v),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
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
            // ТАБ 1: КАРТКА ПАЦІЄНТА, ЕКСПОРТ ТА НОВИЙ ВІЗИТ
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
                          Text('Клінічний діагноз: ${widget.patient.diagnosis}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                  const Text('Провести клінічне оцінювання', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedScale,
                    items: ['Berg Balance Scale', 'Ashworth Scale', 'Barthel Index', 'Rivermead Mobility Index']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedScale = v!),
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Оціночна шкала'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Відображає СУВОРО НАЛАШТОВАНІ віджети балів під обрану шкалу
                  _buildScaleSpecificInput(),
                  
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _visitNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Щоденник візиту / Специфічні нотатки терапевта',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: _submitVisitAndScale,
                    label: const Text('Зафіксувати оцінювання у динаміку'),
                  ),
                ],
              ),
            ),

            // ТАБ 2: СМАРТ КОНСТРУКТОР ТА ІРП
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Розрахувати ІРП та комплекси вправ за МКХ-10'),
                    onPressed: _autoGenerateIrpFromEngine,
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                  ),
                  const SizedBox(height: 16),
                  const Text('Цілі реабілітації (Критерії SMART):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _smartGoalsController,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    maxLines: 6,
                  ),
                  const SizedBox(height: 16),
                  const Text('Програма та розклад занять (Кінезо/Електро/Магніто/Інвентар):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _irpPlanController,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    maxLines: 12,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveSmartConstructorData,
                    child: const Text('Зберегти зміни у конструкторі'),
                  ),
                ],
              ),
            ),

            // ТАБ 3: КЛІНІЧНА ДИНАМІКА
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
                            title: Text(visit.assessmentResults, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal)),
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
