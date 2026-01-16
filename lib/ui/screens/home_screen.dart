import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _showImageSourceDialog(BuildContext context) async {
    final imageCubit = context.read<ImageCubit>();
    final router = GoRouter.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Scan Document'),
              onTap: () async {
                Navigator.of(dialogContext).pop();
                await _scanDocument(imageCubit, router, dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                Navigator.of(dialogContext).pop();
                await _pickFromGallery(imageCubit, router);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanDocument(
      ImageCubit imageCubit, GoRouter router, BuildContext context) async {
    final pictures = await CunningDocumentScanner.getPictures();

    if (pictures != null && pictures.isNotEmpty) {
      final xFiles = pictures.map((path) => XFile(path)).toList();
      await imageCubit.startNewSession(xFiles);
      if (router.routerDelegate.navigatorKey.currentContext != null) {
        router.go('/edit');
      }
    }
  }

  Future<void> _pickFromGallery(
      ImageCubit imageCubit, GoRouter router) async {
    final pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages.isNotEmpty) {
      await imageCubit.startNewSession(pickedImages);
      if (router.routerDelegate.navigatorKey.currentContext != null) {
        router.go('/edit');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Forge'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.go('/about'),
            tooltip: 'About',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              Text('Welcome!', style: theme.textTheme.displayLarge),
              const SizedBox(height: 20),
              Text(
                'Create beautiful PDF documents from your images in seconds.',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => _showImageSourceDialog(context),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Create New PDF'),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => context.go('/library'),
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open Library'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
