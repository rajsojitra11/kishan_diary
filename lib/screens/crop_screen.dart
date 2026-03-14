import 'package:flutter/material.dart';

import '../models/land.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';
import '../widgets/text_input_config.dart';

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
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.selectedLand?.cropProductionKg.toString() ?? '');
  }

  @override
  void didUpdateWidget(CropScreen old) {
    super.didUpdateWidget(old);
    if (widget.selectedLand != old.selectedLand) {
      _ctrl.text = widget.selectedLand?.cropProductionKg.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_ctrl.text.trim()) ?? 0;
    setState(() => widget.selectedLand!.cropProductionKg = value);
    widget.onSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${t(widget.language, 'cropProductionLabel')} saved!')),
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
              t(widget.language, 'navCrop'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            statCard(
              t(widget.language, 'cropProductionLabel'),
              '${widget.selectedLand!.cropProductionKg.toStringAsFixed(2)} kg',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            buildInput(TextInputConfig(
                _ctrl, t(widget.language, 'cropProductionLabel'),
                Icons.agriculture,
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
