import 'package:flutter/material.dart';

import '../models/upad_entry.dart';
import '../utils/localization.dart';
import '../widgets/custom_app_bar.dart';
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
  final _formKey = GlobalKey<FormState>();
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final note = _noteController.text.trim();
    final date = _dateController.text.trim();

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

  Future<void> _confirmDeleteUpad(UpadEntry record) async {
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

    final updatedList = List<UpadEntry>.from(widget.upadEntries)
      ..removeAt(widget.upadEntries.indexOf(record));
    widget.onEntriesChanged(updatedList);
  }

  Widget _buildInput(TextInputConfig config) {
    return TextFormField(
      controller: config.controller,
      keyboardType: config.number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      readOnly: config.readOnly,
      maxLines: config.maxLines,
      onTap: config.onTap,
      validator: config.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: config.label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(config.icon),
        suffixIcon: config.suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final laborUpad = widget.upadEntries
        .where((entry) => entry.laborName == widget.laborName)
        .toList();

    return Scaffold(
      appBar: buildKishanAppBar(
        context: context,
        language: widget.language,
        title: '${t(widget.language, 'upadSectionTitle')} ${widget.laborName}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput(
                TextInputConfig(
                  _amountController,
                  t(widget.language, 'upadAmount'),
                  Icons.account_balance,
                  number: true,
                  validator: (value) {
                    final raw = value?.trim() ?? '';
                    if (raw.isEmpty) {
                      return t(widget.language, 'validationRequiredField');
                    }
                    final amount = double.tryParse(raw);
                    if (amount == null) {
                      return t(widget.language, 'validationEnterValidNumber');
                    }
                    if (amount <= 0) {
                      return t(
                        widget.language,
                        'validationEnterPositiveNumber',
                      );
                    }
                    return null;
                  },
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
              _buildInput(
                TextInputConfig(
                  _dateController,
                  t(widget.language, 'upadDate'),
                  Icons.calendar_today,
                  readOnly: true,
                  onTap: () => _selectDate(_dateController),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(_dateController),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return t(widget.language, 'validationSelectDate');
                    }
                    return null;
                  },
                ),
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
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  final globalIndex = widget.upadEntries
                                      .indexOf(record);
                                  setState(() {
                                    _editingIndex = globalIndex;
                                    _amountController.text = record.amount
                                        .toString();
                                    _noteController.text = record.note;
                                    _dateController.text = record.date;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDeleteUpad(record),
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
      ),
    );
  }
}
