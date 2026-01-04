
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:myapp/business_logic/image_cubit.dart';

class ImageEditScreen extends StatefulWidget {
  const ImageEditScreen({super.key});

  @override
  State<ImageEditScreen> createState() => _ImageEditScreenState();
}

class _ImageEditScreenState extends State<ImageEditScreen> {
  int _currentIndex = 0;

  Future<void> _cropImage(BuildContext context, String imagePath) async {
    final imageCubit = context.read<ImageCubit>();
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop & Rotate',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Crop & Rotate',
        ),
      ],
    );

    if (croppedFile != null) {
      final newBytes = await croppedFile.readAsBytes();
      imageCubit.updateImage(imagePath, newBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        if (state.pickedImages.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('No images to edit.')),
          );
        }

        if (_currentIndex >= state.pickedImages.length) {
          _currentIndex = state.pickedImages.length - 1;
        }

        final imagePath = state.pickedImages[_currentIndex].path;
        final imageBytes = state.imageBytes[imagePath];

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back to Display',
              onPressed: () => context.go('/display'),
            ),
            title: const Text('Edit Image', style: TextStyle(fontSize: 20)),
            actions: [
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Done',
                onPressed: () => context.go('/display'),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: imageBytes == null
                      ? const CircularProgressIndicator()
                      : Image.memory(imageBytes), // Display the image directly
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.crop_rotate),
                    label: const Text('Crop & Rotate'),
                    onPressed: () => _cropImage(context, imagePath),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 100,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.pickedImages.length,
                  itemBuilder: (context, index) {
                    final path = state.pickedImages[index].path;
                    final bytes = state.imageBytes[path];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentIndex == index
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: bytes != null
                              ? Image.memory(bytes, fit: BoxFit.cover)
                              : const Center(
                                  child: CircularProgressIndicator()),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
