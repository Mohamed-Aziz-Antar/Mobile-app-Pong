import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ImageStorage {
  static Future<String> saveImage(File image, String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'user_avatars');
    await Directory(path).create(recursive: true);
    final fileName = 'avatar_${userId.hashCode}${extension(image.path)}';
    final newPath = join(path, fileName);
    await image.copy(newPath);
    return newPath;
  }

  static Future<File?> getImage(String path) async {
    try {
      final file = File(path);
      return await file.exists() ? file : null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}