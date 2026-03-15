import 'package:flutter/material.dart';

import '../models/labor_entry.dart';
import '../models/upad_entry.dart';
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
      _upadEntries.fold(0, (sum, entry) => sum + entry.amount);

  int get _totalUpadCount => _upadEntries.length;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialEntry.name;
    _mobileController.text = widget.initialEntry.mobile;
    _daysController.text = widget.initialEntry.days.toString();
    _dailyRateController.text = widget.initialEntry.dailyRate.toString();
    _totalController.text = widget.initialEntry.total.toStringAsFixed(2);
    _daysController.addListener(_calculateTotal);
    _dailyRateController.addListener(_calculateTotal);
    _upadEntries = List<UpadEntry>.from(widget.initialUpadEntries);
  }

  void _calculateTotal() {
    final days = int.tryParse(_daysController.text.trim()) ?? 0;
    final rate = double.tryParse(_dailyRateController.text.trim()) ?? 0;
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
    final parsed = double.tryParse(raw);
    if (parsed == null) {
      return t(widget.language, 'validationEnterValidNumber');
    }
    if (parsed <= 0) {
      return t(widget.language, 'validationEnterPositiveNumber');
    }
    return null;
  }

  String? _positiveIntValidator(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return t(widget.language, 'validationRequiredField');
    }
    final parsed = int.tryParse(raw);
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
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final amount = double.parse(amountController.text.trim());
                final note = noteController.text.trim();
                final date = dateController.text.trim();

                final upad = UpadEntry(
                  laborName: _nameController.text.trim(),
                  amount: amount,
                  note: note,
                  date: date,
                );

                setState(() {
                  if (index != null) {
                    _upadEntries[index] = upad;
                  } else {
                    _upadEntries.add(upad);
                  }
                });

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

  void _saveLaborChanges() {
    if (!(_laborFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final days = int.parse(_daysController.text.trim());
    final dailyRate = double.parse(_dailyRateController.text.trim());

    final updatedLabor = LaborEntry(
      name: name,
      mobile: mobile,
      days: days,
      dailyRate: dailyRate,
    );

    final updatedUpadEntries = _upadEntries
        .map(
          (entry) => UpadEntry(
            laborName: name,
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
        updatedLabor: updatedLabor,
        updatedUpadEntries: updatedUpadEntries,
      ),
    );
  }

  void _saveUpadChangesOnly() {
    final updatedUpadEntries = _upadEntries
        .map(
          (entry) => UpadEntry(
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: t(widget.language, 'laborDay'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _positiveIntValidator,
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
