import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/business_logic/image_cubit.dart';

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

      imageCubit.clearImages();
    }

    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (!context.mounted || images.isEmpty) return;

    // Navigation logic is now fully handled by GoRouter's redirect function.
    // This cubit change will trigger the router's listener.
    await imageCubit.addImages(images);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The BlocListener has been removed as per the approved architecture.
    // The Scaffold is now the top-level widget.
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Genius'),
        actions: [
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Library'),
                    onPressed: () => context.go('/library'),
                    style: OutlinedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      textStyle: theme.textTheme.titleMedium,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
