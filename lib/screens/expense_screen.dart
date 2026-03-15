import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../models/expense_entry.dart';
import '../models/land.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';

/// Allows the user to add, edit and delete expense records for the selected land.
class ExpenseScreen extends StatefulWidget {
  final Land? selectedLand;
  final AppLanguage language;
  final VoidCallback onSaved;

  const ExpenseScreen({
    super.key,
    required this.selectedLand,
    required this.language,
    required this.onSaved,
  });

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final List<String> _expenseTypeKeys = const [
    'expenseTypeMedicine',
    'expenseTypeSeeds',
    'expenseTypeTractor',
    'expenseTypeLightBill',
    'expenseTypeOther',
  ];

  String _typeLabel(String key) => t(widget.language, key);

  double? _tryParseNumber(String? value) {
    final normalized = (value ?? '').trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  String? _validatePositiveNumber(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return t(widget.language, 'validationRequiredField');
    }

    final amount = _tryParseNumber(raw);
    if (amount == null) {
      return t(widget.language, 'validationEnterValidNumber');
    }

    if (amount <= 0) {
      return t(widget.language, 'validationEnterPositiveNumber');
    }

    return null;
  }

  String _normalizeExpenseType(String? value) {
    if (value != null && _expenseTypeKeys.contains(value)) {
      return value;
    }

    return _expenseTypeKeys.first;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  DateTime? _parseDate(String value) {
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

  void _syncExpenseMetric() {
    final land = widget.selectedLand;
    if (land == null) {
      return;
    }

    const davaBiyaranTypes = {'expenseTypeMedicine', 'expenseTypeSeeds'};

    land.expenses = land.expenseEntries.fold(
      0.0,
      (sum, entry) => sum + entry.amount,
    );

    land.fertilizerKg = land.expenseEntries
        .where((entry) => davaBiyaranTypes.contains(entry.type))
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  Future<ExpenseEntry?> _showExpenseForm({ExpenseEntry? initialEntry}) async {
    final amountController = TextEditingController(
      text: initialEntry == null ? '' : initialEntry.amount.toString(),
    );
    final noteController = TextEditingController(
      text: initialEntry?.note ?? '',
    );
    final dateController = TextEditingController(
      text: initialEntry?.date ?? '',
    );
    final formKey = GlobalKey<FormState>();
    String selectedType = _normalizeExpenseType(initialEntry?.type);
    String? selectedBillPhotoPath = initialEntry?.billPhotoPath;
    Uint8List? selectedBillPhotoBytes = initialEntry?.billPhotoBytes;

    final entry = await showDialog<ExpenseEntry>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setDialogState) {
            Future<void> pickDate() async {
              final pickedDate = await showDatePicker(
                context: dialogContext,
                initialDate: _parseDate(dateController.text) ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (!dialogContext.mounted) {
                return;
              }

              if (pickedDate != null) {
                setDialogState(() {
                  dateController.text = _formatDate(pickedDate);
                });
              }
            }

            Future<void> pickBillPhoto() async {
              final picker = ImagePicker();
              final file = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );

              if (file == null) {
                return;
              }

              final bytes = await file.readAsBytes();

              if (!dialogContext.mounted) {
                return;
              }

              setDialogState(() {
                selectedBillPhotoPath = file.path;
                selectedBillPhotoBytes = bytes;
              });
            }

            return AlertDialog(
              title: Text(
                initialEntry == null
                    ? t(widget.language, 'expenseAddButton')
                    : t(widget.language, 'expenseUpdateButton'),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: InputDecoration(
                            labelText: t(widget.language, 'expenseTypeLabel'),
                            border: const OutlineInputBorder(),
                          ),
                          items: _expenseTypeKeys.map((typeKey) {
                            return DropdownMenuItem<String>(
                              value: typeKey,
                              child: Text(_typeLabel(typeKey)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setDialogState(() => selectedType = value);
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: t(widget.language, 'expenseAmountLabel'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.currency_rupee),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validatePositiveNumber,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: t(widget.language, 'expenseDateLabel'),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: pickDate,
                            ),
                          ),
                          onTap: pickDate,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return t(widget.language, 'validationSelectDate');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: t(widget.language, 'expenseNoteLabel'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t(widget.language, 'expenseBillPhotoLabel'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.photo),
                              label: Text(
                                selectedBillPhotoBytes == null
                                    ? t(
                                        widget.language,
                                        'expensePickPhotoButton',
                                      )
                                    : t(
                                        widget.language,
                                        'expenseChangePhotoButton',
                                      ),
                              ),
                              onPressed: pickBillPhoto,
                            ),
                            if (selectedBillPhotoBytes != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: t(
                                  widget.language,
                                  'expenseRemovePhotoButton',
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    selectedBillPhotoPath = null;
                                    selectedBillPhotoBytes = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (selectedBillPhotoBytes != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              selectedBillPhotoBytes!,
                              width: 120,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(t(widget.language, 'cancelButton')),
                ),
                ElevatedButton.icon(
                  icon: Icon(initialEntry == null ? Icons.add : Icons.save),
                  label: Text(
                    initialEntry == null
                        ? t(widget.language, 'expenseAddButton')
                        : t(widget.language, 'expenseUpdateButton'),
                  ),
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }

                    final amount = _tryParseNumber(amountController.text);
                    if (amount == null || amount <= 0) {
                      return;
                    }
                    final date = dateController.text.trim();
                    final note = noteController.text.trim();

                    Navigator.pop(
                      dialogContext,
                      ExpenseEntry(
                        type: selectedType,
                        amount: amount,
                        date: date,
                        note: note,
                        billPhotoPath: selectedBillPhotoPath,
                        billPhotoBytes: selectedBillPhotoBytes,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
    return entry;
  }

  Future<void> _addExpense() async {
    if (widget.selectedLand == null) {
      return;
    }

    final entry = await _showExpenseForm();
    if (!mounted || entry == null) {
      return;
    }

    setState(() {
      widget.selectedLand!.expenseEntries.add(entry);
      _syncExpenseMetric();
    });
    widget.onSaved();
  }

  Future<void> _editExpense(int index) async {
    if (widget.selectedLand == null) {
      return;
    }

    final existing = widget.selectedLand!.expenseEntries[index];
    final updated = await _showExpenseForm(initialEntry: existing);
    if (!mounted || updated == null) {
      return;
    }

    setState(() {
      widget.selectedLand!.expenseEntries[index] = updated;
      _syncExpenseMetric();
    });
    widget.onSaved();
  }

  Future<void> _deleteExpense(int index) async {
    if (widget.selectedLand == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t(widget.language, 'deleteExpenseTitle')),
          content: Text(t(widget.language, 'deleteExpenseConfirm')),
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

    if (!mounted) {
      return;
    }

    setState(() {
      widget.selectedLand!.expenseEntries.removeAt(index);
      _syncExpenseMetric();
    });
    widget.onSaved();
  }

  void _viewBillPhoto(ExpenseEntry entry) {
    if (entry.billPhotoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'expenseNoBillPhoto'))),
      );
      return;
    }

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
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: InteractiveViewer(
                    child: Image.memory(entry.billPhotoBytes!),
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

  Widget _buildMobileExpenseRecords(List<ExpenseEntry> entries) {
    return Column(
      children: entries.asMap().entries.map((item) {
        final index = item.key;
        final record = item.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _typeLabel(record.type),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${t(widget.language, 'expenseAmountLabel')}: ${record.amount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 2),
                Text(
                  '${t(widget.language, 'expenseDateLabel')}: ${record.date}',
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: t(widget.language, 'viewBillTitle'),
                      onPressed: () => _viewBillPhoto(record),
                      icon: const Icon(
                        Icons.remove_red_eye,
                        color: Colors.teal,
                      ),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: t(widget.language, 'expenseUpdateButton'),
                      onPressed: () => _editExpense(index),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: t(widget.language, 'deleteButton'),
                      onPressed: () => _deleteExpense(index),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopExpenseRecords(List<ExpenseEntry> entries) {
    return Column(
      children: entries.asMap().entries.map((item) {
        final index = item.key;
        final record = item.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -1),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.receipt_long, color: Colors.orange),
            ),
            title: Text(
              _typeLabel(record.type),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t(widget.language, 'expenseAmountLabel')}: ${record.amount.toStringAsFixed(2)}',
                ),
                Text(
                  '${t(widget.language, 'expenseDateLabel')}: ${record.date}',
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: t(widget.language, 'viewBillTitle'),
                  onPressed: () => _viewBillPhoto(record),
                  icon: const Icon(Icons.remove_red_eye, color: Colors.teal),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: t(widget.language, 'expenseUpdateButton'),
                  onPressed: () => _editExpense(index),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: t(widget.language, 'deleteButton'),
                  onPressed: () => _deleteExpense(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedLand == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text(t(widget.language, 'noLandSelected'))),
      );
    }

    final entries = widget.selectedLand!.expenseEntries;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(widget.language, 'navExpense'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        statCard(
          t(widget.language, 'expensesLabel'),
          '₹ ${widget.selectedLand!.expenses.toStringAsFixed(2)}',
          Colors.red,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addExpense,
            icon: const Icon(Icons.add),
            label: Text(t(widget.language, 'expenseAddButton')),
          ),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Text(t(widget.language, 'expenseNoRecords'))
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return _buildMobileExpenseRecords(entries);
              }
              return _buildDesktopExpenseRecords(entries);
            },
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return content;
        }

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(padding: const EdgeInsets.all(16), child: content),
        );
      },
    );
  }
}
