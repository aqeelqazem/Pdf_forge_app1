
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const String appName = 'PDF Genius';
    const String appVersion = '2.1.0'; // Updated Version
    const String developerName = 'Aqeel Al-Ulyawi';
    const String copyrightYear = '2026'; // Updated Year

    return Scaffold(
      appBar: AppBar(
        title: const Text('About $appName'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // App Icon (Placeholder)
              Icon(
                Icons.picture_as_pdf,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),

              // App Name and Version
              Text(
                appName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Version $appVersion',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // App Description
              Text(
                'A simple and elegant tool to convert your favorite images into a single, high-quality PDF document, ready to be shared with the world.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Copyright Information
              const Divider(),
              const SizedBox(height: 20),
              Text(
                'Developed by',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                developerName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '© $copyrightYear All rights reserved.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
