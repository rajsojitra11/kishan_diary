import 'package:flutter/material.dart';

import '../../utils/api_service.dart';
import '../../utils/localization.dart';
import '../../widgets/cached_network_image_view.dart';

class AgroFarmerBillsScreen extends StatefulWidget {
  const AgroFarmerBillsScreen({
    super.key,
    required this.language,
    required this.farmerId,
    required this.farmerName,
    required this.farmerMobile,
  });

  final AppLanguage language;
  final int farmerId;
  final String farmerName;
  final String farmerMobile;

  @override
  State<AgroFarmerBillsScreen> createState() => _AgroFarmerBillsScreenState();
}

class _AgroFarmerBillsScreenState extends State<AgroFarmerBillsScreen> {
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

  DateTime? _parseDisplayDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime.tryParse(
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
    );
  }

  String _formatDisplayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _showEditBillDialog(Map<String, dynamic> bill) async {
    final billId = bill['id'];
    if (billId is! int) {
      return;
    }

    final amountCtrl = TextEditingController(
      text: ((bill['amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2),
    );
    final dateCtrl = TextEditingController(
      text: _toDisplayDate(bill['bill_date']?.toString()),
    );
    final noteCtrl = TextEditingController(text: bill['note']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    String paymentStatus = bill['payment_status']?.toString() == 'completed'
        ? 'completed'
        : 'pending';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t(widget.language, 'agroEditBill')),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: dateCtrl,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: t(widget.language, 'agroBillDate'),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: dialogContext,
                                initialDate:
                                    _parseDisplayDate(dateCtrl.text) ??
                                    DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                dateCtrl.text = _formatDisplayDate(pickedDate);
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return t(widget.language, 'validationSelectDate');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: t(widget.language, 'agroBillAmount'),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.currency_rupee),
                        ),
                        validator: (value) {
                          final parsed =
                              double.tryParse((value ?? '').trim()) ?? 0;
                          if (parsed <= 0) {
                            return t(widget.language, 'validationEnterPositiveNumber');
                          }
                          return null;
                        },
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
                          if (value != null) {
                            setDialogState(() => paymentStatus = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: noteCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: t(widget.language, 'agroBillNote'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(t(widget.language, 'cancelButton')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }

                    final amount =
                        double.tryParse(amountCtrl.text.trim()) ?? 0.0;

                    try {
                      await ApiService.instance.updateAgroBill(
                        billId: billId,
                        farmerId: widget.farmerId,
                        billDate: dateCtrl.text.trim(),
                        paymentStatus: paymentStatus,
                        amount: amount,
                        note: noteCtrl.text.trim(),
                      );

                      if (!dialogContext.mounted) {
                        return;
                      }
                      Navigator.pop(dialogContext);
                      await _loadBills();
                    } on ApiException catch (error) {
                      if (!dialogContext.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(error.message)),
                      );
                    }
                  },
                  child: Text(t(widget.language, 'saveButton')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadBills() async {
    setState(() => _loading = true);
    try {
      final payload = await ApiService.instance.getAgroBills(
        farmerId: widget.farmerId,
      );
      final rows = ((payload['bills'] as List?) ?? [])
          .map((item) => (item as Map).cast<String, dynamic>())
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _bills = rows;
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
        const SnackBar(content: Text('Failed to load farmer bills.')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.farmerName} • ${widget.farmerMobile}'),
        actions: [
          IconButton(
            onPressed: _loadBills,
            icon: const Icon(Icons.refresh),
            tooltip: t(widget.language, 'agroRefresh'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
          ? Center(child: Text(t(widget.language, 'agroNoBills')))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: _bills.map((bill) {
                final amount = (bill['amount'] as num?)?.toDouble() ?? 0;
                final status = bill['payment_status']?.toString() ?? 'pending';
                final statusLabel = status == 'completed'
                    ? t(widget.language, 'agroCompleted')
                    : t(widget.language, 'agroPending');
                final isCompleted = status == 'completed';
                final photoUrl = bill['bill_photo_url']?.toString();
                final hasPhoto =
                    photoUrl != null && photoUrl.trim().isNotEmpty;
                final note =
                    bill['note']?.toString().trim().isNotEmpty == true
                    ? bill['note'].toString().trim()
                    : '-';

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
                        const SizedBox(height: 6),
                        Text('${t(widget.language, 'agroBillNote')}: $note'),
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
                            IconButton(
                              tooltip: t(widget.language, 'agroEditBill'),
                              onPressed: () => _showEditBillDialog(bill),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
