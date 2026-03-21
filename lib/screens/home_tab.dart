import 'package:flutter/material.dart';

import '../models/land.dart';
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
  final double animalIncomeGlobal;
  final Future<bool> Function(String name, double size, String location)
  onAddLand;
  final ValueChanged<Land> onChangeLand;

  const HomeTab({
    super.key,
    required this.lands,
    required this.selectedLand,
    required this.language,
    required this.animalIncomeGlobal,
    required this.onAddLand,
    required this.onChangeLand,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
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
  final _suggestionFormKey = GlobalKey<FormState>();
  final TextEditingController _suggestionCtrl = TextEditingController();
  bool _isSubmittingSuggestion = false;
  bool _isIncomeExpanded = false;
  bool _isExpenseExpanded = false;
  bool _isCropExpanded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sizeCtrl.dispose();
    _locationCtrl.dispose();
    _suggestionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitSuggestion() async {
    if (!(_suggestionFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final message = _suggestionCtrl.text.trim();
    if (message.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _suggestionCtrl.clear();
      _suggestionFormKey.currentState?.reset();
      _isSubmittingSuggestion = true;
    });

    try {
      await ApiService.instance.submitSuggestion(message);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'contactSuggestionSuccess'))),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _isSubmittingSuggestion = false);
      }
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

  double _davaBiyaranExpense(Land land) {
    const davaBiyaranTypes = {'expenseTypeMedicine', 'expenseTypeSeeds'};

    return land.expenseEntries
        .where((entry) => davaBiyaranTypes.contains(entry.type))
        .fold(0.0, (sum, entry) => sum + entry.amount);
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

  Widget _expenseBreakdownRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _expenseDropdownCard({
    required String title,
    required String totalValue,
    required Map<String, double> expenseTypeTotals,
    required String laborValue,
  }) {
    const baseColor = Colors.red;

    return Card(
      color: baseColor.withAlpha(38),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _isExpenseExpanded = !_isExpenseExpanded);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isExpenseExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right,
                    color: baseColor,
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.receipt_long, color: baseColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(totalValue, style: const TextStyle(fontSize: 15)),
                ],
              ),
              if (_isExpenseExpanded) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                for (final typeKey in _expenseTypeKeys)
                  _expenseBreakdownRow(
                    icon: Icons.receipt,
                    label: t(widget.language, typeKey),
                    value:
                        '₹ ${(expenseTypeTotals[typeKey] ?? 0.0).toStringAsFixed(2)}',
                    color: Colors.deepOrange,
                  ),
                _expenseBreakdownRow(
                  icon: Icons.group,
                  label: t(widget.language, 'laborHoursLabel'),
                  value: laborValue,
                  color: Colors.blue,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _incomeDropdownCard({
    required String title,
    required String totalValue,
    required Map<String, double> incomeTypeTotals,
  }) {
    const baseColor = Colors.teal;

    return Card(
      color: baseColor.withAlpha(38),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _isIncomeExpanded = !_isIncomeExpanded);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isIncomeExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right,
                    color: baseColor,
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.currency_rupee, color: baseColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(totalValue, style: const TextStyle(fontSize: 15)),
                ],
              ),
              if (_isIncomeExpanded) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                for (final typeKey in _incomeTypeKeys)
                  _expenseBreakdownRow(
                    icon: Icons.trending_up,
                    label: t(widget.language, typeKey),
                    value:
                        '₹ ${(incomeTypeTotals[typeKey] ?? 0.0).toStringAsFixed(2)}',
                    color: Colors.teal,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cropDropdownCard({
    required String title,
    required String totalValue,
    required Map<String, double> cropTypeTotals,
  }) {
    const baseColor = Colors.orange;

    return Card(
      color: baseColor.withAlpha(38),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _isCropExpanded = !_isCropExpanded);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isCropExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right,
                    color: baseColor,
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.eco, color: baseColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(totalValue, style: const TextStyle(fontSize: 15)),
                ],
              ),
              if (_isCropExpanded) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                for (final typeKey in _cropBreakdownTypeKeys)
                  _expenseBreakdownRow(
                    icon: Icons.agriculture,
                    label: t(widget.language, typeKey),
                    value:
                        '${(cropTypeTotals[typeKey] ?? 0.0).toStringAsFixed(2)} kg',
                    color: Colors.orange,
                  ),
              ],
            ],
          ),
        ),
      ),
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
          Text(
            t(widget.language, 'landDashboard'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (widget.lands.length > 1) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<Land>(
              value: selectedLand,
              decoration: InputDecoration(
                labelText: t(widget.language, 'selectLandHeading'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.swap_horiz),
              ),
              items: widget.lands
                  .map(
                    (land) => DropdownMenuItem<Land>(
                      value: land,
                      child: Text('${land.name} (${land.location})'),
                    ),
                  )
                  .toList(),
              onChanged: (land) {
                if (land == null || identical(land, selectedLand)) {
                  return;
                }
                widget.onChangeLand(land);
              },
            ),
          ],
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                statCard(
                  t(widget.language, 'profitLabel'),
                  '₹ ${profit.toStringAsFixed(2)}',
                  profit >= 0 ? Colors.green : Colors.red,
                ),
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
                _cropDropdownCard(
                  title: t(widget.language, 'cropProductionLabel'),
                  totalValue: '${totalCropProductionKg.toStringAsFixed(2)} kg',
                  cropTypeTotals: cropTypeTotals,
                ),
                statCard(
                  t(widget.language, 'animalIncomeLabel'),
                  '₹ ${widget.animalIncomeGlobal.toStringAsFixed(2)}',
                  Colors.purple,
                ),
              ];

              if (constraints.maxWidth < 640 ||
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

              final crossAxisCount = constraints.maxWidth >= 1100 ? 3 : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: crossAxisCount == 2 ? 2.2 : 2.4,
                ),
                itemBuilder: (_, index) => cards[index],
              );
            },
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _suggestionFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(widget.language, 'contactSuggestionTitle'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _suggestionCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: t(widget.language, 'contactSuggestionHint'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmittingSuggestion
                            ? null
                            : _submitSuggestion,
                        icon: const Icon(Icons.send),
                        label: Text(
                          t(widget.language, 'contactSuggestionSubmit'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
