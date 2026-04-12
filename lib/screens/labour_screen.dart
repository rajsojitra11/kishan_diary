import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/labor_entry.dart';
import '../models/land.dart';
import '../models/upad_entry.dart';
import '../screens/edit_labour_screen.dart';
import '../providers/app_providers.dart';
import '../utils/api_service.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';
import '../widgets/text_input_config.dart';

/// Full labour management screen.
/// Manages its own list of [LaborEntry] and [UpadEntry] records.
class LabourScreen extends ConsumerStatefulWidget {
  final Land? selectedLand;
  final AppLanguage language;
  final VoidCallback onSaved;
  final int closeAddFormSignal;
  final ValueChanged<bool>? onAddFormVisibilityChanged;

  const LabourScreen({
    super.key,
    required this.selectedLand,
    required this.language,
    required this.onSaved,
    this.closeAddFormSignal = 0,
    this.onAddFormVisibilityChanged,
  });

  @override
  ConsumerState<LabourScreen> createState() => _LabourScreenState();
}

class _LabourScreenState extends ConsumerState<LabourScreen> {
  // ── Labor entries state ──────────────────────────────────────────────────
  final _laborFormKey = GlobalKey<FormState>();
  bool _showLaborForm = false;
  bool _loading = false;

  // ── Form controllers ─────────────────────────────────────────────────────
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _laborSearchCtrl = TextEditingController();

  @override
  void dispose() {
    widget.onAddFormVisibilityChanged?.call(false);
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _laborSearchCtrl.dispose();
    super.dispose();
  }

  // ── Computed totals ───────────────────────────────────────────────────────
  double get _totalPaid =>
      _upadEntries.fold(0.0, (sum, entry) => sum + entry.amount);

  double get _totalWage =>
      _laborEntries.fold(0.0, (sum, labor) => sum + labor.total);

  double get _totalPending => _laborEntries.fold(
    0.0,
    (sum, labor) => sum + _totalPendingForLabor(labor),
  );

  List<LaborEntry> get _laborEntries =>
      widget.selectedLand?.laborEntries ?? const [];

  List<UpadEntry> get _upadEntries =>
      widget.selectedLand?.upadEntries ?? const [];

  String _normalizeSearchText(String value) {
    return value.toLowerCase().trim();
  }

  List<LaborEntry> get _filteredLaborEntries {
    final query = _normalizeSearchText(_laborSearchCtrl.text);
    if (query.isEmpty) {
      return _laborEntries;
    }

    return _laborEntries.where((labor) {
      final name = _normalizeSearchText(labor.name);
      final mobile = _normalizeSearchText(labor.mobile);
      return name.contains(query) || mobile.contains(query);
    }).toList();
  }

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
      name: item['labor_name']?.toString() ?? '',
      mobile: item['mobile']?.toString() ?? '',
      days: _toDouble(item['total_days']),
      dailyRate: _toDouble(item['daily_rate']),
    );
  }

  UpadEntry _upadFromApi(Map<String, dynamic> item, LaborEntry labor) {
    final snapshot = item['labor_name_snapshot']?.toString();
    return UpadEntry(
      id: _toInt(item['id']),
      laborEntryId: _toInt(item['labor_entry_id']) ?? labor.id,
      landId: _toInt(item['land_id']),
      laborName: snapshot == null || snapshot.trim().isEmpty
          ? labor.name
          : snapshot,
      amount: _toDouble(item['amount']),
      note: item['note']?.toString() ?? '',
      date: _toDisplayDate(item['payment_date']?.toString()),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.onAddFormVisibilityChanged?.call(_showLaborForm);
    _loadLaborEntries();
  }

  @override
  void didUpdateWidget(covariant LabourScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.closeAddFormSignal != widget.closeAddFormSignal &&
        _showLaborForm) {
      setState(_clearForm);
    }
    if (oldWidget.selectedLand?.id != widget.selectedLand?.id) {
      _loadLaborEntries();
    }
  }

  Future<void> _loadLaborEntries() async {
    final land = widget.selectedLand;
    if (land == null || land.id == null) {
      return;
    }

    setState(() => _loading = true);

    try {
      final payload = await ref
          .read(apiServiceProvider)
          .getLaborEntries(land.id!);
      final laborEntries = ((payload['labor_entries'] as List?) ?? [])
          .map((item) => _laborFromApi((item as Map).cast<String, dynamic>()))
          .toList();

      final upadEntries = <UpadEntry>[];
      for (final labor in laborEntries) {
        if (labor.id == null) {
          continue;
        }

        final upadPayload = await ref
            .read(apiServiceProvider)
            .getUpadEntries(labor.id!);
        final entries = ((upadPayload['upad_entries'] as List?) ?? [])
            .map(
              (item) =>
                  _upadFromApi((item as Map).cast<String, dynamic>(), labor),
            )
            .toList();
        upadEntries.addAll(entries);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        land.laborEntries
          ..clear()
          ..addAll(laborEntries);
        land.upadEntries
          ..clear()
          ..addAll(upadEntries);
        land.laborRupees = _toDouble(
          ((payload['totals'] as Map?)?['total_wage']),
        );
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

  String _formatDays(double days) {
    if (days == days.truncateToDouble()) {
      return days.toInt().toString();
    }
    return days.toString();
  }

  String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toInt().toString();
    }
    return amount
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _syncLaborMetric() {
    final land = widget.selectedLand;
    if (land == null) {
      return;
    }

    land.laborRupees = land.laborEntries.fold(
      0.0,
      (sum, labor) => sum + labor.total,
    );
  }

  double _totalUpadForLabor(LaborEntry labor) {
    return _upadEntries
        .where((entry) {
          if (labor.id != null && entry.laborEntryId != null) {
            return entry.laborEntryId == labor.id;
          }
          return entry.laborName == labor.name;
        })
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  double _totalPendingForLabor(LaborEntry labor) {
    final pending = labor.total - _totalUpadForLabor(labor);
    return pending < 0 ? 0.0 : pending;
  }

  Widget _buildOverallSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final cards = [
          statCard(
            t(widget.language, 'laborTotalPaid'),
            '₹ ${_formatAmount(_totalPaid)}',
            Colors.teal,
          ),
          statCard(
            t(widget.language, 'laborTotalPending'),
            '₹ ${_formatAmount(_totalPending)}',
            Colors.red,
          ),
          statCard(
            t(widget.language, 'laborTotalWage'),
            '₹ ${_formatAmount(_totalWage)}',
            Colors.indigo,
          ),
        ];

        if (isMobile) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 8),
              cards[1],
              const SizedBox(height: 8),
              cards[2],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 8),
            Expanded(child: cards[1]),
            const SizedBox(width: 8),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _clearForm() {
    _nameCtrl.clear();
    _mobileCtrl.clear();
    _showLaborForm = false;
    widget.onAddFormVisibilityChanged?.call(false);
  }

  Future<void> _submitEntry() async {
    if (!(_laborFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final selectedLand = widget.selectedLand;
    if (selectedLand == null) {
      return;
    }

    final name = _nameCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();

    final entry = LaborEntry(
      name: name,
      mobile: mobile,
      days: 0.0,
      dailyRate: 0.0,
    );

    if (selectedLand.id == null) {
      setState(() {
        selectedLand.laborEntries.add(entry);
        _syncLaborMetric();
        _clearForm();
      });
      widget.onSaved();
      return;
    }

    try {
      final payload = await ref
          .read(apiServiceProvider)
          .createLaborEntry(
            landId: selectedLand.id!,
            laborName: name,
            mobile: mobile,
          );

      final created = _laborFromApi(
        ((payload['labor_entry'] as Map?) ?? {}).cast<String, dynamic>(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        selectedLand.laborEntries.add(created);
        selectedLand.laborRupees = _toDouble(
          ((payload['land_totals'] as Map?)?['labor_rupees']),
        );
        _clearForm();
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

  Future<void> _startEdit(int idx) async {
    final selectedLand = widget.selectedLand;
    if (selectedLand == null) {
      return;
    }

    final labor = _laborEntries[idx];
    final laborUpads = _upadEntries.where((entry) {
      if (labor.id != null && entry.laborEntryId != null) {
        return entry.laborEntryId == labor.id;
      }
      return entry.laborName == labor.name;
    }).toList();

    final result = await Navigator.push<EditLabourResult>(
      context,
      MaterialPageRoute(
        builder: (_) => EditLabourScreen(
          language: widget.language,
          initialEntry: labor,
          initialUpadEntries: laborUpads,
        ),
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedLand.laborEntries[idx] = result.updatedLabor;
      if (result.updatedLabor.id != null) {
        selectedLand.upadEntries.removeWhere(
          (entry) => entry.laborEntryId == result.updatedLabor.id,
        );
      } else {
        selectedLand.upadEntries.removeWhere(
          (entry) => entry.laborName == result.originalLaborName,
        );
      }
      selectedLand.upadEntries.addAll(result.updatedUpadEntries);
      _syncLaborMetric();
    });
    widget.onSaved();
  }

  Future<void> _remove(int idx) async {
    final selectedLand = widget.selectedLand;
    if (selectedLand == null) {
      return;
    }

    final labor = _laborEntries[idx];

    if (labor.id == null) {
      setState(() {
        selectedLand.laborEntries.removeAt(idx);
        selectedLand.upadEntries.removeWhere(
          (entry) => entry.laborName == labor.name,
        );
        _syncLaborMetric();
      });
      widget.onSaved();
      return;
    }

    try {
      final payload = await ref
          .read(apiServiceProvider)
          .deleteLaborEntry(labor.id!);

      if (!mounted) {
        return;
      }

      setState(() {
        selectedLand.laborEntries.removeAt(idx);
        selectedLand.upadEntries.removeWhere(
          (entry) => entry.laborEntryId == labor.id,
        );
        selectedLand.laborRupees = _toDouble(
          ((payload['land_totals'] as Map?)?['labor_rupees']),
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

  Future<void> _confirmRemove(int idx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t(widget.language, 'deleteLaborTitle')),
          content: Text(t(widget.language, 'deleteLaborConfirm')),
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

    if (confirmed == true) {
      _remove(idx);
    }
  }

  int _indexOfLaborEntry(LaborEntry labor) {
    if (labor.id != null) {
      final idMatchIndex = _laborEntries.indexWhere(
        (item) => item.id == labor.id,
      );
      if (idMatchIndex != -1) {
        return idMatchIndex;
      }
    }

    return _laborEntries.indexWhere((item) => identical(item, labor));
  }

  void _startEditByEntry(LaborEntry labor) {
    final index = _indexOfLaborEntry(labor);
    if (index == -1) {
      return;
    }
    _startEdit(index);
  }

  void _confirmRemoveByEntry(LaborEntry labor) {
    final index = _indexOfLaborEntry(labor);
    if (index == -1) {
      return;
    }
    _confirmRemove(index);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (widget.selectedLand == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(t(widget.language, 'selectLandFirst'))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Add New Labour Button ─────────────────────────────────────────
        if (!_showLaborForm)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: Text(t(widget.language, 'laborFormButton')),
                onPressed: () {
                  setState(() => _showLaborForm = true);
                  widget.onAddFormVisibilityChanged?.call(true);
                },
              ),
            ),
          ),

        // ── Labour Entry Form ─────────────────────────────────────────────
        if (_showLaborForm)
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _laborFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(widget.language, 'navLabor'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildInput(
                      TextInputConfig(
                        _nameCtrl,
                        t(widget.language, 'laborName'),
                        Icons.person,
                        validator: _requiredValidator,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildInput(
                      TextInputConfig(
                        _mobileCtrl,
                        t(widget.language, 'laborMobile'),
                        Icons.phone,
                        number: true,
                        validator: _mobileValidator,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text(t(widget.language, 'laborAddButton')),
                            onPressed: _submitEntry,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => setState(_clearForm),
                          child: Text(t(widget.language, 'cancelButton')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildOverallSummaryCards(),
                  ],
                ),
              ),
            ),
          ),

        const SizedBox(height: 12),

        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          ),

        // ── Labour Entry List ─────────────────────────────────────────────
        if (!_loading && !_showLaborForm && _laborEntries.isNotEmpty) ...[
          Text(
            t(widget.language, 'navLabor'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _laborSearchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: t(widget.language, 'laborSearchHint'),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _laborSearchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _laborSearchCtrl.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          if (_filteredLaborEntries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(t(widget.language, 'laborSearchNoResults')),
            )
          else
            ..._filteredLaborEntries.map((labor) {
              final totalUpad = _totalUpadForLabor(labor);
              final totalPending = _totalPendingForLabor(labor);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(
                    '${labor.name}  •  ${_formatDays(labor.days)} ${t(widget.language, 'laborWord')}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            size: 14,
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                t(widget.language, 'laborTotalPaid'),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(_formatAmount(totalUpad), maxLines: 1),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                t(widget.language, 'laborTotalPending'),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(_formatAmount(totalPending), maxLines: 1),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            size: 14,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                t(widget.language, 'laborTotalWage'),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(_formatAmount(labor.total), maxLines: 1),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.note_alt,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () => _startEditByEntry(labor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _confirmRemoveByEntry(labor),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

          // ── Summary bar when form is hidden ──────────────────────────
          if (!_showLaborForm)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildOverallSummaryCards(),
            ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}
