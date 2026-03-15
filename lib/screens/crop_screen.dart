import 'package:flutter/material.dart';

import '../models/crop_entry.dart';
import '../models/land.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';

/// Allows the user to record / update crop production for the selected land.
class CropScreen extends StatefulWidget {
  final Land? selectedLand;
  final AppLanguage language;
  final VoidCallback onSaved;

  const CropScreen({
    super.key,
    required this.selectedLand,
    required this.language,
    required this.onSaved,
  });

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final List<String> _cropTypeKeys = [
    'cropTypeWheat',
    'cropTypeCotton',
    'cropTypeGroundnut',
    'cropTypeBajra',
    'cropTypeMaize',
    'cropTypeRice',
    'cropTypeJiru',
    'cropTypeLasan',
    'cropTypeChana',
    'cropTypeTal',
    'cropTypeAnyOther',
  ];

  String _normalizeCropTypeValue(String cropType) {
    if (cropType == 'cropTypeCumin') {
      return 'cropTypeJiru';
    }
    if (cropType == 'cropTypeGarlic') {
      return 'cropTypeLasan';
    }
    if (cropType == 'cropTypeChickpea') {
      return 'cropTypeChana';
    }
    if (cropType == 'cropTypeSesame') {
      return 'cropTypeTal';
    }
    if (cropType == 'cropTypeOther') {
      return 'cropTypeAnyOther';
    }

    if (_cropTypeKeys.contains(cropType)) {
      return cropType;
    }

    final normalized = cropType.trim().toLowerCase();
    switch (normalized) {
      case 'cotton':
      case 'કપાસ':
        return 'cropTypeCotton';
      case 'groundnut':
      case 'મગફળી':
        return 'cropTypeGroundnut';
      case 'wheat':
      case 'ઘઉં':
        return 'cropTypeWheat';
      case 'bajra':
      case 'બાજરી':
        return 'cropTypeBajra';
      case 'maize':
      case 'મકાઈ':
        return 'cropTypeMaize';
      case 'rice':
      case 'ચોખા':
        return 'cropTypeRice';
      case 'cumin':
      case 'jiru':
      case 'જીરૂં':
      case 'જીરુ':
        return 'cropTypeJiru';
      case 'garlic':
      case 'લસણ':
      case 'lasan':
        return 'cropTypeLasan';
      case 'chickpea':
      case 'chana':
      case 'ચણા':
        return 'cropTypeChana';
      case 'sesame':
      case 'tal':
      case 'તલ':
        return 'cropTypeTal';
      case 'any':
      case 'other':
      case 'any (other)':
      case 'any(other)':
      case 'કોઈપણ':
      case 'અન્ય':
      case 'કોઈપણ (અન્ય)':
        return 'cropTypeAnyOther';
      default:
        return _cropTypeKeys.first;
    }
  }

  String _normalizeWeightUnit(String? value) {
    return value == 'man' ? 'man' : 'kg';
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

    final parsed = _tryParseNumber(raw);
    if (parsed == null) {
      return t(widget.language, 'validationEnterValidNumber');
    }

    if (parsed <= 0) {
      return t(widget.language, 'validationEnterPositiveNumber');
    }

    return null;
  }

  String _cropTypeLabel(String cropTypeKeyOrValue) {
    if (_cropTypeKeys.contains(cropTypeKeyOrValue)) {
      return t(widget.language, cropTypeKeyOrValue);
    }
    return cropTypeKeyOrValue;
  }

  void _recalculateCropProduction() {
    final selectedLand = widget.selectedLand;
    if (selectedLand == null) {
      return;
    }

    selectedLand.cropProductionKg = selectedLand.cropEntries.fold(
      0,
      (sum, entry) => sum + entry.cropWeightKg,
    );
  }

  Future<void> _showCropDialog({int? editingIndex}) async {
    final selectedLand = widget.selectedLand;
    if (selectedLand == null) {
      return;
    }

    final isEditing = editingIndex != null;
    final editingEntry = isEditing
        ? selectedLand.cropEntries[editingIndex]
        : null;

    final landSizeCtrl = TextEditingController(
      text: editingEntry?.landSize.toString() ?? '',
    );
    final cropWeightCtrl = TextEditingController(
      text: editingEntry?.cropWeight.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    var selectedCropType = editingEntry == null
        ? _cropTypeKeys.first
        : _normalizeCropTypeValue(editingEntry.cropType);
    var selectedWeightUnit = _normalizeWeightUnit(editingEntry?.weightUnit);

    final entry = await showDialog<CropEntry>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing
                    ? t(widget.language, 'updateCropButton')
                    : t(widget.language, 'addCropButton'),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedCropType,
                        decoration: InputDecoration(
                          labelText: t(widget.language, 'cropType'),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.grass),
                        ),
                        items: _cropTypeKeys
                            .map(
                              (typeKey) => DropdownMenuItem(
                                value: typeKey,
                                child: Text(t(widget.language, typeKey)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedCropType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: landSizeCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: t(widget.language, 'landSize'),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.straighten),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validatePositiveNumber,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: cropWeightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: t(widget.language, 'cropWeight'),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.scale),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validatePositiveNumber,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedWeightUnit,
                        decoration: InputDecoration(
                          labelText: t(widget.language, 'weightUnit'),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.balance),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'kg',
                            child: Text(t(widget.language, 'weightUnitKg')),
                          ),
                          DropdownMenuItem(
                            value: 'man',
                            child: Text(t(widget.language, 'weightUnitMan')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedWeightUnit = value);
                          }
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

                    final landSize = _tryParseNumber(landSizeCtrl.text);
                    final cropWeight = _tryParseNumber(cropWeightCtrl.text);
                    if (landSize == null || landSize <= 0) {
                      return;
                    }
                    if (cropWeight == null || cropWeight <= 0) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      CropEntry(
                        cropType: selectedCropType,
                        landSize: landSize,
                        cropWeight: cropWeight,
                        weightUnit: selectedWeightUnit,
                      ),
                    );
                  },
                  child: Text(
                    isEditing
                        ? t(widget.language, 'updateCropButton')
                        : t(widget.language, 'addCropButton'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || entry == null) {
      return;
    }

    setState(() {
      if (isEditing) {
        selectedLand.cropEntries[editingIndex] = entry;
      } else {
        selectedLand.cropEntries.add(entry);
      }
      _recalculateCropProduction();
    });

    widget.onSaved();
  }

  Future<void> _deleteCrop(int index) async {
    final selectedLand = widget.selectedLand;
    if (selectedLand == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t(widget.language, 'deleteCropTitle')),
          content: Text(t(widget.language, 'deleteCropConfirm')),
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
      selectedLand.cropEntries.removeAt(index);
      _recalculateCropProduction();
    });

    widget.onSaved();
  }

  Widget _buildMobileCropRecords(Land selectedLand) {
    return Column(
      children: selectedLand.cropEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final record = entry.value;
        final unitLabel = record.weightUnit == 'man'
            ? t(widget.language, 'weightUnitMan')
            : t(widget.language, 'weightUnitKg');

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cropTypeLabel(record.cropType),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${t(widget.language, 'landSize')}: ${record.landSize.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 4),
                Text(
                  '${t(widget.language, 'cropWeight')}: ${record.cropWeight.toStringAsFixed(2)} $unitLabel',
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showCropDialog(editingIndex: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCrop(index),
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

  Widget _buildDesktopCropTable(Land selectedLand) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(t(widget.language, 'cropType'))),
          DataColumn(label: Text(t(widget.language, 'landSize'))),
          DataColumn(label: Text(t(widget.language, 'cropWeight'))),
          DataColumn(label: Text(t(widget.language, 'actions'))),
        ],
        rows: selectedLand.cropEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          final unitLabel = record.weightUnit == 'man'
              ? t(widget.language, 'weightUnitMan')
              : t(widget.language, 'weightUnitKg');

          return DataRow(
            cells: [
              DataCell(Text(_cropTypeLabel(record.cropType))),
              DataCell(Text(record.landSize.toStringAsFixed(2))),
              DataCell(
                Text('${record.cropWeight.toStringAsFixed(2)} $unitLabel'),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showCropDialog(editingIndex: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCrop(index),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLand = widget.selectedLand;

    if (selectedLand == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text(t(widget.language, 'noLandSelected'))),
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(widget.language, 'navCrop'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        statCard(
          t(widget.language, 'cropProductionLabel'),
          '${selectedLand.cropProductionKg.toStringAsFixed(2)} kg',
          Colors.orange,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(t(widget.language, 'addCropButton')),
            onPressed: _showCropDialog,
          ),
        ),
        const SizedBox(height: 12),
        if (selectedLand.cropEntries.isEmpty)
          Text(t(widget.language, 'noCropRecords'))
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return _buildMobileCropRecords(selectedLand);
              }
              return _buildDesktopCropTable(selectedLand);
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
