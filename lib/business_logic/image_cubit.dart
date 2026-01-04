
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/services/session_service.dart';

part 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  final SessionService _sessionService = SessionService();

  ImageCubit() : super(const ImageState());

  Future<void> loadInitialSession() async {
    final images = await _sessionService.loadSession();
    if (images.isNotEmpty) {
      final imageBytes = await _getBytesForImages(images);
      emit(state.copyWith(pickedImages: images, imageBytes: imageBytes));
    }
  }

  Future<void> addImages(List<XFile> images) async {
    final updatedImages = [...state.pickedImages, ...images];
    final newBytes = await _getBytesForImages(images);
    final updatedBytes = {...state.imageBytes, ...newBytes};
    emit(state.copyWith(pickedImages: updatedImages, imageBytes: updatedBytes));
    _sessionService.saveSession(updatedImages);
  }

  void removeImage(int index) {
    final imageToRemove = state.pickedImages[index];
    final newImages = List<XFile>.from(state.pickedImages)..removeAt(index);
    final newBytes = Map<String, Uint8List>.from(state.imageBytes)
      ..remove(imageToRemove.path);
    emit(state.copyWith(pickedImages: newImages, imageBytes: newBytes));
    _sessionService.saveSession(newImages);
  }

  void reorderImages(int oldIndex, int newIndex) {
    final newImages = List<XFile>.from(state.pickedImages);
    final item = newImages.removeAt(oldIndex);
    newImages.insert(newIndex, item);
    emit(state.copyWith(pickedImages: newImages));
    _sessionService.saveSession(newImages);
  }

  void clearImages() {
    emit(state.copyWith(pickedImages: [], imageBytes: {}));
    _sessionService.clearSession();
  }

  void updateImage(String path, Uint8List newBytes) {
    final newBytesMap = Map<String, Uint8List>.from(state.imageBytes);
    newBytesMap[path] = newBytes;
    emit(state.copyWith(imageBytes: newBytesMap));
  }

  Future<Map<String, Uint8List>> _getBytesForImages(List<XFile> images) async {
    final map = <String, Uint8List>{};
    for (final image in images) {
      map[image.path] = await image.readAsBytes();
    }
    return map;
  }
}
