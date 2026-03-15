import 'package:flutter/material.dart';

import '../models/labor_entry.dart';
import '../models/land.dart';
import '../models/upad_entry.dart';
import '../screens/edit_labour_screen.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';
import '../widgets/text_input_config.dart';

/// Full labour management screen.
/// Manages its own list of [LaborEntry] and [UpadEntry] records.
class LabourScreen extends StatefulWidget {
  final Land? selectedLand;
  final AppLanguage language;

  const LabourScreen({
    super.key,
    required this.selectedLand,
    required this.language,
  });

  @override
  State<LabourScreen> createState() => _LabourScreenState();
}

class _LabourScreenState extends State<LabourScreen> {
  // ── Labor entries state ──────────────────────────────────────────────────
  final _laborFormKey = GlobalKey<FormState>();
  bool _showLaborForm = false;

  // ── Form controllers ─────────────────────────────────────────────────────
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  // ── Computed totals ───────────────────────────────────────────────────────
  double get _totalPaid =>
      _upadEntries.fold(0, (sum, entry) => sum + entry.amount);

  double get _totalWage =>
      _laborEntries.fold(0, (sum, labor) => sum + labor.total);

  double get _totalPending =>
      _laborEntries.fold(0, (sum, labor) => sum + _totalPendingForLabor(labor));

  List<LaborEntry> get _laborEntries =>
      widget.selectedLand?.laborEntries ?? const [];

  List<UpadEntry> get _upadEntries =>
      widget.selectedLand?.upadEntries ?? const [];

  void _syncLaborMetric() {
    final land = widget.selectedLand;
    if (land == null) {
      return;
    }

    land.laborRupees = land.laborEntries.fold(
      0,
      (sum, labor) => sum + labor.total,
    );
  }

  double _totalUpadForLabor(String laborName) {
    return _upadEntries
        .where((entry) => entry.laborName == laborName)
        .fold(0, (sum, entry) => sum + entry.amount);
  }

  double _totalPendingForLabor(LaborEntry labor) {
    final pending = labor.total - _totalUpadForLabor(labor.name);
    return pending < 0 ? 0 : pending;
  }

  Widget _buildOverallSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final cards = [
          statCard(
            t(widget.language, 'laborTotalPaid'),
            '₹ ${_totalPaid.toStringAsFixed(2)}',
            Colors.teal,
          ),
          statCard(
            t(widget.language, 'laborTotalPending'),
            '₹ ${_totalPending.toStringAsFixed(2)}',
            Colors.red,
          ),
          statCard(
            t(widget.language, 'laborTotalWage'),
            '₹ ${_totalWage.toStringAsFixed(2)}',
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
  }

  void _submitEntry() {
    if (!(_laborFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final selectedLand = widget.selectedLand;
    if (selectedLand == null) {
      return;
    }

    final name = _nameCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();

    final entry = LaborEntry(name: name, mobile: mobile, days: 0, dailyRate: 0);

    setState(() {
      selectedLand.laborEntries.add(entry);
      _syncLaborMetric();
      _clearForm();
    });
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
    final laborUpads = _upadEntries
        .where((entry) => entry.laborName == labor.name)
        .toList();

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
      selectedLand.upadEntries
        ..removeWhere((entry) => entry.laborName == result.originalLaborName)
        ..addAll(result.updatedUpadEntries);
      _syncLaborMetric();
    });
  }

  void _remove(int idx) {
    final selectedLand = widget.selectedLand;
    if (selectedLand == null) {
      return;
    }

    final laborName = _laborEntries[idx].name;
    setState(() {
      selectedLand.laborEntries.removeAt(idx);
      selectedLand.upadEntries.removeWhere(
        (entry) => entry.laborName == laborName,
      );
      _syncLaborMetric();
    });
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
                onPressed: () => setState(() => _showLaborForm = true),
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

        // ── Labour Entry List ─────────────────────────────────────────────
        if (!_showLaborForm && _laborEntries.isNotEmpty) ...[
          Text(
            t(widget.language, 'navLabor'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._laborEntries.asMap().entries.map((e) {
            final idx = e.key;
            final labor = e.value;
            final totalUpad = _totalUpadForLabor(labor.name);
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
                  '${labor.name}  •  ${labor.days} ${t(widget.language, 'laborDay')}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t(widget.language, 'laborTotalPaid')} ${totalUpad.toStringAsFixed(2)}',
                    ),
                    Text(
                      '${t(widget.language, 'laborTotalPending')} ${totalPending.toStringAsFixed(2)}',
                    ),
                    Text(
                      '${t(widget.language, 'laborTotalWage')} ${labor.total.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _startEdit(idx),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmRemove(idx),
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
