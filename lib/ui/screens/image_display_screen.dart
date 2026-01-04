
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:myapp/services/pdf_service.dart';
import 'package:myapp/ui/widgets/image_grid.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        final images = state.pickedImages;

        return Scaffold(
          appBar: AppBar(
            title: Text('Selected Images (${images.length})'),
            actions: [
              if (images.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Create PDF',
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    final pdfService = PdfService();
                    final imageBytes = state.imageBytes.values.toList();

                    try {
                      await pdfService.createAndSharePdf(imageBytes);
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create PDF: $e')),
                        );
                      }
                    }
                  },
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
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'About',
                onPressed: () => context.go('/about'),
              )
            ],
          ),
          body: images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey),
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
    );
  }
}
