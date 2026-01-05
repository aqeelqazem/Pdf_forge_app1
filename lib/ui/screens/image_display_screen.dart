
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:myapp/services/pdf_service.dart';
import 'package:myapp/ui/widgets/image_grid.dart';
import 'package:share_plus/share_plus.dart';

class ImageDisplayScreen extends StatelessWidget {
  const ImageDisplayScreen({super.key});

  Future<void> _pickImages(BuildContext context) async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty && context.mounted) {
      context.read<ImageCubit>().addImages(images);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete all images?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ImageCubit>().clearImages();
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _createPdf(BuildContext context, ImageState state) async {
    final pdfService = PdfService();
    final imageCubit = context.read<ImageCubit>(); // Get cubit instance

    final orderedImageBytes = state.pickedImages
        .map((xfile) => state.imageBytes[xfile.path])
        .where((bytes) => bytes != null)
        .cast<List<int>>()
        .toList();

    if (orderedImageBytes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot create PDF, no valid images found.')),
        );
      }
      return;
    }

    final fileNameController = TextEditingController();
    String? fileName;

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Name Your PDF'),
        content: TextField(
          controller: fileNameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Enter filename'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (fileNameController.text.isNotEmpty) {
                fileName = fileNameController.text;
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (fileName == null) return; // User cancelled

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final filePath = await pdfService.createAndSavePdf(
          orderedImageBytes.map((e) => Uint8List.fromList(e)).toList(), fileName!);

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading indicator

      bool shareFile = false;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('PDF Saved'),
          content: const Text('Would you like to share the file?'),
          actions: [
            TextButton(
              onPressed: () {
                shareFile = false;
                Navigator.of(ctx).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                shareFile = true;
                Navigator.of(ctx).pop();
              },
              child: const Text('Yes, Share'),
            ),
          ],
        ),
      );

      // Share if the user chose to. The await ensures we don't clear images until sharing is done.
      if (shareFile) {
        await Share.shareXFiles([XFile(filePath)], text: 'Here is your PDF file.');
      }

      // ALWAYS clear images. The BlocListener will then handle navigation.
      imageCubit.clearImages();

    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ImageCubit, ImageState>(
      listenWhen: (previous, current) {
        // This listener only cares about when images are cleared, not reordered.
        return previous.pickedImages.isNotEmpty && current.pickedImages.isEmpty;
      },
      listener: (context, state) {
        // When all images are gone (cleared), navigate back to the home screen.
        context.go('/');
      },
      child: BlocBuilder<ImageCubit, ImageState>(
        builder: (context, state) {
          final images = state.pickedImages;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back to Home',
                onPressed: () => context.go('/'),
              ),
              title: Text('Selected Images (${images.length})'),
              actions: [
                if (images.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Create PDF',
                    onPressed: () => _createPdf(context, state),
                  ),
                if (images.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Images',
                    onPressed: () => context.go('/edit'),
                  ),
                if (images.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    tooltip: 'Delete All',
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
              ],
            ),
            body: images.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_library_outlined,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No images selected yet.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _pickImages(context),
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Select Images'),
                        ),
                      ],
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: ImageGrid(),
                  ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _pickImages(context),
              label: const Text('Add Images'),
              icon: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
