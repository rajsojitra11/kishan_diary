import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/localization.dart';
import '../../widgets/app_widgets.dart';

class AgroReportTab extends ConsumerStatefulWidget {
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
  ConsumerState<AgroReportTab> createState() => _AgroReportTabState();
}

class _AgroReportTabState extends ConsumerState<AgroReportTab> {
  String _statusFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final summary =
        (widget.report['summary'] as Map?)?.cast<String, dynamic>() ?? {};
    final rows = ((widget.report['rows'] as List?) ?? [])
        .map((item) => (item as Map).cast<String, dynamic>())
        .toList();

    final filteredRows = rows.where((row) {
      final status = row['payment_status']?.toString().toLowerCase() ?? '';
      if (_statusFilter != 'all' && status != _statusFilter) {
        return false;
      }

      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }

      final farmerName = row['farmer_name']?.toString().toLowerCase() ?? '';
      final farmerMobile =
          row['farmer_mobile']?.toString().toLowerCase() ?? '';
      return farmerName.contains(query) || farmerMobile.contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        statCard(
          t(widget.language, 'agroBillsTotal'),
          (summary['total_bills'] ?? 0).toString(),
          Colors.indigo,
        ),
        statCard(
          t(widget.language, 'agroBillsPending'),
          (summary['pending_bills'] ?? 0).toString(),
          Colors.orange,
        ),
        statCard(
          t(widget.language, 'agroBillsCompleted'),
          (summary['completed_bills'] ?? 0).toString(),
          Colors.green,
        ),
        statCard(
          t(widget.language, 'agroAmountTotal'),
          '₹ ${((summary['total_amount'] ?? 0) as num).toStringAsFixed(2)}',
          Colors.blue,
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: t(widget.language, 'agroSearchFarmerHint'),
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text(t(widget.language, 'incomeTypeAll')),
                selected: _statusFilter == 'all',
                onSelected: (_) => setState(() => _statusFilter = 'all'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(t(widget.language, 'agroPending')),
                selected: _statusFilter == 'pending',
                onSelected: (_) => setState(() => _statusFilter = 'pending'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(t(widget.language, 'agroCompleted')),
                selected: _statusFilter == 'completed',
                onSelected: (_) => setState(() => _statusFilter = 'completed'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          t(widget.language, 'agroReportRows'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (filteredRows.isEmpty)
          Text(t(widget.language, 'agroNoReportData'))
        else
          ...filteredRows.map(
            (row) => Card(
              child: ListTile(
                title: Text(
                  '${row['farmer_name'] ?? '-'} • ₹ ${((row['amount'] ?? 0) as num).toStringAsFixed(2)}',
                ),
                subtitle: Text(
                  '${t(widget.language, 'agroBillDate')}: ${widget.toDisplayDate(row['bill_date']?.toString())}\n'
                  '${t(widget.language, 'agroPaymentStatus')}: ${(row['payment_status'] == 'completed') ? t(widget.language, 'agroCompleted') : t(widget.language, 'agroPending')}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
      ],
    );
  }
}
