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

  const HomeTab({
    super.key,
    required this.lands,
    required this.selectedLand,
    required this.language,
    required this.animalIncomeGlobal,
    required this.onAddLand,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _sizeCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final _suggestionFormKey = GlobalKey<FormState>();
  final TextEditingController _suggestionCtrl = TextEditingController();
  bool _isSubmittingSuggestion = false;

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

  @override
  Widget build(BuildContext context) {
    final selectedLand = widget.selectedLand;
    final davaBiyaranExpense = selectedLand == null
        ? 0.0
        : _davaBiyaranExpense(selectedLand);
    final majuriKharch = selectedLand == null
        ? 0.0
        : _majuriKharch(selectedLand);

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
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                statCard(
                  t(widget.language, 'incomeLabel'),
                  '₹ ${selectedLand.income.toStringAsFixed(2)}',
                  Colors.teal,
                ),
                statCard(
                  t(widget.language, 'expensesLabel'),
                  '₹ ${selectedLand.expenses.toStringAsFixed(2)}',
                  Colors.red,
                ),
                statCard(
                  t(widget.language, 'cropProductionLabel'),
                  '${selectedLand.cropProductionKg.toStringAsFixed(2)} kg',
                  Colors.orange,
                ),
                statCard(
                  t(widget.language, 'fertilizerLabel'),
                  '₹ ${davaBiyaranExpense.toStringAsFixed(2)}',
                  Colors.green,
                ),
                statCard(
                  t(widget.language, 'laborHoursLabel'),
                  '₹ ${majuriKharch.toStringAsFixed(2)}',
                  Colors.blue,
                ),
                statCard(
                  t(widget.language, 'animalIncomeLabel'),
                  '₹ ${widget.animalIncomeGlobal.toStringAsFixed(2)}',
                  Colors.purple,
                ),
              ];

              if (constraints.maxWidth < 640) {
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
