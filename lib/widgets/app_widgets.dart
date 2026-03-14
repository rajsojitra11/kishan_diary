import 'package:flutter/material.dart';

import 'text_input_config.dart';

/// A reusable text input field using [TextInputConfig].
Widget buildInput(TextInputConfig config) {
  return TextField(
    controller: config.controller,
    keyboardType: config.number
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    decoration: InputDecoration(
      labelText: config.label,
      border: const OutlineInputBorder(),
      prefixIcon: Icon(config.icon),
    ),
  );
}

/// A stat card with coloured background and icon.
Widget statCard(String title, String value, Color color) {
  return Card(
    color: color.withAlpha(38),
    child: ListTile(
      leading: Icon(_iconForStat(title), color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(value, style: const TextStyle(fontSize: 15)),
    ),
  );
}

IconData _iconForStat(String title) {
  if (title.contains('Labor') || title.contains('મજૂર') || title.contains('မ')) {
    return Icons.group;
  }
  if (title.contains('Fertilizer') || title.contains('દવા')) return Icons.grass;
  if (title.contains('Income') || title.contains('આવક')) {
    return Icons.currency_rupee;
  }
  if (title.contains('Expenses') || title.contains('ખર્ચ')) return Icons.money_off;
  if (title.contains('Crop') || title.contains('ફસલ')) return Icons.agriculture;
  if (title.contains('Animal') || title.contains('પશુ')) return Icons.pets;
  return Icons.info;
}
