
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class ImageGrid extends StatelessWidget {
  const ImageGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the grid with a BlocBuilder to ensure it rebuilds on any state change.
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        final images = state.pickedImages;

        return ReorderableGridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: images.length,
          onReorder: (oldIndex, newIndex) {
            context.read<ImageCubit>().reorderImages(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final image = images[index];
            final bytes = state.imageBytes[image.path];

            // Using a more robust key. The image path is unique and stable.
            return ReorderableDragStartListener(
              key: ValueKey(image.path), 
              index: index,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (bytes != null)
                    // Add another ValueKey here based on the bytes to force image refresh
                    Image.memory(
                      bytes,
                      key: ValueKey(bytes.hashCode),
                      fit: BoxFit.cover,
                    )
                  else
                    const Center(child: CircularProgressIndicator()),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => context.read<ImageCubit>().removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
