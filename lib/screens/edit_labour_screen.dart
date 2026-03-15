import 'package:flutter/material.dart';

import '../models/labor_entry.dart';
import '../models/upad_entry.dart';
import '../utils/api_service.dart';
import '../utils/localization.dart';
import '../widgets/custom_app_bar.dart';

class EditLabourResult {
  final String originalLaborName;
  final LaborEntry updatedLabor;
  final List<UpadEntry> updatedUpadEntries;

  EditLabourResult({
    required this.originalLaborName,
    required this.updatedLabor,
    required this.updatedUpadEntries,
  });
}

class EditLabourScreen extends StatefulWidget {
  final AppLanguage language;
  final LaborEntry initialEntry;
  final List<UpadEntry> initialUpadEntries;

  const EditLabourScreen({
    super.key,
    required this.language,
    required this.initialEntry,
    required this.initialUpadEntries,
  });

  @override
  State<EditLabourScreen> createState() => _EditLabourScreenState();
}

class _EditLabourScreenState extends State<EditLabourScreen> {
  final _laborFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _dailyRateController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  late List<UpadEntry> _upadEntries;

  double get _totalUpadAmount =>
      _upadEntries.fold(0.0, (sum, entry) => sum + entry.amount);

  int get _totalUpadCount => _upadEntries.length;

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String _toDisplayDate(String? serverDate) {
    if (serverDate == null || serverDate.trim().isEmpty) {
      return '';
    }
    final parts = serverDate.split('-');
    if (parts.length != 3) {
      return serverDate;
    }
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  LaborEntry _laborFromApi(Map<String, dynamic> item) {
    return LaborEntry(
      id: _toInt(item['id']),
      name: item['labor_name']?.toString() ?? widget.initialEntry.name,
      mobile: item['mobile']?.toString() ?? widget.initialEntry.mobile,
      days: _toDouble(item['total_days']),
      dailyRate: _toDouble(item['daily_rate']),
    );
  }

  UpadEntry _upadFromApi(Map<String, dynamic> item) {
    final snapshot = item['labor_name_snapshot']?.toString();
    return UpadEntry(
      id: _toInt(item['id']),
      laborEntryId: _toInt(item['labor_entry_id']) ?? widget.initialEntry.id,
      landId: _toInt(item['land_id']),
      laborName: snapshot == null || snapshot.trim().isEmpty
          ? _nameController.text.trim()
          : snapshot,
      amount: _toDouble(item['amount']),
      note: item['note']?.toString() ?? '',
      date: _toDisplayDate(item['payment_date']?.toString()),
    );
  }

  double? _tryParseNumber(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  String _formatDays(double days) {
    if (days == days.truncateToDouble()) {
      return days.toInt().toString();
    }
    return days.toString();
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialEntry.name;
    _mobileController.text = widget.initialEntry.mobile;
    _daysController.text = _formatDays(widget.initialEntry.days);
    _dailyRateController.text = widget.initialEntry.dailyRate.toString();
    _totalController.text = widget.initialEntry.total.toStringAsFixed(2);
    _daysController.addListener(_calculateTotal);
    _dailyRateController.addListener(_calculateTotal);
    _upadEntries = List<UpadEntry>.from(widget.initialUpadEntries);
  }

  void _calculateTotal() {
    final days = _tryParseNumber(_daysController.text) ?? 0.0;
    final rate = _tryParseNumber(_dailyRateController.text) ?? 0.0;
    final total = days * rate;
    setState(() {
      _totalController.text = total.toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _daysController.dispose();
    _dailyRateController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t(widget.language, 'validationRequiredField');
    }
    return null;
  }

  String? _mobileValidator(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return t(widget.language, 'validationRequiredField');
    }
    if (!RegExp(r'^\d{10}$').hasMatch(raw)) {
      return t(widget.language, 'validationEnterValidMobile');
    }
    return null;
  }

  String? _positiveDoubleValidator(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return t(widget.language, 'validationRequiredField');
    }
    final parsed = _tryParseNumber(raw);
    if (parsed == null) {
      return t(widget.language, 'validationEnterValidNumber');
    }
    if (parsed <= 0) {
      return t(widget.language, 'validationEnterPositiveNumber');
    }
    return null;
  }

  String? _positiveDayValidator(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return t(widget.language, 'validationRequiredField');
    }
    final parsed = _tryParseNumber(raw);
    if (parsed == null) {
      return t(widget.language, 'validationEnterValidNumber');
    }
    if (parsed <= 0) {
      return t(widget.language, 'validationEnterPositiveNumber');
    }
    return null;
  }

  void _showUpadFormDialog({UpadEntry? existing, int? index}) {
    final amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toString(),
    );
    final noteController = TextEditingController(text: existing?.note ?? '');
    final dateController = TextEditingController(text: existing?.date ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            existing == null
                ? t(widget.language, 'upadAddButton')
                : t(widget.language, 'upadUpdateButton'),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: t(widget.language, 'upadAmount'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _positiveDoubleValidator,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: t(widget.language, 'upadNote'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: t(widget.language, 'upadDate'),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _pickDate(dateController),
                      ),
                    ),
                    onTap: () => _pickDate(dateController),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t(widget.language, 'validationSelectDate');
                      }
                      return null;
                    },
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

                final amount = _tryParseNumber(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  return;
                }
                final note = noteController.text.trim();
                final date = dateController.text.trim();

                UpadEntry upad = UpadEntry(
                  id: existing?.id,
                  laborEntryId:
                      existing?.laborEntryId ?? widget.initialEntry.id,
                  landId: existing?.landId,
                  laborName: _nameController.text.trim(),
                  amount: amount,
                  note: note,
                  date: date,
                );

                if (widget.initialEntry.id != null) {
                  try {
                    final payload = existing?.id == null
                        ? await ApiService.instance.createUpadEntry(
                            laborEntryId: widget.initialEntry.id!,
                            amount: amount,
                            paymentDate: date,
                            note: note,
                            laborNameSnapshot: _nameController.text.trim(),
                          )
                        : await ApiService.instance.updateUpadEntry(
                            upadEntryId: existing!.id!,
                            amount: amount,
                            paymentDate: date,
                            note: note,
                            laborNameSnapshot: _nameController.text.trim(),
                          );

                    upad = _upadFromApi(
                      ((payload['upad_entry'] as Map?) ?? {})
                          .cast<String, dynamic>(),
                    );
                  } on ApiException catch (error) {
                    if (!mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.message)));
                    return;
                  }
                }

                if (!mounted) {
                  return;
                }

                setState(() {
                  if (index != null) {
                    _upadEntries[index] = upad;
                  } else {
                    _upadEntries.add(upad);
                  }
                });

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.pop(dialogContext);
              },
              child: Text(
                existing == null
                    ? t(widget.language, 'upadAddButton')
                    : t(widget.language, 'upadUpdateButton'),
              ),
            ),
          ],
        );
      },
    ).whenComplete(() {
      amountController.dispose();
      noteController.dispose();
      dateController.dispose();
    });
  }

  Future<void> _saveLaborChanges() async {
    if (!(_laborFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final days = _tryParseNumber(_daysController.text) ?? 0.0;
    final dailyRate = _tryParseNumber(_dailyRateController.text) ?? 0.0;

    LaborEntry updatedLabor = LaborEntry(
      id: widget.initialEntry.id,
      name: name,
      mobile: mobile,
      days: days,
      dailyRate: dailyRate,
    );

    if (widget.initialEntry.id != null) {
      try {
        final payload = await ApiService.instance.updateLaborEntry(
          laborEntryId: widget.initialEntry.id!,
          laborName: name,
          mobile: mobile,
          totalDays: days,
          dailyRate: dailyRate,
        );

        updatedLabor = _laborFromApi(
          ((payload['labor_entry'] as Map?) ?? {}).cast<String, dynamic>(),
        );
      } on ApiException catch (error) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
        return;
      }
    }

    final updatedUpadEntries = _upadEntries
        .map(
          (entry) => UpadEntry(
            id: entry.id,
            laborEntryId: entry.laborEntryId ?? updatedLabor.id,
            landId: entry.landId,
            laborName: name,
            amount: entry.amount,
            note: entry.note,
            date: entry.date,
          ),
        )
        .toList();

    if (!mounted) {
      return;
    }

    Navigator.pop(
      context,
      EditLabourResult(
        originalLaborName: widget.initialEntry.name,
        updatedLabor: updatedLabor,
        updatedUpadEntries: updatedUpadEntries,
      ),
    );
  }

  void _saveUpadChangesOnly() {
    final updatedUpadEntries = _upadEntries
        .map(
          (entry) => UpadEntry(
            id: entry.id,
            laborEntryId: entry.laborEntryId,
            landId: entry.landId,
            laborName: widget.initialEntry.name,
            amount: entry.amount,
            note: entry.note,
            date: entry.date,
          ),
        )
        .toList();

    Navigator.pop(
      context,
      EditLabourResult(
        originalLaborName: widget.initialEntry.name,
        updatedLabor: widget.initialEntry,
        updatedUpadEntries: updatedUpadEntries,
      ),
    );
  }

  Future<void> _confirmDeleteUpadAt(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t(widget.language, 'deleteUpadTitle')),
          content: Text(t(widget.language, 'deleteUpadConfirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(t(widget.language, 'cancelButton')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(t(widget.language, 'deleteButton')),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final target = _upadEntries[index];

    if (target.id != null) {
      try {
        await ApiService.instance.deleteUpadEntry(target.id!);
      } on ApiException catch (error) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
        return;
      }
    }

    setState(() {
      _upadEntries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _saveUpadChangesOnly();
        }
      },
      child: Scaffold(
        appBar: buildKishanAppBar(
          context: context,
          language: widget.language,
          title: t(widget.language, 'laborUpdateButton'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _laborFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: t(widget.language, 'laborName'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: t(widget.language, 'laborMobile'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _mobileValidator,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _daysController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: t(widget.language, 'laborDay'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _positiveDayValidator,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _dailyRateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: t(widget.language, 'laborDailyWage'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.money),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _positiveDoubleValidator,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _totalController,
                  readOnly: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: t(widget.language, 'laborTotalWage'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _saveUpadChangesOnly,
                        child: Text(t(widget.language, 'cancelButton')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.update),
                        label: Text(t(widget.language, 'laborUpdateButton')),
                        onPressed: _saveLaborChanges,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.account_balance),
                    label: Text(t(widget.language, 'upadAddButton')),
                    onPressed: () => _showUpadFormDialog(),
                  ),
                ),
                const SizedBox(height: 12),
                if (_upadEntries.isEmpty)
                  Text(t(widget.language, 'upadNoRecords'))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(t(widget.language, 'upadAmount')),
                        ),
                        DataColumn(label: Text(t(widget.language, 'upadNote'))),
                        DataColumn(label: Text(t(widget.language, 'upadDate'))),
                        DataColumn(label: Text(t(widget.language, 'actions'))),
                      ],
                      rows: [
                        ..._upadEntries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final upad = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text('₹ ${upad.amount.toStringAsFixed(2)}'),
                              ),
                              DataCell(Text(upad.note)),
                              DataCell(Text(upad.date)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _showUpadFormDialog(
                                        existing: upad,
                                        index: index,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _confirmDeleteUpadAt(index),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '₹ ${_totalUpadAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'Total Upad: $_totalUpadCount',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const DataCell(Text('-')),
                            const DataCell(SizedBox.shrink()),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
