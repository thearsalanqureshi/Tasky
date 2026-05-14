import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AvatarStorageService {
  AvatarStorageService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<XFile?> pickImageFromGallery() {
    return _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
  }

  Future<XFile?> pickImageFromCamera() {
    return _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1200,
    );
  }

  Future<String?> saveAvatarFile(
    XFile imageFile, {
    String? previousAvatarPath,
  }) async {
    try {
      final sourceFile = File(imageFile.path);
      if (!await sourceFile.exists()) {
        return null;
      }

      final avatarDirectory = await _avatarDirectory();
      final extension = _extensionFor(imageFile.path);
      final fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}$extension';
      final destination = File(
        '${avatarDirectory.path}${Platform.pathSeparator}$fileName',
      );
      await sourceFile.copy(destination.path);

      if (previousAvatarPath != null &&
          previousAvatarPath != destination.path) {
        await deleteAvatarFile(previousAvatarPath);
      }

      return destination.path;
    } catch (_) {
      return null;
    }
  }

  Future<String?> saveAvatarPath(String path) async {
    return await avatarFileExists(path) ? path : null;
  }

  Future<bool> deleteAvatarFile(String path) async {
    try {
      final avatarDirectory = await _avatarDirectory();
      final file = File(path);
      if (!_isInsideDirectory(file, avatarDirectory) || !await file.exists()) {
        return false;
      }
      await file.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> avatarFileExists(String path) async {
    try {
      if (path.trim().isEmpty) {
        return false;
      }
      return File(path).exists();
    } catch (_) {
      return false;
    }
  }

  Future<String?> readAvatarPath() async {
    return null;
  }

  Future<void> clearAvatar() async {
    try {
      final avatarDirectory = await _avatarDirectory(create: false);
      if (!await avatarDirectory.exists()) {
        return;
      }
      await for (final entity in avatarDirectory.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
    } catch (_) {
      return;
    }
  }

  Future<Directory> _avatarDirectory({bool create = true}) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final avatarDirectory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}tasky${Platform.pathSeparator}avatar',
    );
    if (create && !await avatarDirectory.exists()) {
      await avatarDirectory.create(recursive: true);
    }
    return avatarDirectory;
  }

  String _extensionFor(String path) {
    final extensionIndex = path.lastIndexOf('.');
    if (extensionIndex == -1 || extensionIndex == path.length - 1) {
      return '.jpg';
    }
    final extension = path.substring(extensionIndex).toLowerCase();
    return RegExp(r'^\.(jpg|jpeg|png|webp)$').hasMatch(extension)
        ? extension
        : '.jpg';
  }

  bool _isInsideDirectory(File file, Directory directory) {
    final directoryPath = directory.absolute.path;
    final filePath = file.absolute.path;
    return filePath == directoryPath ||
        filePath.startsWith('$directoryPath${Platform.pathSeparator}');
  }
}
