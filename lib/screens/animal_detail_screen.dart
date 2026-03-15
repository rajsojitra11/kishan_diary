import 'package:flutter/material.dart';

import '../models/animal.dart';
import '../models/animal_record.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/text_input_config.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Animal animal;
  final AppLanguage language;
  final VoidCallback onChanged;

  const AnimalDetailScreen({
    super.key,
    required this.animal,
    required this.language,
    required this.onChanged,
  });

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  final _recordFormKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _milkController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _showRecordValidation = false;

  void _deleteRecord(int index) {
    setState(() {
      widget.animal.records.removeAt(index);
    });
    widget.onChanged();
  }

  Future<void> _confirmDeleteRecord(int index) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(t(widget.language, 'deleteAnimalRecordTitle')),
              content: Text(t(widget.language, 'deleteAnimalRecordConfirm')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(t(widget.language, 'cancelButton')),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(t(widget.language, 'deleteButton')),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || index < 0 || index >= widget.animal.records.length) {
      return;
    }

    _deleteRecord(index);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _milkController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _dateController.text = _formatDate(picked);
    }
  }

  void _saveRecord() {
    final isValid = _recordFormKey.currentState?.validate() ?? false;

    if (!isValid) {
      if (!_showRecordValidation) {
        setState(() {
          _showRecordValidation = true;
        });
      }
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final milk = double.parse(_milkController.text.trim());
    final date = _dateController.text.trim();

    widget.animal.records.add(
      AnimalRecord(amount: amount, milk: milk, date: date),
    );
    widget.onChanged();

    setState(() {
      _recordFormKey.currentState?.reset();
      _amountController.clear();
      _milkController.clear();
      _dateController.clear();
      _showRecordValidation = false;
    });
  }

  Widget _buildRecordCard(AnimalRecord record, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: const Icon(Icons.local_drink, color: Colors.indigo),
        ),
        title: Text(
          '${record.milk.toStringAsFixed(2)} L',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t(widget.language, 'animalDateLabel')}: ${record.date}'),
            Text(
              '${t(widget.language, 'animalAmountLabel')}: ₹ ${record.amount.toStringAsFixed(2)}',
            ),
          ],
        ),
        trailing: IconButton(
          tooltip: t(widget.language, 'deleteButton'),
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeleteRecord(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildKishanAppBar(
        context: context,
        language: widget.language,
        title: widget.animal.name,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _recordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statCard(
                t(widget.language, 'animalTotalAmountLabel'),
                '₹ ${widget.animal.totalAmount.toStringAsFixed(2)}',
                Colors.purple,
              ),
              const SizedBox(height: 8),
              statCard(
                t(widget.language, 'animalTotalMilkLabel'),
                '${widget.animal.totalMilk.toStringAsFixed(2)} L',
                Colors.indigo,
              ),
              const SizedBox(height: 16),
              buildInput(
                TextInputConfig(
                  _amountController,
                  t(widget.language, 'animalAmountLabel'),
                  Icons.currency_rupee,
                  number: true,
                  autovalidateMode: _showRecordValidation
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
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
              buildInput(
                TextInputConfig(
                  _milkController,
                  t(widget.language, 'animalMilkLabel'),
                  Icons.local_drink,
                  number: true,
                  autovalidateMode: _showRecordValidation
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  validator: (value) {
                    final raw = value?.trim() ?? '';
                    if (raw.isEmpty) {
                      return t(widget.language, 'validationRequiredField');
                    }
                    final milk = double.tryParse(raw);
                    if (milk == null) {
                      return t(widget.language, 'validationEnterValidNumber');
                    }
                    if (milk <= 0) {
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
              buildInput(
                TextInputConfig(
                  _dateController,
                  t(widget.language, 'animalDateLabel'),
                  Icons.calendar_today,
                  readOnly: true,
                  onTap: _pickDate,
                  autovalidateMode: _showRecordValidation
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDate,
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
                  icon: const Icon(Icons.add),
                  label: Text(t(widget.language, 'addAnimalRecordButton')),
                  onPressed: _saveRecord,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                t(widget.language, 'animalRecordsLabel'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.animal.records.isEmpty)
                Text(t(widget.language, 'animalNoRecords'))
              else
                ...widget.animal.records.asMap().entries.map((entry) {
                  return _buildRecordCard(entry.value, entry.key);
                }),
            ],
          ),
        ),
      ),
    );
  }
}
