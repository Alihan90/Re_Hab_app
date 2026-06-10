import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../../services/smart_irp_engine.dart';
import '../../services/pdf_export_service.dart';
import '../../models/clinical_models.dart';
import '../assessment/interactive_assessment_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final dynamic patient; // Об'єкт пацієнта з бази даних Drift або Mock-системи

  const PatientDetailsScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _completedDays = <int>{};

  // Контролери для додавання кастомної вправи лікарем
  final _exNameController = TextEditingController();
  final _exDescController = TextEditingController();
  final _exDosageController = TextEditingController();
  String _selectedExCategory = 'Нейрореабілітація';

  @override
  void initState() {
    super.initState();
    // Створюємо 3 вкладки: Клінічний профіль, Календар ІРП, Клінікометрія та Вправи
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _exNameController.dispose();
    _exDescController.dispose();
    _exDosageController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Віконце (BottomSheet) для ручного додавання нової вправи лікарем
  void _showAddExerciseBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Додати власну вправу до довідника',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const Divider(),
                const SizedBox(height: 8),
                TextField(
                  controller: _exNameController,
                  decoration: const InputDecoration(labelText: 'Назва вправи', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedExCategory,
                  decoration: const InputDecoration(labelText: 'Клінічна категорія', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Нейрореабілітація', child: Text('Нейрореабілітація')),
                    DropdownMenuItem(value: 'Ортопедія/Травматологія', child: Text('Ортопедія/Травматологія')),
                    DropdownMenuItem(value: 'Кардіо-респіраторна', child: Text('Кардіо-респіраторна')),
                    DropdownMenuItem(value: 'Загальна реабілітація', child: Text('Загальна реабілітація')),
                  ],
                  onChanged: (val) {
                    if (val != null) _selectedExCategory = val;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _exDescController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Опис техніки виконання та контролю', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _exDosageController,
                  decoration: const InputDecoration(labelText: 'Дозування (напр: 3 підходи по 10 разів)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                    onPressed: () {
                      if (_exNameController.text.isNotEmpty && _exDescController.text.isNotEmpty) {
                        Provider.of<RehabProvider>(context, listen: false).addCustomExercise(
                          name: _exNameController.text,
                          category: _selectedExCategory,
                          description: _exDescController.text,
                          dosage: _exDosageController.text,
                        );
                        _exNameController.clear();
                        _exDescController.clear();
                        _exDosageController.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Вправу успішно додано до клінічної бази!'), backgroundColor: Colors.green),
                        );
                      }
                    },
                    child: const Text('Зберегти вправу у довідник', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);
    final historyAssessments = provider.getAssessmentsForPatient(widget.patient.id.toString());

    // Генеруємо інтелектуальний базовий каркас плану лікування через CDSS-рушій
    final irpPlan = SmartIrpEngine.generate(
      icdCode: widget.patient.icdCode,
      diagnosis: widget.patient.diagnosis,
      treatmentDays: widget.patient.treatmentDays ?? 10,
      complaints: widget.patient.complaints,
      expectations: widget.patient.expectations,
    );

    final totalDays = widget.patient.treatmentDays ?? 10;
    final progressPercentage = totalDays > 0 ? (_completedDays.length / totalDays) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.fullName),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.assignment), text: 'Профіль & МОЗ PDF'),
            Tab(icon: Icon(Icons.fact_check), text: 'Календар ІРП'),
            Tab(icon: Icon(Icons.analytics), text: 'Шкали & Вправи'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ВЕРХНІЙ МОНІТОР КОМПЛАЄНСУ ТА ПРОГРЕСУ
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Вік: ${_calculateAge(widget.patient.dateOfBirth)} р. | Код: ${widget.patient.icdCode}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_completedDays.length}/$totalDays дн. (${(progressPercentage * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.blue.shade700,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          //ОСНОВНИЙ КОНТЕНТ ВКЛАДОК
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ВКЛАДКА 1: ПРОФІЛЬ + ЕКСПОРТ PDF ЗА СТАНДАРТАМИ МОЗ
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Панель експорту офіційних документів
                    Card(
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.shade200)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.picture_as_pdf, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Звітність та експорт документації (МОЗ / НСЗУ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.description, size: 18),
                                    label: const Text('Первинний ІРП', style: TextStyle(fontSize: 12)),
                                    onPressed: () => PdfExportService.exportInitialPlan(
                                      patient: widget.patient,
                                      irpPlan: irpPlan,
                                      assessments: historyAssessments,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.output, size: 18),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                                    label: const Text('Виписка/Епікриз', style: TextStyle(fontSize: 12)),
                                    onPressed: () => PdfExportService.exportDischargeSummary(
                                      patient: widget.patient,
                                      irpPlan: irpPlan,
                                      assessments: historyAssessments,
                                      completedDays: _completedDays,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSectionCard('Офіційний клінічний діагноз', Icons.medical_services, widget.patient.diagnosis, Colors.redAccent),
                    if (widget.patient.complaints != null)
                      _buildSectionCard('Анамнестичні скарги пацієнта', Icons.comment, widget.patient.complaints!, Colors.orange),
                    _buildSectionCard('⚠️ Клінічні застереження та моніторинг', Icons.warning_amber_rounded, irpPlan.clinicalPrecautions, Colors.amber.shade900, isAlert: true),
                    _buildSectionCard('Автоматичний SMART-критерій цілей', Icons.track_changes, irpPlan.smartGoals, Colors.green),
                  ],
                ),

                // ВКЛАДКА 2: КАЛЕНДАР ІРП (ЧЕК-ЛІСТ ПО ДНЯХ)
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: irpPlan.dailyActivities.length,
                  itemBuilder: (context, index) {
                    final dayNumber = index + 1;
                    final isDone = _completedDays.contains(dayNumber);
                    final activityText = irpPlan.dailyActivities[index];
                    final displayBody = activityText.replaceFirst('День $dayNumber — ', '');

                    return Card(
                      elevation: isDone ? 1 : 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: isDone ? Colors.green.shade50.withOpacity(0.6) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isDone ? Colors.green.withOpacity(0.4) : Colors.transparent, width: 1.5),
                      ),
                      child: CheckboxListTile(
                        activeColor: Colors.green.shade700,
                        title: Text('ДЕНЬ $dayNumber', style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? Colors.green.shade800 : Colors.blueGrey.shade800, decoration: isDone ? TextDecoration.lineThrough : null)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(displayBody, style: TextStyle(fontSize: 14, color: isDone ? Colors.grey.shade600 : Colors.black87, decoration: isDone ? TextDecoration.lineThrough : null)),
                        ),
                        value: isDone,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              _completedDays.add(dayNumber);
                            } else {
                              _completedDays.remove(dayNumber);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),

                // ВКЛАДКА 3: КЛІНІКОМЕТРІЯ (ШКАЛИ) ТА БАЗА ВПРАВ
                ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    // Блок запуску інтерактивного тестування
                    const Text('Проведення клінікометричних тестів:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade700, foregroundColor: Colors.white),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InteractiveAssessmentScreen(patientId: widget.patient.id.toString(), scaleType: 'berg')),
                            ),
                            child: const Text('Тест Берга (Баланс)', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade700, foregroundColor: Colors.white),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InteractiveAssessmentScreen(patientId: widget.patient.id.toString(), scaleType: 'barthel')),
                            ),
                            child: const Text('Індекс Бартел (АДЛ)', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Результати тестувань у картці пацієнта
                    const Text('Історія тестувань за шкалами:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (historyAssessments.isEmpty)
                      const Text('Жодного тестування ще не проведено. Оберіть шкалу вище.', style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic))
                    else
                      ...historyAssessments.map((res) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.analytics_outlined, color: Colors.blue),
                              title: Text(res.scaleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text('${res.interpretation}\nДата: ${res.date.day}.${res.date.month}.${res.date.year}', style: const TextStyle(fontSize: 12)),
                              isThreeLine: true,
                            ),
                          )),
                    
                    const Divider(height: 32),

                    // РОЗШИРЕНА БАЗА ВПРАВ З МОЖЛИВІСТЮ ДОДАВАННЯ ВЛАСНИХ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Клінічний довідник вправ:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
                          onPressed: _showAddExerciseBottomSheet,
                          tooltip: 'Додати свою вправу',
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...provider.exercises.map((ex) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: ex.isCustom ? Colors.blue.withOpacity(0.4) : Colors.transparent, width: 1)
                          ),
                          color: ex.isCustom ? Colors.blue.shade50.withOpacity(0.4) : null,
                          child: ExpansionTile(
                            leading: Icon(
                              ex.category == 'Нейрореабілітація' ? Icons.psychology : ex.category == 'Ортопедія/Травматологія' ? Icons.accessibility : Icons.air,
                              color: Colors.blueGrey,
                            ),
                            title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            trailing: ex.isCustom ? const Chip(label: Text('Лікар', style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.blue, dense: true) : null,
                            subtitle: Text('Категорія: ${ex.category} | Доза: ${ex.dosage}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(ex.description, style: const TextStyle(fontSize: 13, height: 1.3, color: Colors.black87)),
                              )
                            ],
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, String content, Color iconColor, {bool isAlert = false}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isAlert ? Colors.amber.shade50.withOpacity(0.5) : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isAlert ? Colors.amber.shade900 : null)),
              ],
            ),
            const Divider(height: 20),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
