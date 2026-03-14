import 'package:flutter/material.dart';

import '../models/upad_entry.dart';
import '../utils/localization.dart';
import '../widgets/text_input_config.dart';

class UpadScreen extends StatefulWidget {
  final String laborName;
  final List<UpadEntry> upadEntries;
  final ValueChanged<List<UpadEntry>> onEntriesChanged;
  final AppLanguage language;

  const UpadScreen({
    super.key,
    required this.laborName,
    required this.upadEntries,
    required this.onEntriesChanged,
    required this.language,
  });

  @override
  State<UpadScreen> createState() => _UpadScreenState();
}

class _UpadScreenState extends State<UpadScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  int? _editingIndex;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
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

  void _saveUpad() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final note = _noteController.text.trim();
    final date = _dateController.text.trim();

    if (amount <= 0 || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'enterValidUpad'))),
      );
      return;
    }

    final newEntry = UpadEntry(
      laborName: widget.laborName,
      amount: amount,
      note: note,
      date: date,
    );

    final updatedList = List<UpadEntry>.from(widget.upadEntries);
    if (_editingIndex != null) {
      updatedList[_editingIndex!] = newEntry;
    } else {
      updatedList.add(newEntry);
    }

    widget.onEntriesChanged(updatedList);

    setState(() {
      _amountController.clear();
      _noteController.clear();
      _dateController.clear();
      _editingIndex = null;
    });
  }

  Widget _buildInput(TextInputConfig config) {
    return TextField(
      controller: config.controller,
      keyboardType: config.number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: config.label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(config.icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final laborUpad = widget.upadEntries
        .where((entry) => entry.laborName == widget.laborName)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${t(widget.language, 'upadSectionTitle')} ${widget.laborName}',
        ),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInput(
              TextInputConfig(
                _amountController,
                t(widget.language, 'upadAmount'),
                Icons.account_balance,
                number: true,
              ),
            ),
            const SizedBox(height: 10),
            _buildInput(
              TextInputConfig(
                _noteController,
                t(widget.language, 'upadNote'),
                Icons.notes,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: t(widget.language, 'upadDate'),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(_dateController),
                ),
              ),
              onTap: () => _selectDate(_dateController),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(_editingIndex != null ? Icons.update : Icons.add),
                label: Text(
                  _editingIndex != null
                      ? t(widget.language, 'upadUpdateButton')
                      : t(widget.language, 'upadAddButton'),
                ),
                onPressed: _saveUpad,
              ),
            ),
            const SizedBox(height: 20),
            Text(t(widget.language, 'upadNoRecords')),
            const SizedBox(height: 10),
            if (laborUpad.isEmpty)
              Text(t(widget.language, 'upadNoRecords'))
            else
              DataTable(
                columns: [
                  DataColumn(label: Text(t(widget.language, 'upadAmount'))),
                  DataColumn(label: Text(t(widget.language, 'upadNote'))),
                  DataColumn(label: Text(t(widget.language, 'upadDate'))),
                  DataColumn(label: Text(t(widget.language, 'actions'))),
                ],
                rows: laborUpad.map((record) {
                  return DataRow(
                    cells: [
                      DataCell(Text('₹ ${record.amount.toStringAsFixed(2)}')),
                      DataCell(Text(record.note)),
                      DataCell(Text(record.date)),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                final globalIndex =
                                    widget.upadEntries.indexOf(record);
                                setState(() {
                                  _editingIndex = globalIndex;
                                  _amountController.text =
                                      record.amount.toString();
                                  _noteController.text = record.note;
                                  _dateController.text = record.date;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                final updatedList = List<UpadEntry>.from(
                                  widget.upadEntries,
                                )..removeAt(widget.upadEntries.indexOf(record));
                                widget.onEntriesChanged(updatedList);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
