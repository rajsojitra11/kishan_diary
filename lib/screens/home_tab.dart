import 'package:flutter/material.dart';

import '../models/land.dart';
import '../utils/app_session.dart';
import '../utils/api_service.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';
import '../widgets/text_input_config.dart';

/// Displays the home dashboard — land summary stats.
/// If no lands exist it shows the Add Land form.
/// If lands exist but none is selected it shows a prompt.
class HomeTab extends StatefulWidget {
  final List<Land> lands;
  final Land? selectedLand;
  final AppLanguage language;
  final Future<bool> Function(String name, double size, String location)
  onAddLand;
  final Future<void> Function(Land) onChangeLand;

  const HomeTab({
    super.key,
    required this.lands,
    required this.selectedLand,
    required this.language,
    required this.onAddLand,
    required this.onChangeLand,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static int _lastKnownTotalBillsCount = 0;
  static const List<String> _expenseTypeKeys = [
    'expenseTypeMedicine',
    'expenseTypeSeeds',
    'expenseTypeTractor',
    'expenseTypeLightBill',
    'expenseTypeOther',
  ];
  static const List<String> _incomeTypeKeys = [
    'incomeTypeCropSale',
    'incomeTypeTractorHarvester',
    'incomeTypeVegetables',
    'incomeTypeSubsidy',
    'incomeTypeOther',
  ];
  static const List<String> _cropBreakdownTypeKeys = [
    'cropTypeCotton',
    'cropTypeGroundnut',
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _sizeCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  bool _isSubmittingSuggestion = false;
  bool _isBillsExpanded = false;
  bool _isIncomeExpanded = false;
  bool _isExpenseExpanded = false;
  bool _isCropExpanded = false;
  final Map<String, String> _landDiaryNotes = <String, String>{};
  int _totalBillsCount =
      ApiService.cachedBillsTotalCount ?? _lastKnownTotalBillsCount;
  int _completedBillsCount = 0;
  int _pendingBillsCount = 0;
  int _billsCountRequestId = 0;

  @override
  void initState() {
    super.initState();
    ApiService.billsRefreshNotifier.addListener(_onBillsChanged);
    _loadTotalBillsCount();
    _loadDiaryNotes();
  }

  void _onBillsChanged() {
    final cached = ApiService.cachedBillsTotalCount;
    if (cached != null && mounted && cached != _totalBillsCount) {
      setState(() => _totalBillsCount = cached);
      _lastKnownTotalBillsCount = cached;
    }

    _loadTotalBillsCount();
  }

  String _normalizedBillStatus(dynamic rawStatus) {
    final status = rawStatus?.toString().trim().toLowerCase() ?? '';
    return status == 'completed' ? 'completed' : 'pending';
  }

  Future<void> _loadTotalBillsCount() async {
    if (!mounted) {
      return;
    }

    final requestId = ++_billsCountRequestId;

    try {
      var allBills = await ApiService.instance.getMyBills(source: 'all');

      if (!mounted || requestId != _billsCountRequestId) {
        return;
      }

      var nextCount = allBills.length;
      var completedCount = allBills
          .where(
            (bill) =>
                _normalizedBillStatus(bill['payment_status']) == 'completed',
          )
          .length;
      var pendingCount = allBills
          .where(
            (bill) =>
                _normalizedBillStatus(bill['payment_status']) == 'pending',
          )
          .length;

      if (nextCount == 0 && _lastKnownTotalBillsCount > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 350));

        if (!mounted || requestId != _billsCountRequestId) {
          return;
        }

        allBills = await ApiService.instance.getMyBills(source: 'all');

        if (!mounted || requestId != _billsCountRequestId) {
          return;
        }

        nextCount = allBills.length;
        completedCount = allBills
            .where(
              (bill) =>
                  _normalizedBillStatus(bill['payment_status']) == 'completed',
            )
            .length;
        pendingCount = allBills
            .where(
              (bill) =>
                  _normalizedBillStatus(bill['payment_status']) == 'pending',
            )
            .length;
      }

      _lastKnownTotalBillsCount = nextCount;
      ApiService.cachedBillsTotalCount = nextCount;

      if (_totalBillsCount != nextCount ||
          _completedBillsCount != completedCount ||
          _pendingBillsCount != pendingCount) {
        setState(() {
          _totalBillsCount = nextCount;
          _completedBillsCount = completedCount;
          _pendingBillsCount = pendingCount;
        });
      }
    } on ApiException {
      // Keep previous value on transient API errors.
    } catch (_) {
      // Keep previous value on transient failures.
    }
  }

  @override
  void dispose() {
    ApiService.billsRefreshNotifier.removeListener(_onBillsChanged);
    _nameCtrl.dispose();
    _sizeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitSuggestionMessage(String message) async {
    if (!mounted) {
      return;
    }

    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSubmittingSuggestion = true);
    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      await ApiService.instance.submitSuggestion(trimmedMessage);

      if (!mounted) {
        return;
      }

      messenger?.showSnackBar(
        SnackBar(content: Text(t(widget.language, 'contactSuggestionSuccess'))),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      messenger?.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger?.showSnackBar(
        SnackBar(content: Text(t(widget.language, 'contactSuggestionError'))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingSuggestion = false);
      }
    }
  }

  Future<void> _showSuggestionDialog() async {
    final suggestionCtrl = TextEditingController();

    try {
      final message = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(t(widget.language, 'contactSuggestionTitle')),
            content: TextField(
              controller: suggestionCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: t(widget.language, 'contactSuggestionHint'),
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(t(widget.language, 'cancelButton')),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  try {
                    final text = suggestionCtrl.text.trim();
                    if (text.isEmpty) {
                      final messenger = ScaffoldMessenger.maybeOf(context);
                      messenger?.showSnackBar(
                        SnackBar(
                          content: Text(
                            t(widget.language, 'validationRequiredField'),
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(dialogContext, text);
                  } catch (_) {
                    final messenger = ScaffoldMessenger.maybeOf(context);
                    messenger?.showSnackBar(
                      SnackBar(
                        content: Text(
                          t(widget.language, 'contactSuggestionError'),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.send),
                label: Text(t(widget.language, 'contactSuggestionSubmit')),
              ),
            ],
          );
        },
      );

      if (!mounted || message == null || message.trim().isEmpty) {
        return;
      }

      await _submitSuggestionMessage(message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(t(widget.language, 'contactSuggestionError'))),
      );
    } finally {
      suggestionCtrl.dispose();
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = _nameCtrl.text.trim();
    final size = double.parse(_sizeCtrl.text.trim());
    final location = _locationCtrl.text.trim();

    final saved = await widget.onAddLand(name, size, location);
    if (!saved || !mounted) {
      return;
    }

    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _sizeCtrl.clear();
    _locationCtrl.clear();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t(widget.language, 'validationRequiredField');
    }
    return null;
  }

  String? _positiveNumberValidator(String? value) {
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

  double _majuriKharch(Land land) {
    if (land.laborEntries.isNotEmpty) {
      return land.laborEntries.fold(0.0, (sum, labor) => sum + labor.total);
    }
    return land.laborRupees;
  }

  Map<String, double> _expenseTypeTotals(Land land) {
    final totals = {for (final key in _expenseTypeKeys) key: 0.0};

    for (final entry in land.expenseEntries) {
      if (!totals.containsKey(entry.type)) {
        continue;
      }
      totals[entry.type] = (totals[entry.type] ?? 0.0) + entry.amount;
    }

    return totals;
  }

  double _expenseEntriesTotal(Land land) {
    if (land.expenseEntries.isNotEmpty) {
      return land.expenseEntries.fold(0.0, (sum, entry) => sum + entry.amount);
    }
    return land.expenses;
  }

  double _totalExpenseWithLabor(Land land) {
    return _expenseEntriesTotal(land) + _majuriKharch(land);
  }

  Map<String, double> _incomeTypeTotals(Land land) {
    final totals = {for (final key in _incomeTypeKeys) key: 0.0};

    for (final entry in land.incomeEntries) {
      if (!totals.containsKey(entry.type)) {
        continue;
      }
      totals[entry.type] = (totals[entry.type] ?? 0.0) + entry.amount;
    }

    return totals;
  }

  double _incomeEntriesTotal(Land land) {
    if (land.incomeEntries.isNotEmpty) {
      return land.incomeEntries.fold(0.0, (sum, entry) => sum + entry.amount);
    }
    return land.income;
  }

  Map<String, double> _cropTypeTotals(Land land) {
    final totals = {for (final key in _cropBreakdownTypeKeys) key: 0.0};

    for (final entry in land.cropEntries) {
      if (!totals.containsKey(entry.cropType)) {
        continue;
      }
      totals[entry.cropType] =
          (totals[entry.cropType] ?? 0.0) + entry.cropWeightKg;
    }

    return totals;
  }

  double _cropProductionTotalKg(Land land) {
    if (land.cropEntries.isNotEmpty) {
      return land.cropEntries.fold(
        0.0,
        (sum, entry) => sum + entry.cropWeightKg,
      );
    }
    return land.cropProductionKg;
  }

  Future<void> _loadDiaryNotes() async {
    try {
      final savedNotes = await AppSession.getDashboardDiaryNotes();
      if (!mounted) {
        return;
      }

      setState(() {
        _landDiaryNotes
          ..clear()
          ..addAll(savedNotes);
      });
    } catch (_) {
      // Keep defaults when persisted diary notes cannot be loaded.
    }
  }

  Future<void> _persistDiaryNotes() async {
    try {
      await AppSession.saveDashboardDiaryNotes(_landDiaryNotes);
    } catch (_) {
      // Keep UI responsive even if local persistence fails.
    }
  }

  String _landDiaryKey(Land land) {
    if (land.id != null) {
      return 'id_${land.id}';
    }
    return '${land.name}|${land.location}|${land.size.toStringAsFixed(4)}';
  }

  String _landDiaryNote(Land land) {
    return _landDiaryNotes[_landDiaryKey(land)] ?? '';
  }

  Future<void> _showDiaryNoteDialog(Land land) async {
    final noteKey = _landDiaryKey(land);
    var draftNote = _landDiaryNote(land);
    var didTapSave = false;
    const rowCount = 15;
    final keys = List<String>.filled(rowCount, '', growable: false);
    final values = List<String>.filled(rowCount, '', growable: false);

    final existingLines = draftNote.split('\n');
    for (int i = 0; i < existingLines.length && i < rowCount; i++) {
      final line = existingLines[i].trim();
      if (line.isEmpty) {
        continue;
      }

      final separatorIndex = line.indexOf('|');
      if (separatorIndex >= 0) {
        keys[i] = line.substring(0, separatorIndex).trim();
        values[i] = line.substring(separatorIndex + 1).trim();
      } else {
        keys[i] = line;
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final mediaQuery = MediaQuery.of(dialogContext);
        final availableHeight =
            mediaQuery.size.height - mediaQuery.viewInsets.bottom;
        final editorHeight = availableHeight < 620 ? 180.0 : 260.0;

        return AlertDialog(
          scrollable: true,
          title: Text(t(widget.language, 'dashboardDiaryTitle')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: editorHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    color: Colors.white,
                  ),
                  child: ListView.separated(
                    itemCount: rowCount,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE2E8F0),
                    ),
                    itemBuilder: (_, index) {
                      return SizedBox(
                        height: 42,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: keys[index],
                                onChanged: (value) {
                                  keys[index] = value;
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            Container(width: 1, color: const Color(0xFFE2E8F0)),
                            Expanded(
                              child: TextFormField(
                                initialValue: values[index],
                                onChanged: (value) {
                                  values[index] = value;
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t(widget.language, 'dashboardDiaryAutosaveHint'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                final lines = <String>[];
                for (int i = 0; i < rowCount; i++) {
                  final key = keys[i].trim();
                  final value = values[i].trim();
                  if (key.isEmpty && value.isEmpty) {
                    continue;
                  }
                  lines.add(value.isEmpty ? key : '$key | $value');
                }
                draftNote = lines.join('\n');
                didTapSave = true;
                Navigator.of(dialogContext).pop();
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(t(widget.language, 'saveButton')),
            ),
          ],
        );
      },
    );

    if (!mounted || !didTapSave) {
      return;
    }

    final result = draftNote;
    final trimmed = result.trim();
    if (trimmed.isEmpty) {
      _landDiaryNotes.remove(noteKey);
    } else {
      _landDiaryNotes[noteKey] = result;
    }
    await _persistDiaryNotes();

    if (mounted) {
      setState(() {});
    }
  }

  Widget _expenseBreakdownRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withAlpha(28),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardHeroCard({
    required Land selectedLand,
    required double profit,
    required double totalIncome,
    required double totalExpense,
  }) {
    final profitColor = profit >= 0
        ? const Color(0xFFBBF7D0)
        : Colors.red[100]!;
    final profitPrefix = profit >= 0 ? '+' : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14532D), Color(0xFF166534), Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF22C55E).withAlpha(120)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3314532D),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.landscape_rounded, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(widget.language, 'landDashboard'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD1FAE5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedLand.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${selectedLand.size.toStringAsFixed(2)} ${t(widget.language, 'landSize')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.candlestick_chart_rounded,
                color: profitColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                t(widget.language, 'profitLabel'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA7F3D0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$profitPrefix₹ ${profit.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: profitColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${t(widget.language, 'incomeLabel')}: ₹ ${totalIncome.toStringAsFixed(2)}   |   ${t(widget.language, 'expensesLabel')}: ₹ ${totalExpense.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFFDCFCE7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(90)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: child,
      ),
    );
  }

  Widget _dashboardExpandableCard({
    required bool expanded,
    required VoidCallback onTap,
    required String title,
    required String value,
    required IconData icon,
    required Color accent,
    required List<Widget> details,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3,
                  width: 52,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Row(
                  children: [
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(Icons.expand_more, color: accent),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accent.withAlpha(18),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(icon, color: accent, size: 17),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                if (expanded) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0x3F334155)),
                  ...details,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _expenseDropdownCard({
    required String title,
    required String totalValue,
    required Map<String, double> expenseTypeTotals,
    required String laborValue,
  }) {
    return _dashboardExpandableCard(
      expanded: _isExpenseExpanded,
      onTap: () {
        setState(() => _isExpenseExpanded = !_isExpenseExpanded);
      },
      title: title,
      value: totalValue,
      icon: Icons.receipt_long,
      accent: const Color(0xFFB45309),
      details: [
        for (final typeKey in _expenseTypeKeys)
          _expenseBreakdownRow(
            icon: Icons.receipt,
            label: t(widget.language, typeKey),
            value:
                '₹ ${(expenseTypeTotals[typeKey] ?? 0.0).toStringAsFixed(2)}',
            color: const Color(0xFFB45309),
          ),
        _expenseBreakdownRow(
          icon: Icons.group,
          label: t(widget.language, 'laborHoursLabel'),
          value: laborValue,
          color: const Color(0xFF1D4ED8),
        ),
      ],
    );
  }

  Widget _incomeDropdownCard({
    required String title,
    required String totalValue,
    required Map<String, double> incomeTypeTotals,
  }) {
    return _dashboardExpandableCard(
      expanded: _isIncomeExpanded,
      onTap: () {
        setState(() => _isIncomeExpanded = !_isIncomeExpanded);
      },
      title: title,
      value: totalValue,
      icon: Icons.currency_rupee,
      accent: const Color(0xFF15803D),
      details: [
        for (final typeKey in _incomeTypeKeys)
          _expenseBreakdownRow(
            icon: Icons.trending_up,
            label: t(widget.language, typeKey),
            value: '₹ ${(incomeTypeTotals[typeKey] ?? 0.0).toStringAsFixed(2)}',
            color: const Color(0xFF0F766E),
          ),
      ],
    );
  }

  Widget _cropDropdownCard({
    required String title,
    required String totalValue,
    required Map<String, double> cropTypeTotals,
  }) {
    return _dashboardExpandableCard(
      expanded: _isCropExpanded,
      onTap: () {
        setState(() => _isCropExpanded = !_isCropExpanded);
      },
      title: title,
      value: totalValue,
      icon: Icons.eco,
      accent: const Color(0xFF16A34A),
      details: [
        for (final typeKey in _cropBreakdownTypeKeys)
          _expenseBreakdownRow(
            icon: Icons.agriculture,
            label: t(widget.language, typeKey),
            value: '${(cropTypeTotals[typeKey] ?? 0.0).toStringAsFixed(2)} kg',
            color: const Color(0xFFC2410C),
          ),
      ],
    );
  }

  Widget _billsDropdownCard({
    required String title,
    required int totalCount,
    required int completedCount,
    required int pendingCount,
  }) {
    return _dashboardExpandableCard(
      expanded: _isBillsExpanded,
      onTap: () {
        setState(() => _isBillsExpanded = !_isBillsExpanded);
      },
      title: title,
      value: '$totalCount',
      icon: Icons.receipt_long,
      accent: const Color(0xFF14532D),
      details: [
        _expenseBreakdownRow(
          icon: Icons.check_circle_outline,
          label: t(widget.language, 'agroCompleted'),
          value: '$completedCount',
          color: const Color(0xFF15803D),
        ),
        _expenseBreakdownRow(
          icon: Icons.schedule,
          label: t(widget.language, 'agroPending'),
          value: '$pendingCount',
          color: const Color(0xFFB45309),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLand = widget.selectedLand;
    final majuriKharch = selectedLand == null
        ? 0.0
        : _majuriKharch(selectedLand);
    final expenseTypeTotals = selectedLand == null
        ? <String, double>{}
        : _expenseTypeTotals(selectedLand);
    final incomeTypeTotals = selectedLand == null
        ? <String, double>{}
        : _incomeTypeTotals(selectedLand);
    final totalIncome = selectedLand == null
        ? 0.0
        : _incomeEntriesTotal(selectedLand);
    final cropTypeTotals = selectedLand == null
        ? <String, double>{}
        : _cropTypeTotals(selectedLand);
    final totalCropProductionKg = selectedLand == null
        ? 0.0
        : _cropProductionTotalKg(selectedLand);
    final totalExpense = selectedLand == null
        ? 0.0
        : _totalExpenseWithLabor(selectedLand);
    final profit = totalIncome - totalExpense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Add Land Form (shown only when no land exists yet) ─────────────
        if (widget.lands.isEmpty) ...[
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(widget.language, 'addNewLand'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildInput(
                      TextInputConfig(
                        _nameCtrl,
                        t(widget.language, 'landName'),
                        Icons.landscape,
                        validator: _requiredValidator,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildInput(
                      TextInputConfig(
                        _sizeCtrl,
                        t(widget.language, 'landSize'),
                        Icons.straighten,
                        number: true,
                        validator: _positiveNumberValidator,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildInput(
                      TextInputConfig(
                        _locationCtrl,
                        t(widget.language, 'location'),
                        Icons.location_on,
                        validator: _requiredValidator,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(t(widget.language, 'addLandButton')),
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Dashboard / No Land Selected ───────────────────────────────────
        if (selectedLand == null)
          Center(child: Text(t(widget.language, 'noLandSelected')))
        else ...[
          if (widget.lands.length > 1) ...[
            const SizedBox(height: 4),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 420;
                final selectedSize = selectedLand.size.toStringAsFixed(2);

                return Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCFE8D6)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF14532D).withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.swap_horiz,
                              size: 16,
                              color: Color(0xFF14532D),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t(widget.language, 'selectLandHeading'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF14532D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Land>(
                        isExpanded: true,
                        value: selectedLand,
                        decoration: InputDecoration(
                          isDense: isCompact,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFB7D7C2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFB7D7C2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF14532D),
                              width: 1.5,
                            ),
                          ),
                          suffixText: isCompact
                              ? selectedSize
                              : '${t(widget.language, 'landSize')}: $selectedSize',
                          suffixStyle: TextStyle(fontSize: isCompact ? 12 : 13),
                        ),
                        selectedItemBuilder: (context) => widget.lands
                            .map(
                              (land) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${land.name} - ${land.size.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        items: widget.lands
                            .map(
                              (land) => DropdownMenuItem<Land>(
                                value: land,
                                child: Text(
                                  '${land.name} - ${t(widget.language, 'landSize')}: ${land.size.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (land) async {
                          if (land == null) {
                            return;
                          }
                          if (selectedLand.id != null &&
                              land.id == selectedLand.id) {
                            return;
                          }
                          if (selectedLand.id == null &&
                              identical(land, selectedLand)) {
                            return;
                          }
                          await widget.onChangeLand(land);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final notePreview = _landDiaryNote(
                selectedLand,
              ).replaceAll(RegExp(r'\s+'), ' ').trim();
              final noteCardValue = notePreview.isEmpty
                  ? t(widget.language, 'dashboardDiaryAdd')
                  : (notePreview.length > 16
                        ? '${notePreview.substring(0, 16)}...'
                        : notePreview);

              final noteCard = _quickMetricCard(
                title: t(widget.language, 'dashboardDiaryTitle'),
                value: noteCardValue,
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF1D4ED8),
                onTap: () => _showDiaryNoteDialog(selectedLand),
              );

              final useSingleColumn = constraints.maxWidth < 320;

              if (useSingleColumn) {
                return Column(
                  children: [
                    _quickMetricCard(
                      title: t(widget.language, 'incomeLabel'),
                      value: '₹ ${totalIncome.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: const Color(0xFF15803D),
                    ),
                    const SizedBox(height: 8),
                    _quickMetricCard(
                      title: t(widget.language, 'expensesLabel'),
                      value: '₹ ${totalExpense.toStringAsFixed(2)}',
                      icon: Icons.trending_down,
                      color: const Color(0xFFB45309),
                    ),
                    const SizedBox(height: 8),
                    _quickMetricCard(
                      title: t(widget.language, 'agroBillsTotal'),
                      value: '$_totalBillsCount',
                      icon: Icons.receipt_long,
                      color: const Color(0xFF14532D),
                    ),
                    const SizedBox(height: 8),
                    noteCard,
                  ],
                );
              }

              final columnWidth = (constraints.maxWidth - 8) / 2;

              return Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: columnWidth,
                        child: _quickMetricCard(
                          title: t(widget.language, 'incomeLabel'),
                          value: '₹ ${totalIncome.toStringAsFixed(2)}',
                          icon: Icons.trending_up,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: columnWidth,
                        child: _quickMetricCard(
                          title: t(widget.language, 'expensesLabel'),
                          value: '₹ ${totalExpense.toStringAsFixed(2)}',
                          icon: Icons.trending_down,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: columnWidth,
                        child: _quickMetricCard(
                          title: t(widget.language, 'agroBillsTotal'),
                          value: '$_totalBillsCount',
                          icon: Icons.receipt_long,
                          color: const Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(width: columnWidth, child: noteCard),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _incomeDropdownCard(
                  title: t(widget.language, 'incomeLabel'),
                  totalValue: '₹ ${totalIncome.toStringAsFixed(2)}',
                  incomeTypeTotals: incomeTypeTotals,
                ),
                _expenseDropdownCard(
                  title: t(widget.language, 'expensesLabel'),
                  totalValue: '₹ ${totalExpense.toStringAsFixed(2)}',
                  expenseTypeTotals: expenseTypeTotals,
                  laborValue: '₹ ${majuriKharch.toStringAsFixed(2)}',
                ),
                _billsDropdownCard(
                  title: t(widget.language, 'agroBillsTotal'),
                  totalCount: _totalBillsCount,
                  completedCount: _completedBillsCount,
                  pendingCount: _pendingBillsCount,
                ),
                _cropDropdownCard(
                  title: t(widget.language, 'cropProductionLabel'),
                  totalValue: '${totalCropProductionKg.toStringAsFixed(2)} kg',
                  cropTypeTotals: cropTypeTotals,
                ),
              ];

              if (constraints.maxWidth < 640 ||
                  _isBillsExpanded ||
                  _isExpenseExpanded ||
                  _isIncomeExpanded ||
                  _isCropExpanded) {
                return Column(
                  children: [
                    for (int i = 0; i < cards.length; i++) ...[
                      cards[i],
                      if (i != cards.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    cards[i],
                    if (i != cards.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmittingSuggestion ? null : _showSuggestionDialog,
              icon: const Icon(Icons.feedback_outlined),
              label: Text(t(widget.language, 'contactSuggestionSubmit')),
            ),
          ),
        ],
      ],
    );
  }
}
