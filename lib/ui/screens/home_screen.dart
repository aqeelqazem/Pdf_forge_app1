import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:myapp/main.dart'; // Import main.dart to access ThemeProvider
import 'package:provider/provider.dart'; // Import provider

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickImages(BuildContext context) async {
    final imageCubit = context.read<ImageCubit>();
    if (imageCubit.state.pickedImages.isNotEmpty) {
      final bool? shouldClear = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Start New Session?'),
          content: const Text(
              'Starting a new session will clear your current images. Do you want to continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (shouldClear != true) {
        return;
      }
    }

    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (!context.mounted || images.isEmpty) return;

    await imageCubit.addImages(images);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return BlocListener<ImageCubit, ImageState>(
      listenWhen: (previous, current) {
        return previous.pickedImages.isEmpty && current.pickedImages.isNotEmpty;
      },
      listener: (context, state) {
        context.go('/display');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PDF Genius'),
          actions: [
            IconButton(
              icon: Icon(themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              tooltip: 'Toggle Theme',
              onPressed: () => themeProvider.toggleTheme(),
            ),
            BlocBuilder<ImageCubit, ImageState>(
              builder: (context, state) {
                if (state.pickedImages.isEmpty) {
                  return const SizedBox.shrink();
                } else {
                  return IconButton(
                    icon: const Icon(Icons.edit_document),
                    tooltip: 'Continue Editing',
                    onPressed: () => context.go('/display'),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'About App',
              onPressed: () => context.go('/about'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: <Widget>[
              const Spacer(flex: 2),
              const Icon(
                Icons.add_photo_alternate_outlined,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to PDF Genius',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Create beautiful PDF documents from your images in seconds.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Start New Session'),
                    onPressed: () => _pickImages(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      textStyle: theme.textTheme.titleMedium,
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Library'),
                    onPressed: () => context.go('/library'),
                    style: OutlinedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      textStyle: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
