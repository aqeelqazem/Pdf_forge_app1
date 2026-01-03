
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class ImageGrid extends StatelessWidget {
  final List<XFile> images;

  const ImageGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final imageCubit = context.read<ImageCubit>();

    return ReorderableGridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return ReorderableDragStartListener(
          index: index,
          key: ValueKey(image.path),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: kIsWeb
                        ? NetworkImage(image.path)
                        : FileImage(File(image.path)) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => imageCubit.removeImage(index),
              ),
            ],
          ),
        );
      },
      onReorder: (oldIndex, newIndex) {
        imageCubit.reorderImages(oldIndex, newIndex);
      },
    );
  }
}
