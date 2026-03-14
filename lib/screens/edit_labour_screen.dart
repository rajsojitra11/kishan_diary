import 'package:flutter/material.dart';

import '../models/labor_entry.dart';
import '../models/upad_entry.dart';
import '../utils/localization.dart';

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

  void _showUpadFormDialog({UpadEntry? existing, int? index}) {
    final amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toString(),
    );
    final noteController = TextEditingController(text: existing?.note ?? '');
    final dateController = TextEditingController(text: existing?.date ?? '');

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: t(widget.language, 'upadAmount'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: t(widget.language, 'upadNote'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
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
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0;
                final note = noteController.text.trim();
                final date = dateController.text.trim();

                if (amount <= 0 || date.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t(widget.language, 'enterValidUpad')),
                    ),
                  );
                  return;
                }

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
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final days = int.tryParse(_daysController.text.trim()) ?? 0;
    final dailyRate = double.tryParse(_dailyRateController.text.trim()) ?? 0;

    if (name.isEmpty || mobile.isEmpty || days <= 0 || dailyRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'enterValidLabor'))),
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t(widget.language, 'laborUpdateButton')),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: t(widget.language, 'laborName'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _mobileController,
              decoration: InputDecoration(
                labelText: t(widget.language, 'laborMobile'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t(widget.language, 'laborDay'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dailyRateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: t(widget.language, 'laborDailyWage'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
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
                    onPressed: () => Navigator.pop(context),
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
                    DataColumn(label: Text(t(widget.language, 'upadAmount'))),
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
                          DataCell(Text('₹ ${upad.amount.toStringAsFixed(2)}')),
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
                                  onPressed: () {
                                    setState(() {
                                      _upadEntries.removeAt(index);
                                    });
                                  },
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Text(
                            'Total Upad: $_totalUpadCount',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
