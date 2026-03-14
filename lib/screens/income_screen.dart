import 'package:flutter/material.dart';

import '../models/land.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';
import '../widgets/text_input_config.dart';

/// Allows the user to record / update income for the selected land.
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
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.selectedLand?.income.toString() ?? '');
  }

  @override
  void didUpdateWidget(IncomeScreen old) {
    super.didUpdateWidget(old);
    // Refresh when the selected land changes
    if (widget.selectedLand != old.selectedLand) {
      _ctrl.text = widget.selectedLand?.income.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_ctrl.text.trim()) ?? 0;
    setState(() => widget.selectedLand!.income = value);
    widget.onSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${t(widget.language, 'incomeLabel')} saved!')),
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

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            buildInput(TextInputConfig(
                _ctrl, t(widget.language, 'incomeLabel'), Icons.currency_rupee,
                number: true)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(t(widget.language, 'saveMetricsButton')),
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
