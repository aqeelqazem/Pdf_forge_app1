import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About PDF Forge'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Icon(
              Icons.picture_as_pdf,
              size: 100,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'PDF Forge',
              style: theme.textTheme.displaySmall,
            ),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            const Text(
              'Create beautiful PDF documents from your images in seconds.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              'Developed by Aqeel Al-Ulyawi',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '© 2024 All rights reserved.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
