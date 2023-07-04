import 'dart:io';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';

Future<File> compressImage({required File file}) async {
  File compressedFile = await FlutterNativeImage.compressImage(
    file.path,
    quality: 25,
  );
  return compressedFile;
}

Future<File> compressImageFromCroppedFile({required CroppedFile file}) async {
  File compressedFile = await FlutterNativeImage.compressImage(
    file.path,
    quality: 25,
  );
  return compressedFile;
}
