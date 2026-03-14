import 'package:flutter/material.dart';

import '../utils/localization.dart';
import '../widgets/app_widgets.dart';
import '../widgets/text_input_config.dart';

/// Allows the user to record / update animal (pet) income.
/// Does NOT require a land to be selected.
class AnimalScreen extends StatefulWidget {
  final AppLanguage language;
  final double animalIncome;
  final void Function(double income) onSaved;

  const AnimalScreen({
    super.key,
    required this.language,
    required this.animalIncome,
    required this.onSaved,
  });

  @override
  State<AnimalScreen> createState() => _AnimalScreenState();
}

class _AnimalScreenState extends State<AnimalScreen> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.animalIncome.toString());
  }

  @override
  void didUpdateWidget(AnimalScreen old) {
    super.didUpdateWidget(old);
    if (widget.animalIncome != old.animalIncome) {
      _ctrl.text = widget.animalIncome.toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_ctrl.text.trim()) ?? 0;
    widget.onSaved(value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${t(widget.language, 'animalIncomeLabel')} saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(widget.language, 'navAnimal'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            statCard(
              t(widget.language, 'animalIncomeLabel'),
              '₹ ${widget.animalIncome.toStringAsFixed(2)}',
              Colors.purple,
            ),
            const SizedBox(height: 12),
            buildInput(TextInputConfig(
                _ctrl, t(widget.language, 'animalIncomeLabel'), Icons.pets,
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
