import 'package:flutter/material.dart';

import '../utils/localization.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key, required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t(language, 'drawerAbout'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(language, 'aboutPageTitle'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(t(language, 'aboutPageIntro')),
                const SizedBox(height: 16),
                Text(
                  t(language, 'aboutPageFeaturesTitle'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text('• ${t(language, 'aboutFeature1')}'),
                const SizedBox(height: 4),
                Text('• ${t(language, 'aboutFeature2')}'),
                const SizedBox(height: 4),
                Text('• ${t(language, 'aboutFeature3')}'),
                const SizedBox(height: 4),
                Text('• ${t(language, 'aboutFeature4')}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
