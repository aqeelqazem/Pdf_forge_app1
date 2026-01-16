import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:myapp/business_logic/image_cubit.dart';

class ImageEditScreen extends StatefulWidget {
  const ImageEditScreen({super.key});

  @override
  State<ImageEditScreen> createState() => _ImageEditScreenState();
}

class _ImageEditScreenState extends State<ImageEditScreen> {
  int _currentIndex = 0;
  double _contrastValue = 1.0; 
  Uint8List? _originalImageBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOriginalBytes();
    });
  }

  @override
  void didUpdateWidget(ImageEditScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadOriginalBytes();
  }

  void _loadOriginalBytes() {
    final state = context.read<ImageCubit>().state;
    if (state.pickedImages.isNotEmpty) {
      final imagePath = state.pickedImages[_currentIndex].path;
      // Load the initially processed bytes as the 'original' for this editing session
      _originalImageBytes = state.imageBytes[imagePath];
    }
  }

  void _onThumbnailTapped(int index) {
    setState(() {
      _currentIndex = index;
      _contrastValue = 1.0; // Reset contrast when switching images
    });
    _loadOriginalBytes(); // Load original bytes for the new image
  }

  Future<void> _cropImage(BuildContext context, String imagePath) async {
    final imageCubit = context.read<ImageCubit>();
    final theme = Theme.of(context);

    final currentBytes = imageCubit.state.imageBytes[imagePath];
    if (currentBytes == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath, // Still needs a path
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: theme.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(title: 'Cropper'),
      ],
    );

    if (croppedFile == null) return;

    final bytes = await croppedFile.readAsBytes();
    imageCubit.updateImage(imagePath, bytes);
    // After cropping, this becomes our new 'original' for further edits
    _originalImageBytes = bytes;
    setState(() {
      _contrastValue = 1.0;
    });
  }

  void _applyGrayscale() {
    final imageCubit = context.read<ImageCubit>();
    final imagePath = imageCubit.state.pickedImages[_currentIndex].path;
    final currentBytes = imageCubit.state.imageBytes[imagePath];

    if (currentBytes == null) return;

    img.Image? image = img.decodeImage(currentBytes);
    if (image == null) return;

    img.grayscale(image);
    final newBytes = Uint8List.fromList(img.encodeJpg(image));
    imageCubit.updateImage(imagePath, newBytes);
  }

  void _revertToOriginal() {
    if (_originalImageBytes == null) return;

    final imageCubit = context.read<ImageCubit>();
    final imagePath = imageCubit.state.pickedImages[_currentIndex].path;
    imageCubit.updateImage(imagePath, _originalImageBytes!);
    setState(() {
      _contrastValue = 1.0; // Reset slider
    });
  }

  void _applyContrast(double value) {
    if (_originalImageBytes == null) return;

    final imageCubit = context.read<ImageCubit>();
    final imagePath = imageCubit.state.pickedImages[_currentIndex].path;

    img.Image? image = img.decodeImage(_originalImageBytes!);
    if (image == null) return;

    // Apply contrast and brightness adjustments
    img.adjustColor(image, contrast: value,); 

    final newBytes = Uint8List.fromList(img.encodeJpg(image));
    imageCubit.updateImage(imagePath, newBytes);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        if (state.pickedImages.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Image'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/display'),
              ),
            ),
            body: const Center(
              child: Text('No images to edit.'),
            ),
          );
        }

        if (_currentIndex >= state.pickedImages.length) {
          _currentIndex = state.pickedImages.length - 1;
        }

        final imagePath = state.pickedImages[_currentIndex].path;
        final imageBytes = state.imageBytes[imagePath];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Image'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/display'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
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
                      : Image.memory(imageBytes, fit: BoxFit.contain),
                ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.pickedImages.length,
                        itemBuilder: (context, index) {
                          final imgPath = state.pickedImages[index].path;
                          final bytes = state.imageBytes[imgPath];
                          return GestureDetector(
                            onTap: () => _onThumbnailTapped(index),
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _currentIndex == index
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: bytes != null
                                  ? Image.memory(bytes, fit: BoxFit.cover)
                                  : const Icon(Icons.broken_image),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          'Crop',
                          Icons.crop_rotate,
                          () => _cropImage(context, imagePath),
                        ),
                        _buildActionButton(
                          context,
                          'B & W',
                          Icons.filter_b_and_w,
                          _applyGrayscale,
                        ),
                        _buildActionButton(
                          context,
                          'Original',
                          Icons.refresh,
                          _revertToOriginal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildContrastSlider(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon), onPressed: onPressed, iconSize: 28),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildContrastSlider() {
    return Row(
      children: [
        const Text('Contrast'),
        Expanded(
          child: Slider(
            value: _contrastValue,
            min: 0.0,
            max: 2.0,
            divisions: 20,
            label: _contrastValue.toStringAsFixed(1),
            onChanged: (double value) {
              setState(() {
                _contrastValue = value;
              });
            },
            onChangeEnd: (double value) {
              _applyContrast(value);
            },
          ),
        ),
      ],
    );
  }
}