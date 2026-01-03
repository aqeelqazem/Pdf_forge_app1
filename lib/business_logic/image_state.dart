
part of 'image_cubit.dart';

class ImageState {
  final List<XFile> pickedImages;

  const ImageState({this.pickedImages = const []});

  ImageState copyWith({List<XFile>? pickedImages}) {
    return ImageState(
      pickedImages: pickedImages ?? this.pickedImages,
    );
  }
}
