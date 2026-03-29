import 'package:flutter/material.dart';

import '../../utils/localization.dart';

class AgroFarmersTab extends StatelessWidget {
  const AgroFarmersTab({
    super.key,
    required this.language,
    required this.farmers,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAddFarmer,
    required this.onEditFarmer,
    required this.onDeleteFarmer,
  });

  final AppLanguage language;
  final List<Map<String, dynamic>> farmers;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddFarmer;
  final void Function(Map<String, dynamic> farmer) onEditFarmer;
  final void Function(Map<String, dynamic> farmer) onDeleteFarmer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddFarmer,
            icon: const Icon(Icons.person_add),
            label: Text(t(language, 'agroAddFarmerButton')),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t(language, 'agroFarmersList'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: t(language, 'agroSearchFarmerHint'),
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        if (farmers.isEmpty)
          Text(
            searchQuery.trim().isEmpty
                ? t(language, 'agroNoFarmers')
                : t(language, 'agroNoSearchFarmers'),
          )
        else
          ...farmers.map(
            (farmer) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(farmer['name']?.toString() ?? '-'),
                subtitle: Text(
                  '${t(language, 'contactMobileLabel')}: ${farmer['mobile'] ?? '-'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => onEditFarmer(farmer),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () => onDeleteFarmer(farmer),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
