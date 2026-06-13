import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:re_hab_app/models/clinical_models.dart';
import 'smart_irp_engine.dart';

class PdfExportService {
  /// ДОКУМЕНТ 1: Формування Первинного плану реабілітації (на початку лікування)
  static Future<void> exportInitialPlan({
    required dynamic patient,
    required SmartIrpPlan irpPlan,
    required List<AssessmentResult> assessments,
  }) async {
    final pdf = pw.Document();
    
    // Завантажуємо шрифти з підтримкою української кирилиці
    final regularFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // Штамп закладу (імітація офіційного бланку МОЗ)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('ЗАТВЕРДЖЕНО МОЗ УКРАЇНИ\nПротокол надання реабілітаційної допомоги', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                pw.Text('Forma первинної фіксації ІРП', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              ],
            ),
            pw.SizedBox(height: 16),
            
            // Заголовок документа
            pw.Center(
              child: pw.Text(
                'ІНДИВІДУАЛЬНИЙ РЕАБІЛІТАЦІЙНИЙ ПЛАН (ІРП)',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Center(
              child: pw.Text('Етап: Первинне призначення та стратегія відновлення', style: pw.TextStyle(fontSize: 11, color: PdfColors.grey900)),
            ),
            pw.SizedBox(height: 20),

            // 1. ПАСПОРТНА ЧАСТИНА
            _buildPdfSectionTitle('1. Загальні відомості про пацієнта'),
            _buildPdfKeyValue('ПІБ Пацієнта:', patient.fullName),
            _buildPdfKeyValue('Дата народження:', '${patient.dateOfBirth.day}.${patient.dateOfBirth.month}.${patient.dateOfBirth.year}'),
            _buildPdfKeyValue('Запланована тривалість курсу:', '${patient.treatmentDays} днів лікувального протоколу'),
            pw.SizedBox(height: 12),

            // 2. КЛІНІЧНИЙ СТАТУС
            _buildPdfSectionTitle('2. Клінічний профіль на початку реабілітації'),
            _buildPdfKeyValue('Код МКХ-10:', patient.icdCode),
            _buildPdfKeyValue('Основний та супутній діагнози:', patient.diagnosis),
            _buildPdfKeyValue('Анамнестичні скарги:', patient.complaints ?? 'Скарги відсутні / не зафіксовані'),
            _buildPdfKeyValue('Очікування пацієнта від лікування:', patient.expectations ?? 'Сформульовано загальне відновлення функцій'),
            pw.SizedBox(height: 12),

            // 3. ПЕРВИННЕ ТЕСТУВАННЯ ЗА ШКАЛАМИ
            _buildPdfSectionTitle('3. Об\'єктивне тестування (Вхідні клінікометричні дані)'),
            if (assessments.isEmpty)
              pw.Paragraph(text: 'Інтерактивні об\'єктивні шкали на момент формування плану не проводилися. Оцінка проведена на основі загального соматичного статусу.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800))
            else
              pw.Column(
                children: assessments.map((res) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // ПОМИЛКУ ВИПРАВЛЕНО: bulletColor замінено на color
                        pw.Bullet(color: PdfColors.blue),
                        pw.SizedBox(width: 6),
                        pw.Expanded(
                          // ПОМИЛКУ ВИПРАВЛЕНО: res.scaleName замінено на res.scaleId
                          child: pw.Text('${res.scaleId}: ${res.interpretation} (Дата: ${res.date.day}.${res.date.month}.${res.date.year})', style: pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            pw.SizedBox(height: 12),

            // 4. SMART ЦІЛІ
            _buildPdfSectionTitle('4. Встановлені цілі реабілітації за критеріями SMART'),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.all(pw.Radius.circular(6))),
              child: pw.Text(irpPlan.smartGoals, style: pw.TextStyle(fontSize: 10, height: 1.3)),
            ),
            pw.SizedBox(height: 12),

            // 5. КЛІНІЧНІ ЗАСТЕРЕЖЕННЯ
            _buildPdfSectionTitle('5. Клінічні застереження та обмеження життєдіяльності'),
            pw.Text(irpPlan.clinicalPrecautions, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
            pw.SizedBox(height: 24),

            // ПІДПИСИ СТОРОН
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 120, 
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(width: 1, color: PdfColors.black))
                      )
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Підпис фізичного терапевта / лікаря', style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 120, 
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(width: 1, color: PdfColors.black))
                      )
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('З планом ознайомлений (пацієнт)', style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Викликаємо системне діалогове вікно друку або збереження у PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Initial_Plan_${patient.fullName.replaceAll(' ', '_')}.pdf',
    );
  }

  /// ДОКУМЕНТ 2: Формування Виписного епікризу / Витягу з ІРП (в кінці лікування)
  static Future<void> exportDischargeSummary({
    required dynamic patient,
    required SmartIrpPlan irpPlan,
    required List<AssessmentResult> assessments,
    required Set<int> completedDays,
  }) async {
    final pdf = pw.Document();
    
    final regularFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final int totalDays = patient.treatmentDays ?? 10;
    final double complianceRate = totalDays > 0 ? (completedDays.length / totalDays) * 100 : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // Шапка документа
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('МЕДИЧНА ДОКУМЕНТАЦІЯ ЗА СТАНДАРТАМИ НСЗУ\nКод форми за ДКУД', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                pw.Text('Витяг з медичної карти / Виписка з ІРП', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              ],
            ),
            pw.SizedBox(height: 16),
            
            pw.Center(
              child: pw.Text(
                'ВИПИСНИЙ ЕПІКРИЗ ІЗ КАРТКИ РЕАБІЛІТАЦІЇ',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 20),

            // ПАСПОРТНІ ТА КЛІНІЧНІ ДАНІ
            _buildPdfSectionTitle('Паспортні та анамнестичні відомості пацієнта'),
            _buildPdfKeyValue('ПІБ Пацієнта:', patient.fullName),
            _buildPdfKeyValue('Діагноз / Код МКХ-10:', '[${patient.icdCode}] ${patient.diagnosis}'),
            _buildPdfKeyValue('Скарги при надходженні:', patient.complaints ?? 'Не зафіксовані'),
            pw.SizedBox(height: 12),

            // ОЦІНКА ДИНАМІКИ ВИКОНАННЯ ПРОГРАМИ
            _buildPdfSectionTitle('Оцінка комплаєнсу та виконання реабілітаційних заходів'),
            _buildPdfKeyValue('Загальний обсяг курсу:', '$totalDays днів реабілітаційного сеансу'),
            _buildPdfKeyValue('Фактично виконано занять:', '${completedDays.length} днів із внесенням у чек-ліст'),
            _buildPdfKeyValue('Рівень дотримання протоколу (Комплаєнс):', '${complianceRate.toStringAsFixed(1)}% виконання плану'),
            pw.SizedBox(height: 12),

            // МОЗ СТАНДАРТ: ДИНАМІКА ШКАЛ
            _buildPdfSectionTitle('Клінікометричні показники та динаміка за шкалами ВООЗ/МОЗ'),
            if (assessments.isEmpty)
              pw.Paragraph(text: 'Для даного пацієнта не зафіксовано повторних або первинних тестувань у базі даних додатку.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700))
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Назва інструменту / шкали', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Клінічний результат та інтерпретація бала', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    ],
                  ),
                  ...assessments.map((res) {
                    return pw.TableRow(
                      children: [
                        // ПОМИЛКУ ВИПРАВЛЕНО: res.scaleName замінено на res.scaleId
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(res.scaleId, style: pw.TextStyle(fontSize: 9))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(res.interpretation, style: pw.TextStyle(fontSize: 9))),
                      ],
                    );
                  }).toList(),
                ],
              ),
            pw.SizedBox(height: 12),

            // ДОСЯГНЕННЯ SMART ЦІЛЕЙ ТА РЕКОМЕНДАЦІЇ
            _buildPdfSectionTitle('Статус досягнення SMART-цілей реабілітації'),
            pw.Paragraph(
              text: complianceRate >= 80.0
                  ? '🎯 Заплановані короткострокові та довгострокові SMART-цілі досягнуті у повному обсязі. Спостерігається виражена позитивна рухова та соматична динаміка, відновлення рівня самообслуговування пацієнта.'
                  : '⚠️ Цілі досягнуті частково. Потрібне подовження термінів лікування або адаптація вправ через пропуски занять чи соматичну нестабільність пацієнта.',
              style: pw.TextStyle(fontSize: 10, height: 1.3),
            ),
            pw.SizedBox(height: 12),

            _buildPdfSectionTitle('Рекомендації для подальшого амбулаторного етапу терапії'),
            pw.Bullet(text: 'Продовжити щоденне виконання індивідуального комплексу ЛФК у домашніх умовах.', style: pw.TextStyle(fontSize: 9)),
            pw.Bullet(text: 'Дотримуватись ортопедичного або неврологічного режиму безпеки руху (контроль пози тіла, уникнення перевантажень).', style: pw.TextStyle(fontSize: 9)),
            pw.Bullet(text: 'Повторний огляд мультидисциплінарною реабілітаційною командою (МРК) через 3 місяці.', style: pw.TextStyle(fontSize: 9)),
            if (patient.diagnosis.toString().toLowerCase().contains('нирк') || patient.icdCode.toString().startsWith('N18'))
              pw.Bullet(text: 'Суворий супутній контроль нефролога, щоденний моніторинг АТ, ваги та набряків кінцівок.', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
            
            pw.SizedBox(height: 32),

            // Завірення документа
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Дата виписки: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year} р.', style: pw.TextStyle(fontSize: 10)),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 150, 
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(width: 1, color: PdfColors.black))
                      )
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Підпис голови МРК / Фізичного терапевта', style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Discharge_Summary_${patient.fullName.replaceAll(' ', '_')}.pdf',
    );
  }

  /// Внутрішній допоміжний метод для побудови заголовків секцій у PDF
  static pw.Widget _buildPdfSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10, bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
      ),
    );
  }

  /// Внутрішній допоміжний метод для рядків типу Ключ: Значення у PDF
  static pw.Widget _buildPdfKeyValue(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$key ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }
}
