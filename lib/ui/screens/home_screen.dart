
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/business_logic/image_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickImages(BuildContext context) async {
    // When picking images from the home screen, we always start a new session.
    final imageCubit = context.read<ImageCubit>();
    if (imageCubit.state.pickedImages.isNotEmpty) {
      imageCubit.clearImages();
    }

    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty && context.mounted) {
      imageCubit.addImages(images);
      context.go('/editor');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Genius'),
        actions: [
          // This builder will conditionally show the 'Edit' button
          BlocBuilder<ImageCubit, ImageState>(
            builder: (context, state) {
              if (state.pickedImages.isEmpty) {
                // If there are no images, show nothing.
                return const SizedBox.shrink();
              } else {
                // If there are images, show a button to go back to the editor.
                return IconButton(
                  icon: const Icon(Icons.edit_document),
                  tooltip: 'Continue Editing',
                  onPressed: () => context.go('/editor'),
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
              ElevatedButton.icon(
                icon: const Icon(Icons.image_outlined),
                label: const Text('Start New Session'),
                onPressed: () => _pickImages(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
