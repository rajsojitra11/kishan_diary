import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../models/income_entry.dart';
import '../models/land.dart';
import '../utils/api_service.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';

/// Allows the user to add, edit and delete income records for the selected land.
class IncomeScreen extends StatefulWidget {
  final Land? selectedLand;
  final AppLanguage language;
  final VoidCallback onSaved;

  const IncomeScreen({
    super.key,
    required this.selectedLand,
    required this.language,
    required this.onSaved,
  });

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final List<String> _incomeTypeKeys = const [
    'incomeTypeCropSale',
    'incomeTypeTractorHarvester',
    'incomeTypeVegetables',
    'incomeTypeSubsidy',
    'incomeTypeOther',
  ];
  String _selectedIncomeTypeFilter = 'incomeTypeAll';

  String _typeLabel(String key) => t(widget.language, key);

  List<IncomeEntry> _filteredEntries(List<IncomeEntry> entries) {
    if (_selectedIncomeTypeFilter == 'incomeTypeAll') {
      return entries;
    }

    return entries
        .where((entry) => entry.type == _selectedIncomeTypeFilter)
        .toList();
  }

  int _indexOfIncomeEntry(IncomeEntry entry) {
    final land = widget.selectedLand;
    if (land == null) {
      return -1;
    }

    if (entry.id != null) {
      final idMatchIndex = land.incomeEntries.indexWhere(
        (item) => item.id == entry.id,
      );
      if (idMatchIndex != -1) {
        return idMatchIndex;
      }
    }

    return land.incomeEntries.indexWhere((item) => identical(item, entry));
  }

  void _editIncomeByEntry(IncomeEntry entry) {
    final index = _indexOfIncomeEntry(entry);
    if (index == -1) {
      return;
    }
    _editIncome(index);
  }

  void _deleteIncomeByEntry(IncomeEntry entry) {
    final index = _indexOfIncomeEntry(entry);
    if (index == -1) {
      return;
    }
    _deleteIncome(index);
  }

  bool _loading = false;

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

  IncomeEntry _entryFromApi(Map<String, dynamic> item) {
    return IncomeEntry(
      id: _toInt(item['id']),
      type: item['income_type']?.toString() ?? _incomeTypeKeys.first,
      amount: _toDouble(item['amount']),
      date: _toDisplayDate(item['entry_date']?.toString()),
      note: item['note']?.toString() ?? '',
      billPhotoPath: item['bill_photo_path']?.toString(),
      billPhotoUrl: item['bill_photo_url']?.toString(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void didUpdateWidget(covariant IncomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLand?.id != widget.selectedLand?.id) {
      _loadEntries();
    }
  }

  Future<void> _loadEntries() async {
    final land = widget.selectedLand;
    if (land == null || land.id == null) {
      return;
    }

    setState(() => _loading = true);
    try {
      final payload = await ApiService.instance.getIncomeEntries(land.id!);
      final entries = ((payload['income_entries'] as List?) ?? [])
          .map((item) => _entryFromApi((item as Map).cast<String, dynamic>()))
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        land.incomeEntries
          ..clear()
          ..addAll(entries);
        land.income = _toDouble(payload['total_income']);
        _loading = false;
      });
      widget.onSaved();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

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

  String _normalizeIncomeType(String? value) {
    if (value != null && _incomeTypeKeys.contains(value)) {
      return value;
    }

    if (value == 'incomeTypeMilkSale') {
      return 'incomeTypeOther';
    }

    return _incomeTypeKeys.first;
  }

  void _syncIncomeMetric() {
    final land = widget.selectedLand;
    if (land == null) {
      return;
    }
    land.income = land.incomeEntries.fold(
      0,
      (sum, entry) => sum + entry.amount,
    );
  }

  Future<IncomeEntry?> _showIncomeForm({IncomeEntry? initialEntry}) async {
    final amountController = TextEditingController(
      text: initialEntry == null ? '' : initialEntry.amount.toString(),
    );
    final noteController = TextEditingController(
      text: initialEntry?.note ?? '',
    );
    final dateController = TextEditingController(
      text: initialEntry?.date ?? _formatDate(DateTime.now()),
    );
    final formKey = GlobalKey<FormState>();
    String selectedType = _normalizeIncomeType(initialEntry?.type);
    String? selectedBillPhotoPath = initialEntry?.billPhotoPath;
    Uint8List? selectedBillPhotoBytes = initialEntry?.billPhotoBytes;
    String? selectedBillPhotoUrl = initialEntry?.billPhotoUrl;

    final entry = await showDialog<IncomeEntry>(
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
                selectedBillPhotoUrl = null;
              });
            }

            return AlertDialog(
              title: Text(
                initialEntry == null
                    ? t(widget.language, 'incomeAddButton')
                    : t(widget.language, 'incomeUpdateButton'),
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
                            labelText: t(widget.language, 'incomeTypeLabel'),
                            border: const OutlineInputBorder(),
                          ),
                          items: _incomeTypeKeys.map((typeKey) {
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
                            labelText: t(widget.language, 'incomeAmountLabel'),
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
                            labelText: t(widget.language, 'incomeDateLabel'),
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
                            labelText: t(widget.language, 'incomeNoteLabel'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t(widget.language, 'incomeBillPhotoLabel'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.photo),
                              label: Text(
                                (selectedBillPhotoBytes == null &&
                                        (selectedBillPhotoUrl == null ||
                                            selectedBillPhotoUrl!
                                                .trim()
                                                .isEmpty))
                                    ? t(
                                        widget.language,
                                        'incomePickPhotoButton',
                                      )
                                    : t(
                                        widget.language,
                                        'incomeChangePhotoButton',
                                      ),
                              ),
                              onPressed: pickBillPhoto,
                            ),
                            if (selectedBillPhotoBytes != null ||
                                (selectedBillPhotoUrl != null &&
                                    selectedBillPhotoUrl!
                                        .trim()
                                        .isNotEmpty)) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: t(
                                  widget.language,
                                  'incomeRemovePhotoButton',
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    selectedBillPhotoPath = null;
                                    selectedBillPhotoBytes = null;
                                    selectedBillPhotoUrl = null;
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
                        if (selectedBillPhotoBytes != null ||
                            (selectedBillPhotoUrl != null &&
                                selectedBillPhotoUrl!.trim().isNotEmpty)) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: selectedBillPhotoBytes != null
                                ? Image.memory(
                                    selectedBillPhotoBytes!,
                                    width: 120,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    selectedBillPhotoUrl!,
                                    width: 120,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 120,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.broken_image),
                                    ),
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
                        ? t(widget.language, 'incomeAddButton')
                        : t(widget.language, 'incomeUpdateButton'),
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
                      IncomeEntry(
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

  Future<void> _addIncome() async {
    final land = widget.selectedLand;
    if (land == null) {
      return;
    }

    final entry = await _showIncomeForm();
    if (!mounted || entry == null) {
      return;
    }

    if (land.id == null) {
      setState(() {
        land.incomeEntries.add(entry);
        _syncIncomeMetric();
      });
      widget.onSaved();
      return;
    }

    try {
      final payload = await ApiService.instance.createIncomeEntry(
        landId: land.id!,
        incomeType: entry.type,
        amount: entry.amount,
        entryDate: entry.date,
        note: entry.note,
        billPhotoPath: entry.billPhotoPath,
        billPhotoBytes: entry.billPhotoBytes,
        billPhotoFileName: entry.billPhotoPath?.split('/').last,
      );

      final created = _entryFromApi(
        ((payload['income_entry'] as Map?) ?? {}).cast<String, dynamic>(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        land.incomeEntries.add(created);
        land.income = _toDouble(
          ((payload['land_totals'] as Map?)?['income_total']),
        );
      });
      widget.onSaved();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _editIncome(int index) async {
    final land = widget.selectedLand;
    if (land == null) {
      return;
    }

    final existing = land.incomeEntries[index];
    final updated = await _showIncomeForm(initialEntry: existing);
    if (!mounted || updated == null) {
      return;
    }

    if (existing.id == null) {
      setState(() {
        land.incomeEntries[index] = updated;
        _syncIncomeMetric();
      });
      widget.onSaved();
      return;
    }

    try {
      final payload = await ApiService.instance.updateIncomeEntry(
        incomeEntryId: existing.id!,
        incomeType: updated.type,
        amount: updated.amount,
        entryDate: updated.date,
        note: updated.note,
        billPhotoPath: updated.billPhotoPath,
        billPhotoBytes: updated.billPhotoBytes,
        billPhotoFileName: updated.billPhotoPath?.split('/').last,
      );

      final updatedEntry = _entryFromApi(
        ((payload['income_entry'] as Map?) ?? {}).cast<String, dynamic>(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        land.incomeEntries[index] = updatedEntry;
        land.income = _toDouble(
          ((payload['land_totals'] as Map?)?['income_total']),
        );
      });
      widget.onSaved();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _deleteIncome(int index) async {
    final land = widget.selectedLand;
    if (land == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t(widget.language, 'deleteIncomeTitle')),
          content: Text(t(widget.language, 'deleteIncomeConfirm')),
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

    final target = land.incomeEntries[index];

    if (target.id == null) {
      setState(() {
        land.incomeEntries.removeAt(index);
        _syncIncomeMetric();
      });
      widget.onSaved();
      return;
    }

    try {
      final payload = await ApiService.instance.deleteIncomeEntry(target.id!);

      if (!mounted) {
        return;
      }

      setState(() {
        land.incomeEntries.removeAt(index);
        land.income = _toDouble(
          ((payload['land_totals'] as Map?)?['income_total']),
        );
      });
      widget.onSaved();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _viewBillPhoto(IncomeEntry entry) {
    if (entry.billPhotoBytes == null &&
        (entry.billPhotoUrl == null || entry.billPhotoUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'incomeNoBillPhoto'))),
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
                  t(widget.language, 'viewIncomeBillTitle'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: InteractiveViewer(
                    child: entry.billPhotoBytes != null
                        ? Image.memory(entry.billPhotoBytes!)
                        : Image.network(entry.billPhotoUrl!),
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

  Widget _buildMobileIncomeRecords(List<IncomeEntry> entries) {
    return Column(
      children: entries.map((record) {
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
                  '${t(widget.language, 'incomeAmountLabel')}: ${record.amount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 2),
                Text(
                  '${t(widget.language, 'incomeDateLabel')}: ${record.date}',
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: t(widget.language, 'viewIncomeBillTitle'),
                      onPressed: () => _viewBillPhoto(record),
                      icon: const Icon(
                        Icons.remove_red_eye,
                        color: Colors.teal,
                      ),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: t(widget.language, 'incomeUpdateButton'),
                      onPressed: () => _editIncomeByEntry(record),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: t(widget.language, 'deleteButton'),
                      onPressed: () => _deleteIncomeByEntry(record),
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

  Widget _buildDesktopIncomeRecords(List<IncomeEntry> entries) {
    return Column(
      children: entries.map((record) {
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
              backgroundColor: Colors.teal.shade100,
              child: const Icon(Icons.currency_rupee, color: Colors.teal),
            ),
            title: Text(
              _typeLabel(record.type),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t(widget.language, 'incomeAmountLabel')}: ${record.amount.toStringAsFixed(2)}',
                ),
                Text(
                  '${t(widget.language, 'incomeDateLabel')}: ${record.date}',
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: t(widget.language, 'viewIncomeBillTitle'),
                  onPressed: () => _viewBillPhoto(record),
                  icon: const Icon(Icons.remove_red_eye, color: Colors.teal),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: t(widget.language, 'incomeUpdateButton'),
                  onPressed: () => _editIncomeByEntry(record),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: t(widget.language, 'deleteButton'),
                  onPressed: () => _deleteIncomeByEntry(record),
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

    final entries = widget.selectedLand!.incomeEntries;
    final filteredEntries = _filteredEntries(entries);
    final incomeTabs = ['incomeTypeAll', ..._incomeTypeKeys];

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(widget.language, 'navIncome'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        statCard(
          t(widget.language, 'incomeLabel'),
          '₹ ${widget.selectedLand!.income.toStringAsFixed(2)}',
          Colors.teal,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addIncome,
            icon: const Icon(Icons.add),
            label: Text(t(widget.language, 'incomeAddButton')),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: incomeTabs.map((typeKey) {
              final isSelected = _selectedIncomeTypeFilter == typeKey;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_typeLabel(typeKey)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedIncomeTypeFilter = typeKey;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (filteredEntries.isEmpty)
          Text(t(widget.language, 'incomeNoRecords'))
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return _buildMobileIncomeRecords(filteredEntries);
              }
              return _buildDesktopIncomeRecords(filteredEntries);
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
