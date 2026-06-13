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
      name: 'Initial
