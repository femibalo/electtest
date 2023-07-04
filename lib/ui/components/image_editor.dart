import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart' as cropper;
import 'compress_file.dart';


Future choosingImage({
  required BuildContext context,
  required bool isFromCamera,
}) async {
  Navigator.pop(context);
  XFile? pickedImage = await ImagePicker().pickImage(
      source: isFromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50);
  if (pickedImage != null) {
    File imageToCompress = File.fromUri(Uri.file(pickedImage.path));
    if (isFromCamera) {
      // need to compress it first before enter to image editor
      // because it will slow if picture from camera doesn't compress before
      // entering editor
      imageToCompress = await compressImage(file: File.fromUri(Uri.file(pickedImage.path)));
    }
    var editedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ImageEditor(
            image: imageToCompress.readAsBytesSync(),
          );
        },
      ),
    );
    if (editedImage != null) {
      Directory tempDir = await getTemporaryDirectory();
      File file =
          await File('${tempDir.path}/edited_image_profile.png').create();
      file.writeAsBytesSync(editedImage);
      if (isFromCamera) {
        // Because after entering the image editor. Image has a large size
        // after compressing finished, we can send it to API
        // it's only for picture picked from camera
        return compressImage(file: file);
      } else {
        return file;
      }
    }
  } else {
    return false;
  }
}

Future choosingImageV2({
  required BuildContext context,
  required bool isFromCamera,
  bool? isSquare,
  bool aspectRatioSquareOnly = false,
  pop = true,
}) async {
  // Navigator.pop(context);
  if (pop) {
    Navigator.pop(context);
  }

  XFile? pickedImage = await ImagePicker().pickImage(
      source: isFromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50);
  if (pickedImage != null) {
    File imageToCompress = File.fromUri(Uri.file(pickedImage.path));
    if (isFromCamera) {
      // need to compress it first before enter to image editor
      // because it will slow if picture from camera doesn't compress before
      // entering editor
      imageToCompress =
          await compressImage(file: File.fromUri(Uri.file(pickedImage.path)));
    }
    var aspectRatioPresetsAndroid = aspectRatioSquareOnly
        ? [
            cropper.CropAspectRatioPreset.square,
          ]
        : [
            cropper.CropAspectRatioPreset.square,
            cropper.CropAspectRatioPreset.ratio3x2,
            cropper.CropAspectRatioPreset.original,
            cropper.CropAspectRatioPreset.ratio4x3,
            cropper.CropAspectRatioPreset.ratio16x9
          ];
    var aspectRatioPresetsIOS = aspectRatioSquareOnly
        ? [
            cropper.CropAspectRatioPreset.square,
          ]
        : [
            cropper.CropAspectRatioPreset.original,
            cropper.CropAspectRatioPreset.square,
            cropper.CropAspectRatioPreset.ratio3x2,
            cropper.CropAspectRatioPreset.ratio4x3,
            cropper.CropAspectRatioPreset.ratio5x3,
            cropper.CropAspectRatioPreset.ratio5x4,
            cropper.CropAspectRatioPreset.ratio7x5,
            cropper.CropAspectRatioPreset.ratio16x9,
          ];
    cropper.CroppedFile? croppedFile = await cropper.ImageCropper().cropImage(
      sourcePath: imageToCompress.path,
      aspectRatioPresets: Platform.isAndroid
          ? aspectRatioPresetsAndroid
          : aspectRatioPresetsIOS,
      cropStyle: isSquare == true
          ? cropper.CropStyle.rectangle
          : cropper.CropStyle.circle,
      uiSettings: [
        cropper.AndroidUiSettings(
          toolbarTitle: 'adjust before upload',
          backgroundColor: Colors.black,
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: cropper.CropAspectRatioPreset.original,
          lockAspectRatio: false,
          activeControlsWidgetColor: Colors.blue,
          showCropGrid: false,
        ),
        cropper.IOSUiSettings(
          title: 'adjust before upload',
          cancelButtonTitle: 'cancel',
          doneButtonTitle: 'save',
        ),
      ],
    );
    if (croppedFile != null) {
      return compressImageFromCroppedFile(file: croppedFile);
    }
  } else {
    return false;
  }
}
