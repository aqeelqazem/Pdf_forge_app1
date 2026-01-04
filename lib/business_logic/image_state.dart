part of 'image_cubit.dart';

class ImageState {
  final List<XFile> pickedImages;
  final Map<String, Uint8List> imageBytes;
  final bool isLoading; // تمت الإضافة

  const ImageState({
    this.pickedImages = const [],
    this.imageBytes = const {},
    this.isLoading = false, // القيمة الافتراضية
  });

  ImageState copyWith({
    List<XFile>? pickedImages,
    Map<String, Uint8List>? imageBytes,
    bool? isLoading, // تمت الإضافة
  }) {
    return ImageState(
      pickedImages: pickedImages ?? this.pickedImages,
      imageBytes: imageBytes ?? this.imageBytes,
      isLoading: isLoading ?? this.isLoading, // تمت الإضافة
    );
  }
}
