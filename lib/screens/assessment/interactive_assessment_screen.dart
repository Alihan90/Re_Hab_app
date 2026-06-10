import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/clinical_models.dart';
import '../../data/repositories/clinical_repository.dart';
import '../../providers/rehab_provider.dart';

class InteractiveAssessmentScreen extends StatefulWidget {
  final String patientId;
  final String scaleId;

  const InteractiveAssessmentScreen({
    Key? key,
    required this.patientId,
    required this.scaleId,
  }) : super(key: key);

  @override
  State<InteractiveAssessmentScreen> createState() => _InteractiveAssessmentScreenState();
}

class _InteractiveAssessmentScreenState extends State<InteractiveAssessmentScreen> {
  late ClinicalScaleMeta _scaleMeta;
  final Map<int, int> _selectedMultiScores = {}; // Для багатопунктових шкал (Берг/Бартел)
  int _singleSelectedScore = 0; // Для одновимірних шкал (RASS, Ешворт)

  // Контролери для фізіологічних замірів (Ортостатичний / Тілт тест)
  final _hrLyingController = TextEditingController(text: '70');
  final _sysLyingController = TextEditingController(text: '120');
  final _diaLyingController = TextEditingController(text: '80');
  
  final _hrStandingController = TextEditingController(text: '95');
  final _sysStandingController = TextEditingController(text: '105');
  final _diaStandingController = TextEditingController(text: '70');

  @override
  void initState() {
    super.initState();
    // Знаходимо метадані потрібної шкали з нашого репозиторію
    _scaleMeta = ClinicalRepository.allScales.firstWhere((s) => s.id == widget.scaleId);

    // Ініціалізуємо базові бали
    if (_scaleMeta.type == ScaleType.multiItem) {
      for (var item in _scaleMeta.items) {
        _selectedMultiScores[item.id] = item.scoreOptions.keys.first;
      }
    } else if (_scaleMeta.type == ScaleType.selectRow) {
      _singleSelectedScore = _scaleMeta.items.first.scoreOptions.keys.first;
    }
  }

  @override
  void dispose() {
    _hrLyingController.dispose();
    _sysLyingController.dispose();
    _diaLyingController.dispose();
    _hrStandingController.dispose();
    _sysStandingController.dispose();
    _diaStandingController.dispose();
    super.dispose();
  }

  /// Розрахунок результатів на льоту для відображення у верхній панелі
  int get _calculatedScore {
    if (_scaleMeta.type == ScaleType.multiItem) {
      return _selectedMultiScores.values.fold(0, (sum, val) => sum + val);
    }
    if (_scaleMeta.type == ScaleType.selectRow) {
      return _singleSelectedScore;
    }
    return 0; // Для фізіологічних тестів розрахунок йде через метод репозиторію при збереженні
  }

  String get _calculatedInterpretation {
    if (_scaleMeta.type == ScaleType.selectRow) {
      return ClinicalRepository.interpretSingleRow(_scaleMeta.id, _singleSelectedScore);
    }
    if (_scaleMeta.type == ScaleType.multiItem) {
      return _scaleMeta.id == 'berg' 
          ? 'Загальний підрахунок балів Берга: $_calculatedScore із 56 можливих.'
          : 'Загальний індекс Бартел: $_calculatedScore балів.';
    }
    return "Протокол вегетативного реагування.";
  }

  /// Метод обробки та збереження тестування пацієнта
  void _submitAssessment() {
    int finalScore = 0;
    String finalInterpretation = "";
    Map<String, String> details = {};

    if (_scaleMeta.type == ScaleType.vitalsProtocol) {
      // Математичний прорахунок ортостатичної проби
      final res = ClinicalRepository.calculateVitalsTest(
        testId: _scaleMeta.id,
        hrLying: int.tryParse(_hrLyingController.text) ?? 70,
        sysLying: int.tryParse(_sysLyingController.text) ?? 120,
        diaLying: int.tryParse(_diaLyingController.text) ?? 80,
        hrStanding: int.tryParse(_hrStandingController.text) ?? 95,
        sysStanding: int.tryParse(_sysStandingController.text) ?? 105,
        diaStanding: int.tryParse(_diaStandingController.text) ?? 70,
      );
      finalScore = res['score'];
      finalInterpretation = res['text'];
      details = {
        'Lying': '${_sysLyingController.text}/${_diaLyingController.text} мм.рт.ст, ЧСС: ${_hrLyingController.text}',
        'Standing': '${_sysStandingController.text}/${_diaStandingController.text} мм.рт.ст, ЧСС: ${_hrStandingController.text}',
      };
    } else {
      finalScore = _calculatedScore;
      finalInterpretation = _calculatedInterpretation;
    }

    final assessmentResult = AssessmentResult(
      scaleId: _scaleMeta.id,
      scaleName: _scaleMeta.name,
      date: DateTime.now(),
      totalScore: finalScore,
      interpretation: finalInterpretation,
      dynamicDetails: details,
    );

    Provider.of<RehabProvider>(context, listen: false).saveAssessment(
      widget.patientId,
      assessmentResult,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Результат тесту "${_scaleMeta.name}" зафіксовано в картці!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_scaleMeta.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          // ВЕРХНЯ ДІАГНОСТИЧНА СТАТУС-ПАНЕЛЬ (Не рендериться для сирих фізіологічних тестів)
          if (_scaleMeta.type != ScaleType.vitalsProtocol)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Поточний бал: $_calculatedScore', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueDark)),
                  const SizedBox(height: 4),
                  Text('Попередній висновок: $_calculatedInterpretation', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

          // АДАПТИВНЕ ТІЛО ТЕСТУВАННЯ Згідно з ТИПОМ ШКАЛИ
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: _buildAdaptiveTestBody(),
            ),
          ),

          // ФІКСУЮЧА КНОПКА ЗБЕРЕЖЕННЯ
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Записати тест у медичну картку', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _submitAssessment,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Роутер побудови UI під кожну медичну задачу
  Widget _buildAdaptiveTestBody() {
    // ВАРІАНТ А: ШКАЛА ОДНОГО РЯДКА (RASS, ЕШВОРТ) — Величезні детальні чек-рядки
    if (_scaleMeta.type == ScaleType.selectRow) {
      final item = _scaleMeta.items.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.instruction, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          ...item.scoreOptions.entries.map((entry) {
            final isSelected = _singleSelectedScore == entry.key;
            return Card(
              elevation: isSelected ? 3 : 1,
              color: isSelected ? Colors.blue.shade50 : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
              ),
              child: RadioListTile<int>(
                value: entry.key,
                groupValue: _singleSelectedScore,
                activeColor: Colors.blue.shade800,
                title: Text(entry.value, style: const TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w500)),
                onChanged: (val) {
                  if (val != null) setState(() => _singleSelectedScore = val);
                },
              ),
            );
          }).toList(),
        ],
      );
    }

    // ВАРІАНТ Б: ПРОТОКОЛ ЗАМІРІВ СУДИННИХ РЕАКЦІЙ (ОРТОСТАТИЧНИЙ ТА ТІЛТ ТЕСТИ)
    if (_scaleMeta.type == ScaleType.vitalsProtocol) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_scaleMeta.description, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          
          _buildVitalsCard(
            title: 'ФАЗА 1: Кліностаз (Пацієнт лежить на спині у спокої 5 хв)',
            hrController: _hrLyingController,
            sysController: _sysLyingController,
            diaController: _diaLyingController,
            accentColor: Colors.teal,
          ),
          const SizedBox(height: 16),
          
          _buildVitalsCard(
            title: 'ФАЗА 2: Ортостаз (Пацієнт впевнено стоїть, замір на 1-3 хв)',
            hrController: _hrStandingController,
            sysController: _sysStandingController,
            diaController: _diaStandingController,
            accentColor: Colors.deepOrange,
          ),
        ],
      );
    }

    // ВАРІАНТ В: БАГАТОПУНКТОВІ ОПИТУВАЛЬНИКИ (БЕРГ / БАРТЕЛ / FIM)
    return Column(
      children: _scaleMeta.items.map((item) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.instruction, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Divider(),
                ...item.scoreOptions.entries.map((opt) => RadioListTile<int>(
                      title: Text(opt.value, style: const TextStyle(fontSize: 13)),
                      value: opt.key,
                      groupValue: _selectedMultiScores[item.id],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMultiScores[item.id] = val);
                      },
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Допоміжний віджет картки для зняття фізіологічних показників
  Widget _buildVitalsCard({
    required String title,
    required TextEditingController hrController,
    required TextEditingController sysController,
    required TextEditingController diaController,
    required Color accentColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: accentColor.withOpacity(0.3))),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentColor)),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hrController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ЧСС (уд/хв)', border: OutlineInputBorder(), dense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: sysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'САТ (сист)', border: OutlineInputBorder(), dense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: diaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ДАТ (діаст)', border: OutlineInputBorder(), dense: true),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
