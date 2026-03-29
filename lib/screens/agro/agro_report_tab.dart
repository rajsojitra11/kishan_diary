import 'package:flutter/material.dart';

import '../../utils/localization.dart';
import '../../widgets/app_widgets.dart';

class AgroReportTab extends StatelessWidget {
  const AgroReportTab({
    super.key,
    required this.language,
    required this.report,
    required this.toDisplayDate,
  });

  final AppLanguage language;
  final Map<String, dynamic> report;
  final String Function(String? serverDate) toDisplayDate;

  @override
  Widget build(BuildContext context) {
    final summary = (report['summary'] as Map?)?.cast<String, dynamic>() ?? {};
    final rows = ((report['rows'] as List?) ?? [])
        .map((item) => (item as Map).cast<String, dynamic>())
        .toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        statCard(
          t(language, 'agroBillsTotal'),
          (summary['total_bills'] ?? 0).toString(),
          Colors.indigo,
        ),
        statCard(
          t(language, 'agroBillsPending'),
          (summary['pending_bills'] ?? 0).toString(),
          Colors.orange,
        ),
        statCard(
          t(language, 'agroBillsCompleted'),
          (summary['completed_bills'] ?? 0).toString(),
          Colors.green,
        ),
        statCard(
          t(language, 'agroAmountTotal'),
          '₹ ${((summary['total_amount'] ?? 0) as num).toStringAsFixed(2)}',
          Colors.blue,
        ),
        const SizedBox(height: 10),
        Text(
          t(language, 'agroReportRows'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (rows.isEmpty)
          Text(t(language, 'agroNoReportData'))
        else
          ...rows.map(
            (row) => Card(
              child: ListTile(
                title: Text(
                  '${row['farmer_name'] ?? '-'} • ₹ ${((row['amount'] ?? 0) as num).toStringAsFixed(2)}',
                ),
                subtitle: Text(
                  '${t(language, 'agroBillDate')}: ${toDisplayDate(row['bill_date']?.toString())}\n'
                  '${t(language, 'agroPaymentStatus')}: ${(row['payment_status'] == 'completed') ? t(language, 'agroCompleted') : t(language, 'agroPending')}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
      ],
    );
  }
}
