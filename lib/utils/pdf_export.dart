import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

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
  List<Map<String, dynamic>> bills = const [],
  Map<String, String> dashboardNotes = const {},
}) async {
  final pageTitle = _pageTitle(language, navIndex);
  final fileName = 'kishan_diary_${_pageKey(navIndex)}.pdf';
  final pdfFonts = await _resolvePdfFonts();
  final baseFont = pdfFonts.base;
  final boldFont = pdfFonts.bold;

  final doc = pw.Document();
  final widgets = _buildPageWidgets(
    language: language,
    navIndex: navIndex,
    lands: lands,
    selectedLand: selectedLand,
    bills: bills,
    dashboardNotes: dashboardNotes,
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
  List<Map<String, dynamic>> bills = const [],
  Map<String, String> dashboardNotes = const {},
}) async {
  final pdfFonts = await _resolvePdfFonts();
  final baseFont = pdfFonts.base;
  final boldFont = pdfFonts.bold;
  final doc = pw.Document();

  final widgets = _buildAllDataWidgets(
    language: language,
    lands: lands,
    bills: bills,
    dashboardNotes: dashboardNotes,
  );

  if (widgets.isEmpty) {
    return false;
  }

  final title = _pdfAppTitle(language);
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
  required List<Map<String, dynamic>> bills,
  required Map<String, String> dashboardNotes,
}) {
  switch (navIndex) {
    case 0:
      return _buildHomeWidgets(
        language,
        lands,
        selectedLand,
        dashboardNotes: dashboardNotes,
        bills: bills,
      );
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
      return _buildBillsWidgets(language, bills);
    default:
      return const [];
  }
}

List<pw.Widget> _buildAllDataWidgets({
  required AppLanguage language,
  required List<Land> lands,
  required List<Map<String, dynamic>> bills,
  required Map<String, String> dashboardNotes,
}) {
  if (lands.isEmpty) {
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

    final diaryNote = dashboardNotes[_landDiaryKey(land)] ?? '';
    widgets.add(pw.SizedBox(height: 8));
    widgets.add(_sectionTitle(t(language, 'dashboardDiaryTitle')));
    widgets.add(
      pw.Text(
        diaryNote.isEmpty ? '-' : diaryNote,
        style: const pw.TextStyle(fontSize: 9.5),
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

  if (bills.isNotEmpty) {
    widgets.add(_sectionTitle(t(language, 'navBills')));
    widgets.add(
      _table(
        headers: [
          t(language, 'agroBillDate'),
          t(language, 'agroBillAmount'),
          t(language, 'agroPaymentStatus'),
          t(language, 'agroBillNote'),
          t(language, 'billSourceLabel'),
        ],
        rows: bills
            .map(
              (bill) => [
                _toDisplayDate(bill['bill_date']?.toString()),
                _toAmountText(bill['amount']),
                _billStatusLabel(language, bill['payment_status']?.toString()),
                bill['note']?.toString() ?? '',
                _billSourceLabel(language, bill['source']?.toString()),
              ],
            )
            .toList(),
      ),
    );
  }

  return widgets;
}

List<pw.Widget> _buildHomeWidgets(
  AppLanguage language,
  List<Land> lands,
  Land? selectedLand, {
  required Map<String, String> dashboardNotes,
  required List<Map<String, dynamic>> bills,
}) {
  if (lands.isEmpty && selectedLand == null) {
    return const [];
  }

  final widgets = <pw.Widget>[];

  if (selectedLand != null) {
    widgets.add(_sectionTitle(t(language, 'landDashboard')));
    widgets.add(
      _table(
        headers: [
          t(language, 'incomeLabel'),
          t(language, 'expensesLabel'),
          t(language, 'cropProductionLabel'),
          t(language, 'laborHoursLabel'),
        ],
        rows: [
          [
            selectedLand.income.toStringAsFixed(2),
            selectedLand.expenses.toStringAsFixed(2),
            selectedLand.cropProductionKg.toStringAsFixed(2),
            selectedLand.laborRupees.toStringAsFixed(2),
          ],
        ],
      ),
    );
    widgets.add(pw.SizedBox(height: 12));

    final diaryNote = dashboardNotes[_landDiaryKey(selectedLand)] ?? '';
    widgets.add(_sectionTitle(t(language, 'dashboardDiaryTitle')));
    widgets.add(
      pw.Text(
        diaryNote.isEmpty ? '-' : diaryNote,
        style: const pw.TextStyle(fontSize: 9.5),
      ),
    );
    widgets.add(pw.SizedBox(height: 10));

    if (bills.isNotEmpty) {
      widgets.add(_sectionTitle(t(language, 'navBills')));
      widgets.add(
        _table(
          headers: [
            t(language, 'agroBillDate'),
            t(language, 'agroBillAmount'),
            t(language, 'agroPaymentStatus'),
          ],
          rows: bills
              .map(
                (bill) => [
                  _toDisplayDate(bill['bill_date']?.toString()),
                  _toAmountText(bill['amount']),
                  _billStatusLabel(
                    language,
                    bill['payment_status']?.toString(),
                  ),
                ],
              )
              .toList(),
        ),
      );
      widgets.add(pw.SizedBox(height: 12));
    }
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

List<pw.Widget> _buildBillsWidgets(
  AppLanguage language,
  List<Map<String, dynamic>> bills,
) {
  if (bills.isEmpty) {
    return const [];
  }

  return [
    _sectionTitle(t(language, 'navBills')),
    _table(
      headers: [
        t(language, 'agroBillDate'),
        t(language, 'agroBillAmount'),
        t(language, 'agroPaymentStatus'),
        t(language, 'agroBillNote'),
        t(language, 'billSourceLabel'),
      ],
      rows: bills
          .map(
            (bill) => [
              _toDisplayDate(bill['bill_date']?.toString()),
              _toAmountText(bill['amount']),
              _billStatusLabel(language, bill['payment_status']?.toString()),
              bill['note']?.toString() ?? '',
              _billSourceLabel(language, bill['source']?.toString()),
            ],
          )
          .toList(),
    ),
  ];
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

Future<_PdfFonts> _resolvePdfFonts() async {
  // Prefer bundled fonts so Gujarati text renders correctly even without internet.
  try {
    final baseData = await rootBundle.load(
      'lib/assets/fonts/HindVadodara-Regular.ttf',
    );
    final boldData = await rootBundle.load(
      'lib/assets/fonts/HindVadodara-Bold.ttf',
    );
    return _PdfFonts(base: pw.Font.ttf(baseData), bold: pw.Font.ttf(boldData));
  } catch (_) {
    final onlineBase = await _resolvePdfBaseFont();
    final onlineBold = await _resolvePdfBoldFont(onlineBase);
    return _PdfFonts(base: onlineBase, bold: onlineBold);
  }
}

Future<pw.Font> _resolvePdfBoldFont(pw.Font fallback) async {
  try {
    return await PdfGoogleFonts.notoSansGujaratiBold();
  } catch (_) {
    return fallback;
  }
}

Future<pw.Font> _resolvePdfBaseFont() async {
  try {
    return await PdfGoogleFonts.notoSansGujaratiRegular();
  } catch (_) {
    return pw.Font.helvetica();
  }
}

class _PdfFonts {
  const _PdfFonts({required this.base, required this.bold});

  final pw.Font base;
  final pw.Font bold;
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
      return 'bills';
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
      return t(language, 'navBills');
    default:
      return t(language, 'navHome');
  }
}

String _toDisplayDate(String? serverDate) {
  if (serverDate == null || serverDate.trim().isEmpty) {
    return '-';
  }
  final parts = serverDate.split('-');
  if (parts.length != 3) {
    return serverDate;
  }
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

String _toAmountText(dynamic raw) {
  if (raw is num) {
    return raw.toDouble().toStringAsFixed(2);
  }
  final parsed = double.tryParse(raw?.toString() ?? '');
  return (parsed ?? 0.0).toStringAsFixed(2);
}

String _billStatusLabel(AppLanguage language, String? status) {
  final normalized = status?.toLowerCase() == 'completed'
      ? 'completed'
      : 'pending';
  return normalized == 'completed'
      ? t(language, 'agroCompleted')
      : t(language, 'agroPending');
}

String _billSourceLabel(AppLanguage language, String? source) {
  final normalized = source?.toLowerCase() == 'agro' ? 'agro' : 'farmer';
  return normalized == 'agro'
      ? t(language, 'farmerBillSourceAgro')
      : t(language, 'farmerBillSourceFarmer');
}

String _landDiaryKey(Land land) {
  if (land.id != null) {
    return 'id_${land.id}';
  }
  return '${land.name}|${land.location}|${land.size.toStringAsFixed(4)}';
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

String _pdfAppTitle(AppLanguage language) {
  if (language == AppLanguage.gujarati) {
    return 'કિશાન ડાયરી';
  }
  return t(language, 'appTitle');
}
