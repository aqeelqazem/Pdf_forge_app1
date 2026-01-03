
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class SessionService {
  static const String _sessionKey = 'image_session';

  Future<void> saveSession(List<XFile> images) async {
    final prefs = await SharedPreferences.getInstance();
    final imagePaths = images.map((file) => file.path).toList();
    await prefs.setStringList(_sessionKey, imagePaths);
  }

  Future<List<XFile>> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePaths = prefs.getStringList(_sessionKey);

    if (imagePaths == null) {
      return [];
    }

    return imagePaths.map((path) => XFile(path)).toList();
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
