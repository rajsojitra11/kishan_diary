import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/animal.dart';
import '../models/crop_entry.dart';
import '../models/expense_entry.dart';
import '../models/income_entry.dart';
import '../models/land.dart';
import '../models/labor_entry.dart';
import '../models/upad_entry.dart';
import 'localization.dart';

Future<bool> exportCurrentPagePdf({
  required AppLanguage language,
  required int navIndex,
  required List<Land> lands,
  required Land? selectedLand,
  required List<Animal> animals,
}) async {
  final pageTitle = _pageTitle(language, navIndex);
  final fileName = 'kishan_diary_${_pageKey(navIndex)}.pdf';
  final baseFont = await _resolvePdfBaseFont();
  final boldFont = await _resolvePdfBoldFont(baseFont);

  final doc = pw.Document();
  final widgets = _buildPageWidgets(
    language: language,
    navIndex: navIndex,
    lands: lands,
    selectedLand: selectedLand,
    animals: animals,
  );

  if (widgets.isEmpty) {
    return false;
  }

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
      ),
      build: (context) => [
        pw.Text(
          pageTitle,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green800,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          '${t(language, 'pdfGeneratedOn')}: ${DateTime.now().toLocal()}',
          style: pw.TextStyle(font: baseFont, fontSize: 10),
        ),
        pw.SizedBox(height: 12),
        ...widgets,
      ],
    ),
  );

  final bytes = await doc.save();

  await Share.shareXFiles(
    [
      XFile.fromData(
        Uint8List.fromList(bytes),
        mimeType: 'application/pdf',
        name: fileName,
      ),
    ],
    subject: pageTitle,
    text: pageTitle,
  );

  return true;
}

Future<bool> exportAllDataPdf({
  required AppLanguage language,
  required List<Land> lands,
  required List<Animal> animals,
}) async {
  final baseFont = await _resolvePdfBaseFont();
  final boldFont = await _resolvePdfBoldFont(baseFont);
  final doc = pw.Document();

  final widgets = _buildAllDataWidgets(
    language: language,
    lands: lands,
    animals: animals,
  );

  if (widgets.isEmpty) {
    return false;
  }

  final title = t(language, 'appTitle');
  final reportTitle = t(language, 'pdfAllDataTitle');
  final generatedLabel = t(language, 'pdfGeneratedOn');

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
      ),
      build: (context) => [
        pw.Text(
          '$title • $reportTitle',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green800,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          '$generatedLabel: ${DateTime.now().toLocal()}',
          style: pw.TextStyle(font: baseFont, fontSize: 10),
        ),
        pw.SizedBox(height: 12),
        ...widgets,
      ],
    ),
  );

  final bytes = await doc.save();

  await Share.shareXFiles(
    [
      XFile.fromData(
        Uint8List.fromList(bytes),
        mimeType: 'application/pdf',
        name: 'kishan_diary_all_data.pdf',
      ),
    ],
    subject: '$title • $reportTitle',
    text: '$title • $reportTitle',
  );

  return true;
}

List<pw.Widget> _buildPageWidgets({
  required AppLanguage language,
  required int navIndex,
  required List<Land> lands,
  required Land? selectedLand,
  required List<Animal> animals,
}) {
  switch (navIndex) {
    case 0:
      return _buildHomeWidgets(language, lands, selectedLand, animals);
    case 1:
      return selectedLand == null
          ? const []
          : _buildIncomeWidgets(language, selectedLand);
    case 2:
      return selectedLand == null
          ? const []
          : _buildExpenseWidgets(language, selectedLand);
    case 3:
      return selectedLand == null
          ? const []
          : _buildCropWidgets(language, selectedLand);
    case 4:
      return selectedLand == null
          ? const []
          : _buildLaborWidgets(language, selectedLand);
    case 5:
      return _buildAnimalWidgets(language, animals);
    default:
      return const [];
  }
}

List<pw.Widget> _buildAllDataWidgets({
  required AppLanguage language,
  required List<Land> lands,
  required List<Animal> animals,
}) {
  if (lands.isEmpty && animals.isEmpty) {
    return const [];
  }

  final widgets = <pw.Widget>[];

  if (lands.isNotEmpty) {
    widgets.add(_sectionTitle(t(language, 'selectLandHeading')));
    widgets.add(
      _table(
        headers: [
          t(language, 'landName'),
          t(language, 'landSize'),
          t(language, 'location'),
        ],
        rows: lands
            .map(
              (land) => [
                land.name,
                land.size.toStringAsFixed(2),
                land.location,
              ],
            )
            .toList(),
      ),
    );
    widgets.add(pw.SizedBox(height: 12));
  }

  for (final land in lands) {
    final totalIncome = land.incomeEntries.isNotEmpty
        ? land.incomeEntries.fold(0.0, (sum, item) => sum + item.amount)
        : land.income;
    final laborTotal = land.laborEntries.isNotEmpty
        ? land.laborEntries.fold(0.0, (sum, item) => sum + item.total)
        : land.laborRupees;
    final totalExpenseEntries = land.expenseEntries.isNotEmpty
        ? land.expenseEntries.fold(0.0, (sum, item) => sum + item.amount)
        : land.expenses;
    final totalExpense = totalExpenseEntries + laborTotal;
    final totalCrop = land.cropEntries.isNotEmpty
        ? land.cropEntries.fold(0.0, (sum, item) => sum + item.cropWeightKg)
        : land.cropProductionKg;

    widgets.add(_sectionTitle('${t(language, 'landName')}: ${land.name}'));
    widgets.add(
      _table(
        headers: [
          t(language, 'incomeLabel'),
          t(language, 'expensesLabel'),
          t(language, 'profitLabel'),
          t(language, 'cropProductionLabel'),
        ],
        rows: [
          [
            totalIncome.toStringAsFixed(2),
            totalExpense.toStringAsFixed(2),
            (totalIncome - totalExpense).toStringAsFixed(2),
            totalCrop.toStringAsFixed(2),
          ],
        ],
      ),
    );

    if (land.incomeEntries.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 8));
      widgets.add(_sectionTitle(t(language, 'navIncome')));
      widgets.add(
        _table(
          headers: [
            t(language, 'incomeTypeLabel'),
            t(language, 'incomeAmountLabel'),
            t(language, 'incomeDateLabel'),
            t(language, 'incomeNoteListLabel'),
          ],
          rows: land.incomeEntries
              .map(
                (entry) => [
                  _localizedTypeLabel(language, entry.type),
                  entry.amount.toStringAsFixed(2),
                  entry.date,
                  entry.note,
                ],
              )
              .toList(),
        ),
      );
    }

    if (land.expenseEntries.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 8));
      widgets.add(_sectionTitle(t(language, 'navExpense')));
      widgets.add(
        _table(
          headers: [
            t(language, 'expenseTypeLabel'),
            t(language, 'expenseAmountLabel'),
            t(language, 'expenseDateLabel'),
            t(language, 'expenseNoteListLabel'),
          ],
          rows: land.expenseEntries
              .map(
                (entry) => [
                  _localizedTypeLabel(language, entry.type),
                  entry.amount.toStringAsFixed(2),
                  entry.date,
                  entry.note,
                ],
              )
              .toList(),
        ),
      );
    }

    if (land.cropEntries.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 8));
      widgets.add(_sectionTitle(t(language, 'navCrop')));
      widgets.add(
        _table(
          headers: [
            t(language, 'cropType'),
            t(language, 'landSize'),
            t(language, 'cropWeight'),
            t(language, 'weightUnit'),
          ],
          rows: land.cropEntries
              .map(
                (entry) => [
                  _localizedTypeLabel(language, entry.cropType),
                  entry.landSize.toStringAsFixed(2),
                  entry.cropWeight.toStringAsFixed(2),
                  entry.weightUnit == 'man'
                      ? t(language, 'weightUnitMan')
                      : t(language, 'weightUnitKg'),
                ],
              )
              .toList(),
        ),
      );
    }

    if (land.laborEntries.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 8));
      widgets.add(_sectionTitle(t(language, 'navLabor')));
      widgets.add(
        _table(
          headers: [
            t(language, 'laborName'),
            t(language, 'laborMobile'),
            t(language, 'laborDay'),
            t(language, 'laborDailyWage'),
            t(language, 'laborTotalWage'),
          ],
          rows: land.laborEntries
              .map(
                (entry) => [
                  entry.name,
                  entry.mobile,
                  _formatDays(entry.days),
                  entry.dailyRate.toStringAsFixed(2),
                  entry.total.toStringAsFixed(2),
                ],
              )
              .toList(),
        ),
      );
    }

    if (land.upadEntries.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 8));
      widgets.add(_sectionTitle(t(language, 'upadSectionTitle')));
      widgets.add(
        _table(
          headers: [
            t(language, 'laborName'),
            t(language, 'upadAmount'),
            t(language, 'upadDate'),
            t(language, 'upadNote'),
          ],
          rows: land.upadEntries
              .map(
                (entry) => [
                  entry.laborName,
                  entry.amount.toStringAsFixed(2),
                  entry.date,
                  entry.note,
                ],
              )
              .toList(),
        ),
      );
    }

    widgets.add(pw.SizedBox(height: 12));
  }

  if (animals.isNotEmpty) {
    widgets.add(_sectionTitle(t(language, 'navAnimal')));
    widgets.add(
      _table(
        headers: [
          t(language, 'animalNameLabel'),
          t(language, 'animalTotalAmountLabel'),
          t(language, 'animalTotalMilkLabel'),
        ],
        rows: animals
            .map(
              (animal) => [
                animal.name,
                animal.totalAmount.toStringAsFixed(2),
                animal.totalMilk.toStringAsFixed(2),
              ],
            )
            .toList(),
      ),
    );

    for (final animal in animals) {
      if (animal.records.isEmpty) {
        continue;
      }

      widgets.add(pw.SizedBox(height: 8));
      widgets.add(
        _sectionTitle('${animal.name} • ${t(language, 'animalRecordsLabel')}'),
      );
      widgets.add(
        _table(
          headers: [
            t(language, 'animalDateLabel'),
            t(language, 'animalAmountLabel'),
            t(language, 'animalMilkLabel'),
          ],
          rows: animal.records
              .map(
                (record) => [
                  record.date,
                  record.amount.toStringAsFixed(2),
                  record.milk.toStringAsFixed(2),
                ],
              )
              .toList(),
        ),
      );
    }
  }

  return widgets;
}

List<pw.Widget> _buildHomeWidgets(
  AppLanguage language,
  List<Land> lands,
  Land? selectedLand,
  List<Animal> animals,
) {
  if (lands.isEmpty && selectedLand == null) {
    return const [];
  }

  final widgets = <pw.Widget>[];

  if (selectedLand != null) {
    final animalIncome = animals.fold(
      0.0,
      (sum, animal) => sum + animal.totalAmount,
    );

    widgets.add(_sectionTitle(t(language, 'landDashboard')));
    widgets.add(
      _table(
        headers: [
          t(language, 'incomeLabel'),
          t(language, 'expensesLabel'),
          t(language, 'cropProductionLabel'),
          t(language, 'laborHoursLabel'),
          t(language, 'animalIncomeLabel'),
        ],
        rows: [
          [
            selectedLand.income.toStringAsFixed(2),
            selectedLand.expenses.toStringAsFixed(2),
            selectedLand.cropProductionKg.toStringAsFixed(2),
            selectedLand.laborRupees.toStringAsFixed(2),
            animalIncome.toStringAsFixed(2),
          ],
        ],
      ),
    );
    widgets.add(pw.SizedBox(height: 12));
  }

  if (lands.isNotEmpty) {
    widgets.add(_sectionTitle(t(language, 'selectLandHeading')));
    widgets.add(
      _table(
        headers: [
          t(language, 'landName'),
          t(language, 'landSize'),
          t(language, 'location'),
        ],
        rows: lands
            .map(
              (land) => [
                land.name,
                land.size.toStringAsFixed(2),
                land.location,
              ],
            )
            .toList(),
      ),
    );
  }

  return widgets;
}

List<pw.Widget> _buildIncomeWidgets(AppLanguage language, Land land) {
  final records = land.incomeEntries;
  if (records.isEmpty) {
    return const [];
  }

  return [
    _sectionTitle('${t(language, 'navIncome')} • ${land.name}'),
    _table(
      headers: [
        t(language, 'incomeTypeLabel'),
        t(language, 'incomeAmountLabel'),
        t(language, 'incomeDateLabel'),
        t(language, 'incomeNoteListLabel'),
      ],
      rows: records
          .map(
            (IncomeEntry entry) => [
              t(language, entry.type),
              entry.amount.toStringAsFixed(2),
              entry.date,
              entry.note,
            ],
          )
          .toList(),
    ),
  ];
}

List<pw.Widget> _buildExpenseWidgets(AppLanguage language, Land land) {
  final records = land.expenseEntries;
  if (records.isEmpty) {
    return const [];
  }

  return [
    _sectionTitle('${t(language, 'navExpense')} • ${land.name}'),
    _table(
      headers: [
        t(language, 'expenseTypeLabel'),
        t(language, 'expenseAmountLabel'),
        t(language, 'expenseDateLabel'),
        t(language, 'expenseNoteListLabel'),
      ],
      rows: records
          .map(
            (ExpenseEntry entry) => [
              t(language, entry.type),
              entry.amount.toStringAsFixed(2),
              entry.date,
              entry.note,
            ],
          )
          .toList(),
    ),
  ];
}

List<pw.Widget> _buildCropWidgets(AppLanguage language, Land land) {
  final records = land.cropEntries;
  if (records.isEmpty) {
    return const [];
  }

  return [
    _sectionTitle('${t(language, 'navCrop')} • ${land.name}'),
    _table(
      headers: [
        t(language, 'cropType'),
        t(language, 'landSize'),
        t(language, 'cropWeight'),
        t(language, 'weightUnit'),
      ],
      rows: records
          .map(
            (CropEntry entry) => [
              t(language, entry.cropType),
              entry.landSize.toStringAsFixed(2),
              entry.cropWeight.toStringAsFixed(2),
              entry.weightUnit == 'man'
                  ? t(language, 'weightUnitMan')
                  : t(language, 'weightUnitKg'),
            ],
          )
          .toList(),
    ),
  ];
}

List<pw.Widget> _buildLaborWidgets(AppLanguage language, Land land) {
  if (land.laborEntries.isEmpty && land.upadEntries.isEmpty) {
    return const [];
  }

  final widgets = <pw.Widget>[
    _sectionTitle('${t(language, 'navLabor')} • ${land.name}'),
  ];

  if (land.laborEntries.isNotEmpty) {
    widgets.add(
      _table(
        headers: [
          t(language, 'laborName'),
          t(language, 'laborMobile'),
          t(language, 'laborDay'),
          t(language, 'laborDailyWage'),
          t(language, 'laborTotalWage'),
        ],
        rows: land.laborEntries
            .map(
              (LaborEntry entry) => [
                entry.name,
                entry.mobile,
                _formatDays(entry.days),
                entry.dailyRate.toStringAsFixed(2),
                entry.total.toStringAsFixed(2),
              ],
            )
            .toList(),
      ),
    );
  }

  if (land.upadEntries.isNotEmpty) {
    widgets.add(pw.SizedBox(height: 10));
    widgets.add(_sectionTitle(t(language, 'upadSectionTitle')));
    widgets.add(
      _table(
        headers: [
          t(language, 'laborName'),
          t(language, 'upadAmount'),
          t(language, 'upadDate'),
          t(language, 'upadNote'),
        ],
        rows: land.upadEntries
            .map(
              (UpadEntry entry) => [
                entry.laborName,
                entry.amount.toStringAsFixed(2),
                entry.date,
                entry.note,
              ],
            )
            .toList(),
      ),
    );
  }

  return widgets;
}

List<pw.Widget> _buildAnimalWidgets(
  AppLanguage language,
  List<Animal> animals,
) {
  if (animals.isEmpty) {
    return const [];
  }

  final widgets = <pw.Widget>[
    _sectionTitle(t(language, 'navAnimal')),
    _table(
      headers: [
        t(language, 'animalNameLabel'),
        t(language, 'animalTotalAmountLabel'),
        t(language, 'animalTotalMilkLabel'),
      ],
      rows: animals
          .map(
            (animal) => [
              animal.name,
              animal.totalAmount.toStringAsFixed(2),
              animal.totalMilk.toStringAsFixed(2),
            ],
          )
          .toList(),
    ),
  ];

  for (final animal in animals) {
    if (animal.records.isEmpty) {
      continue;
    }

    widgets.add(pw.SizedBox(height: 10));
    widgets.add(
      _sectionTitle('${animal.name} ${t(language, 'animalRecordsLabel')}'),
    );
    widgets.add(
      _table(
        headers: [
          t(language, 'animalDateLabel'),
          t(language, 'animalAmountLabel'),
          t(language, 'animalMilkLabel'),
        ],
        rows: animal.records
            .map(
              (record) => [
                record.date,
                record.amount.toStringAsFixed(2),
                record.milk.toStringAsFixed(2),
              ],
            )
            .toList(),
      ),
    );
  }

  return widgets;
}

pw.Widget _sectionTitle(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 13,
        color: PdfColors.green900,
      ),
    ),
  );
}

pw.Widget _table({
  required List<String> headers,
  required List<List<String>> rows,
}) {
  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: rows,
    border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 10.5,
      color: PdfColors.white,
    ),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
    rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
    oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    cellStyle: const pw.TextStyle(fontSize: 9.5),
    cellAlignment: pw.Alignment.centerLeft,
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
  );
}

Future<pw.Font> _resolvePdfBaseFont() async {
  try {
    return await PdfGoogleFonts.notoSansGujaratiRegular();
  } catch (_) {
    return pw.Font.helvetica();
  }
}

Future<pw.Font> _resolvePdfBoldFont(pw.Font fallback) async {
  try {
    return await PdfGoogleFonts.notoSansGujaratiBold();
  } catch (_) {
    return fallback;
  }
}

String _pageKey(int navIndex) {
  switch (navIndex) {
    case 1:
      return 'income';
    case 2:
      return 'expense';
    case 3:
      return 'crop';
    case 4:
      return 'labor';
    case 5:
      return 'animal';
    default:
      return 'home';
  }
}

String _pageTitle(AppLanguage language, int navIndex) {
  switch (navIndex) {
    case 1:
      return t(language, 'navIncome');
    case 2:
      return t(language, 'navExpense');
    case 3:
      return t(language, 'navCrop');
    case 4:
      return t(language, 'navLabor');
    case 5:
      return t(language, 'navAnimal');
    default:
      return t(language, 'navHome');
  }
}

String _formatDays(double days) {
  if (days == days.truncateToDouble()) {
    return days.toInt().toString();
  }
  return days.toString();
}

String _localizedTypeLabel(AppLanguage language, String keyOrLabel) {
  final localized = t(language, keyOrLabel);
  if (localized == keyOrLabel) {
    return keyOrLabel;
  }
  return localized;
}
