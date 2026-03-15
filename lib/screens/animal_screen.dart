import 'package:flutter/material.dart';

import '../models/animal.dart';
import '../screens/animal_detail_screen.dart';
import '../utils/api_service.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';
import '../widgets/text_input_config.dart';

class AnimalScreen extends StatefulWidget {
  final AppLanguage language;
  final List<Animal> animals;
  final ValueChanged<List<Animal>> onAnimalsChanged;

  const AnimalScreen({
    super.key,
    required this.language,
    required this.animals,
    required this.onAnimalsChanged,
  });

  @override
  State<AnimalScreen> createState() => _AnimalScreenState();
}

class _AnimalScreenState extends State<AnimalScreen> {
  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  double get _totalAnimalIncome {
    return widget.animals.fold(0.0, (sum, animal) => sum + animal.totalAmount);
  }

  void _notifyAnimalsChanged() {
    widget.onAnimalsChanged(List<Animal>.from(widget.animals));
    setState(() {});
  }

  void _showAddAnimalDialog() {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t(widget.language, 'addAnimalButton')),
        content: Form(
          key: formKey,
          child: buildInput(
            TextInputConfig(
              nameController,
              t(widget.language, 'animalNameLabel'),
              Icons.pets,
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) {
                  return t(widget.language, 'validationRequiredField');
                }

                final exists = widget.animals.any(
                  (animal) => animal.name.toLowerCase() == name.toLowerCase(),
                );

                if (exists) {
                  return t(widget.language, 'animalExists');
                }

                return null;
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t(widget.language, 'cancelButton')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              final name = nameController.text.trim();

              try {
                final payload = await ApiService.instance.createAnimal(name);
                final animalPayload = ((payload['animal'] as Map?) ?? {})
                    .cast<String, dynamic>();

                if (!mounted) {
                  return;
                }

                final updated = List<Animal>.from(widget.animals)
                  ..add(
                    Animal(
                      id: _toInt(animalPayload['id']),
                      name: animalPayload['animal_name']?.toString() ?? name,
                      totalAmountCached: 0,
                      totalMilkCached: 0,
                    ),
                  );
                widget.onAnimalsChanged(updated);
              } on ApiException catch (error) {
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.message)));
                return;
              }

              Navigator.pop(context);
            },
            child: Text(t(widget.language, 'saveButton')),
          ),
        ],
      ),
    );
  }

  void _openAnimalDetail(Animal animal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimalDetailScreen(
          animal: animal,
          language: widget.language,
          onChanged: _notifyAnimalsChanged,
        ),
      ),
    ).then((_) => _notifyAnimalsChanged());
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
              '₹ ${_totalAnimalIncome.toStringAsFixed(2)}',
              Colors.purple,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(t(widget.language, 'addAnimalButton')),
                onPressed: _showAddAnimalDialog,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t(widget.language, 'animalListLabel'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.animals.isEmpty)
              Text(t(widget.language, 'animalNoAnimals'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.animals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final animal = widget.animals[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.pets, color: Colors.purple),
                      title: Text(animal.name),
                      subtitle: Text(
                        '₹ ${animal.totalAmount.toStringAsFixed(2)} • ${animal.totalMilk.toStringAsFixed(2)} L',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openAnimalDetail(animal),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
