import 'package:flutter/material.dart';

import '../utils/api_service.dart';
import '../utils/localization.dart';

class FarmerBillsScreen extends StatefulWidget {
  const FarmerBillsScreen({super.key, required this.language});

  final AppLanguage language;

  @override
  State<FarmerBillsScreen> createState() => _FarmerBillsScreenState();
}

class _FarmerBillsScreenState extends State<FarmerBillsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _bills = [];

  @override
  void initState() {
    super.initState();
    _loadBills();
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

  Future<void> _loadBills() async {
    try {
      final bills = await ApiService.instance.getMyBills();
      if (!mounted) {
        return;
      }
      setState(() {
        _bills = bills;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'farmerBillsLoadError'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bills.isEmpty) {
      return Center(
        child: Text(t(widget.language, 'farmerNoBills')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _loadBills,
            icon: const Icon(Icons.refresh),
            label: Text(t(widget.language, 'agroRefresh')),
          ),
        ),
        ..._bills.map((bill) {
          final amount = (bill['amount'] as num?)?.toDouble() ?? 0;
          final status = bill['payment_status']?.toString() ?? 'pending';
          final statusLabel = status == 'completed'
              ? t(widget.language, 'agroCompleted')
              : t(widget.language, 'agroPending');
          final isCompleted = status == 'completed';
          final photoUrl = bill['bill_photo_url']?.toString();

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '₹ ${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withAlpha(28)
                              : Colors.orange.withAlpha(28),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${t(widget.language, 'agroBillDate')}: ${_toDisplayDate(bill['bill_date']?.toString())}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${t(widget.language, 'farmerBillFromAgro')}: ${bill['agro_owner_name'] ?? '-'} (${bill['agro_owner_mobile'] ?? '-'})',
                  ),
                  if ((bill['note']?.toString().trim().isNotEmpty ?? false)) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${t(widget.language, 'agroBillNote')}: ${bill['note']}',
                    ),
                  ],
                  if (photoUrl != null && photoUrl.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        photoUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 80,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
