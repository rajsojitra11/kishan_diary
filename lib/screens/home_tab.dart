import 'package:flutter/material.dart';

import '../models/land.dart';
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
  final void Function(String name, double size, String location) onAddLand;

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
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _sizeCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sizeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final size = double.tryParse(_sizeCtrl.text.trim()) ?? 0;
    final location = _locationCtrl.text.trim();

    if (name.isEmpty || size <= 0 || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'enterValidLand'))),
      );
      return;
    }

    widget.onAddLand(name, size, location);
    _nameCtrl.clear();
    _sizeCtrl.clear();
    _locationCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Add Land Form (shown only when no land exists yet) ─────────────
        if (widget.lands.isEmpty) ...[
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(widget.language, 'addNewLand'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  buildInput(TextInputConfig(
                      _nameCtrl, t(widget.language, 'landName'),
                      Icons.landscape)),
                  const SizedBox(height: 10),
                  buildInput(TextInputConfig(
                      _sizeCtrl, t(widget.language, 'landSize'), Icons.straighten,
                      number: true)),
                  const SizedBox(height: 10),
                  buildInput(TextInputConfig(
                      _locationCtrl, t(widget.language, 'location'),
                      Icons.location_on)),
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
          const SizedBox(height: 16),
        ],

        // ── Dashboard / No Land Selected ───────────────────────────────────
        if (widget.selectedLand == null)
          Center(child: Text(t(widget.language, 'noLandSelected')))
        else ...[
          Text(
            t(widget.language, 'landDashboard'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.4,
            children: [
              statCard(
                t(widget.language, 'incomeLabel'),
                '₹ ${widget.selectedLand!.income.toStringAsFixed(2)}',
                Colors.teal,
              ),
              statCard(
                t(widget.language, 'expensesLabel'),
                '₹ ${widget.selectedLand!.expenses.toStringAsFixed(2)}',
                Colors.red,
              ),
              statCard(
                t(widget.language, 'cropProductionLabel'),
                '${widget.selectedLand!.cropProductionKg.toStringAsFixed(2)} kg',
                Colors.orange,
              ),
              statCard(
                t(widget.language, 'fertilizerLabel'),
                '₹ ${widget.selectedLand!.fertilizerKg.toStringAsFixed(2)}',
                Colors.green,
              ),
              statCard(
                t(widget.language, 'laborHoursLabel'),
                '${widget.selectedLand!.laborHours} hrs',
                Colors.blue,
              ),
              statCard(
                t(widget.language, 'animalIncomeLabel'),
                '₹ ${widget.animalIncomeGlobal.toStringAsFixed(2)}',
                Colors.purple,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
