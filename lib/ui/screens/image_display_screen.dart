import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:myapp/services/pdf_service.dart';
import 'package:myapp/ui/widgets/image_grid.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';

class ImageDisplayScreen extends StatelessWidget {
  const ImageDisplayScreen({super.key});

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
                await _pickFromGallery(imageCubit);
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
      imageCubit.addImages(xFiles);
    }
  }

  Future<void> _pickFromGallery(
      ImageCubit imageCubit) async {
    final pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages.isNotEmpty) {
      imageCubit.addImages(pickedImages);
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
              // After clearing, explicitly navigate home.
              context.go('/');
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
    final imageCubit = context.read<ImageCubit>();

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
            onPressed: () => Navigator.of(ctx).pop(),
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

    if (fileName == null) return;

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
      Navigator.of(context, rootNavigator: true).pop();

      bool shareFile = false;
      if (context.mounted) {
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
      }

      if (shareFile) {
        await Share.shareXFiles([XFile(filePath)], text: 'Here is your PDF file.');
      }

      imageCubit.clearImages();
      if (context.mounted) {
        context.go('/');
      }

    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create PDF: $e')),
        );
      }
    }
  }

  Future<void> _handleNavigationBack(BuildContext context) async {
    if (context.read<ImageCubit>().state.pickedImages.isEmpty) {
      context.go('/');
      return;
    }

    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('You will lose the images in the current session. Proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldProceed == true && context.mounted) {
      context.read<ImageCubit>().clearImages();
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        final images = state.pickedImages;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, _) {
            if (didPop) return;
            _handleNavigationBack(context);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Your Images'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleNavigationBack(context),
              ),
              actions: [
                if (images.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Images',
                    onPressed: () => context.go('/edit'),
                  ),
                if (images.isNotEmpty)
                   IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    tooltip: 'Add Images',
                    onPressed: () => _showImageSourceDialog(context),
                  ),
                if (images.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
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
                        const Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No images selected yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showImageSourceDialog(context),
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Select Images'),
                        ),
                      ],
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ImageGrid(),
                  ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _createPdf(context, state),
              label: const Text('Create PDF'),
              icon: const Icon(Icons.picture_as_pdf),
            ),
          ),
        );
      },
    );
  }
}
