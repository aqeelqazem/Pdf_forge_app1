
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:myapp/services/pdf_service.dart';
import 'package:myapp/ui/widgets/image_grid.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final PdfService _pdfService = PdfService();
  final TextEditingController _filenameController = TextEditingController();

  Future<void> _pickMoreImages() async {
    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty && mounted) {
      context.read<ImageCubit>().addImages(images);
    }
  }

  void _showFilenameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter PDF Filename'),
          content: TextField(
            controller: _filenameController,
            decoration: const InputDecoration(hintText: "e.g., my-document"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!mounted) return;
                final images = context.read<ImageCubit>().state.pickedImages;
                _pdfService.createAndSharePdf(
                    images, _filenameController.text, context);
                Navigator.of(context).pop();
              },
              child: const Text('Create PDF'),
            ),
          ],
        );
      },
    );
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear All Images?'),
          content: const Text(
              'Are you sure you want to remove all images? This will end the current session.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                context.read<ImageCubit>().clearImages();
                // GoRouter will automatically redirect to home
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit & Arrange'),
        // Use context.go to navigate home without any confirmation or data clearing
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Go to Home',
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_photos_outlined),
            tooltip: 'Add More Images',
            onPressed: _pickMoreImages,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Create PDF',
            onPressed: _showFilenameDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear All',
            onPressed: _showClearConfirmationDialog,
          ),
        ],
      ),
      body: BlocBuilder<ImageCubit, ImageState>(
        builder: (context, state) {
          // The redirect in go_router handles the empty case, so we just build the grid.
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ImageGrid(images: state.pickedImages),
          );
        },
      ),
    );
  }
}
