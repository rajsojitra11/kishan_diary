import 'package:flutter/material.dart';

import '../utils/api_service.dart';
import '../utils/localization.dart';
import '../widgets/cached_network_image_view.dart';

class FarmerBillsScreen extends StatefulWidget {
  const FarmerBillsScreen({super.key, required this.language});

  final AppLanguage language;

  @override
  State<FarmerBillsScreen> createState() => _FarmerBillsScreenState();
}

class _FarmerBillsScreenState extends State<FarmerBillsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _bills = [];
  String _statusFilter = 'all';

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

  void _showBillImageDialog(String photoUrl) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t(widget.language, 'viewBillTitle'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 450),
                  child: InteractiveViewer(
                    child: CachedNetworkImageView(
                      imageUrl: photoUrl,
                      fit: BoxFit.contain,
                      maxWidthDiskCache: 1800,
                      maxHeightDiskCache: 1800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(t(widget.language, 'cancelButton')),
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bills.isEmpty) {
      return Center(
        child: Text(t(widget.language, 'farmerNoBills')),
      );
    }

    final filteredBills = _statusFilter == 'all'
        ? _bills
        : _bills.where((bill) {
            final status = bill['payment_status']?.toString().toLowerCase();
            return status == _statusFilter;
          }).toList();

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
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${t(widget.language, 'agroBillsTotal')}: ${_bills.length}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
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
        if (filteredBills.isEmpty)
          Center(child: Text(t(widget.language, 'agroNoBills')))
        else
          ...filteredBills.map((bill) {
          final amount = (bill['amount'] as num?)?.toDouble() ?? 0;
          final status = bill['payment_status']?.toString() ?? 'pending';
          final statusLabel = status == 'completed'
              ? t(widget.language, 'agroCompleted')
              : t(widget.language, 'agroPending');
          final isCompleted = status == 'completed';
          final photoUrl = bill['bill_photo_url']?.toString();
          final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

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
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: t(widget.language, 'viewBillTitle'),
                        onPressed: hasPhoto
                            ? () => _showBillImageDialog(photoUrl)
                            : null,
                        icon: const Icon(Icons.remove_red_eye_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
