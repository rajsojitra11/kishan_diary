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
  bool _savingFarmerBill = false;
  List<Map<String, dynamic>> _bills = [];
  String _sourceFilter = 'farmer';
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

  String _toServerDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  double? _parseAmount(dynamic raw) {
    final normalized = raw?.toString().trim().replaceAll(',', '.') ?? '';
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  Future<void> _loadBills() async {
    if (!mounted) {
      return;
    }

    setState(() => _loading = true);

    try {
      final bills = await ApiService.instance.getMyBills(source: _sourceFilter);
      if (!mounted) {
        return;
      }

      final normalizedBills = bills.map((bill) {
        final rawSource = bill['source']?.toString().trim().toLowerCase();
        if (rawSource == 'agro' || rawSource == 'farmer') {
          return bill;
        }

        final agroName = bill['agro_owner_name']?.toString().trim() ?? '';
        final agroMobile = bill['agro_owner_mobile']?.toString().trim() ?? '';
        final inferredSource = (agroName.isNotEmpty || agroMobile.isNotEmpty)
            ? 'agro'
            : 'farmer';

        return {...bill, 'source': inferredSource};
      }).toList();

      setState(() {
        _bills = normalizedBills;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
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

  Future<void> _showAddFarmerBillDialog() async {
    final dateCtrl = TextEditingController(text: _toServerDate(DateTime.now()));
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var paymentStatus = 'pending';

    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> pickDate() async {
              final now = DateTime.now();
              final pickedDate = await showDatePicker(
                context: dialogContext,
                initialDate: now,
                firstDate: DateTime(1900),
                lastDate: DateTime(now.year + 30),
              );

              if (pickedDate == null) {
                return;
              }

              dateCtrl.text = _toServerDate(pickedDate);
              setDialogState(() {});
            }

            return AlertDialog(
              title: Text(t(widget.language, 'farmerAddBillTitle')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: dateCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: t(widget.language, 'agroBillDate'),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: pickDate,
                        ),
                      ),
                      onTap: pickDate,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: t(widget.language, 'agroBillAmount'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: paymentStatus,
                      decoration: InputDecoration(
                        labelText: t(widget.language, 'agroPaymentStatus'),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text(t(widget.language, 'agroPending')),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text(t(widget.language, 'agroCompleted')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() => paymentStatus = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteCtrl,
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: t(widget.language, 'agroBillNote'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(t(widget.language, 'cancelButton')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = _parseAmount(amountCtrl.text);
                    if (amount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            t(widget.language, 'farmerBillInvalidAmount'),
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'bill_date': dateCtrl.text.trim(),
                      'amount': amount,
                      'payment_status': paymentStatus,
                      'note': noteCtrl.text.trim(),
                    });
                  },
                  child: Text(t(widget.language, 'agroSaveBill')),
                ),
              ],
            );
          },
        );
      },
    );

    dateCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();

    if (payload == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() => _savingFarmerBill = true);

    try {
      await ApiService.instance.createFarmerBill(
        billDate: payload['bill_date'].toString(),
        paymentStatus: payload['payment_status'].toString(),
        amount: (payload['amount'] as num).toDouble(),
        note: payload['note']?.toString(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'farmerBillSaved'))),
      );
      await _loadBills();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'farmerBillsLoadError'))),
      );
    } finally {
      if (mounted) {
        setState(() => _savingFarmerBill = false);
      }
    }
  }

  Future<void> _toggleFarmerBillStatus(Map<String, dynamic> bill) async {
    if (bill['source']?.toString() != 'farmer') {
      return;
    }

    final billId = int.tryParse(bill['id']?.toString() ?? '');
    if (billId == null) {
      return;
    }

    final currentStatus = bill['payment_status']?.toString() == 'completed'
        ? 'completed'
        : 'pending';
    final nextStatus = currentStatus == 'completed' ? 'pending' : 'completed';
    final amount = _parseAmount(bill['amount']) ?? 0;

    try {
      await ApiService.instance.updateFarmerBill(
        billId: billId,
        billDate:
            bill['bill_date']?.toString() ?? _toServerDate(DateTime.now()),
        paymentStatus: nextStatus,
        amount: amount,
        note: bill['note']?.toString(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'farmerBillStatusUpdated'))),
      );
      await _loadBills();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _deleteFarmerBill(Map<String, dynamic> bill) async {
    if (bill['source']?.toString() != 'farmer') {
      return;
    }

    final billId = int.tryParse(bill['id']?.toString() ?? '');
    if (billId == null) {
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            content: Text(t(widget.language, 'farmerBillDeleteConfirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(t(widget.language, 'cancelButton')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(t(widget.language, 'deleteButton')),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    try {
      await ApiService.instance.deleteFarmerBill(billId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'farmerBillDeleted'))),
      );
      await _loadBills();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
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

    final sourceFilteredBills = _bills.where((bill) {
      final source = bill['source']?.toString().toLowerCase();

      if (_sourceFilter == 'farmer') {
        return source == 'farmer';
      }

      return source == 'agro';
    }).toList();

    final filteredBills = _statusFilter == 'all'
        ? sourceFilteredBills
        : sourceFilteredBills.where((bill) {
            final status = bill['payment_status']?.toString().toLowerCase();
            return status == _statusFilter;
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${t(widget.language, 'agroBillsTotal')}: ${filteredBills.length}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Center(
                  child: Text(t(widget.language, 'farmerBillSourceFarmer')),
                ),
                selected: _sourceFilter == 'farmer',
                onSelected: (_) {
                  if (_sourceFilter == 'farmer') {
                    return;
                  }
                  setState(() => _sourceFilter = 'farmer');
                  _loadBills();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: Center(
                  child: Text(t(widget.language, 'farmerBillSourceAgro')),
                ),
                selected: _sourceFilter == 'agro',
                onSelected: (_) {
                  if (_sourceFilter == 'agro') {
                    return;
                  }
                  setState(() => _sourceFilter = 'agro');
                  _loadBills();
                },
              ),
            ),
          ],
        ),
        if (_sourceFilter == 'farmer') ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _savingFarmerBill ? null : _showAddFarmerBillDialog,
              icon: const Icon(Icons.add),
              label: Text(t(widget.language, 'farmerAddBillButton')),
            ),
          ),
        ],
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
            final isFarmerBill = bill['source']?.toString() == 'farmer';
            final note = bill['note']?.toString() ?? '';

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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isFarmerBill
                                ? Colors.blue.withAlpha(24)
                                : Colors.brown.withAlpha(24),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isFarmerBill
                                ? t(widget.language, 'farmerBillSourceFarmer')
                                : t(widget.language, 'farmerBillSourceAgro'),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isFarmerBill
                                  ? Colors.blue.shade800
                                  : Colors.brown.shade800,
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
                      isFarmerBill
                          ? t(widget.language, 'farmerSelfBillLabel')
                          : '${t(widget.language, 'farmerBillFromAgro')}: ${bill['agro_owner_name'] ?? '-'} (${bill['agro_owner_mobile'] ?? '-'})',
                    ),
                    if (note.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('${t(widget.language, 'agroBillNote')}: $note'),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isFarmerBill) ...[
                          IconButton(
                            tooltip: t(widget.language, 'agroPaymentStatus'),
                            onPressed: () => _toggleFarmerBillStatus(bill),
                            icon: Icon(
                              isCompleted
                                  ? Icons.check_circle_outline
                                  : Icons.pending_actions_outlined,
                            ),
                          ),
                          IconButton(
                            tooltip: t(widget.language, 'deleteButton'),
                            onPressed: () => _deleteFarmerBill(bill),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ] else
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
