
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
      emit(state.copyWith(pickedImages: images));
    }
  }

  void addImages(List<XFile> images) {
    final updatedImages = [...state.pickedImages, ...images];
    emit(state.copyWith(pickedImages: updatedImages));
    _sessionService.saveSession(updatedImages);
  }

  void removeImage(int index) {
    final newImages = List<XFile>.from(state.pickedImages)..removeAt(index);
    emit(state.copyWith(pickedImages: newImages));
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
    emit(state.copyWith(pickedImages: []));
    _sessionService.clearSession();
  }
}
