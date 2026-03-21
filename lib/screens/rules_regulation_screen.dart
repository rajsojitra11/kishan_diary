import 'package:flutter/material.dart';

import '../utils/localization.dart';

class RulesRegulationScreen extends StatelessWidget {
  const RulesRegulationScreen({super.key, required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t(language, 'drawerTermsConditions'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(language, 'rulesPageTitle'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('1. ${t(language, 'rule1')}'),
                const SizedBox(height: 8),
                Text('2. ${t(language, 'rule2')}'),
                const SizedBox(height: 8),
                Text('3. ${t(language, 'rule3')}'),
                const SizedBox(height: 8),
                Text('4. ${t(language, 'rule4')}'),
                const SizedBox(height: 8),
                Text('5. ${t(language, 'rule5')}'),
                const SizedBox(height: 8),
                Text('6. ${t(language, 'rule6')}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
