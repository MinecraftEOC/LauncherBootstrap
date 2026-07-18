import 'dart:io';

/// Общая логика поиска и валидации распакованной Java внутри `java/`.
class JavaUtils {
  static Future<Directory?> findJavaHome(Directory javaDirectory) async {
    if (!await javaDirectory.exists()) return null;

    await for (final entry in javaDirectory.list()) {
      if (entry is Directory) return entry;
    }

    return null;
  }

  static String executablePath(String javaHomePath) {
    if (Platform.isMacOS) {
      return '$javaHomePath/Contents/Home/bin/java';
    }
    return '$javaHomePath/bin/java';
  }

  static Future<bool> isValidInstallation(Directory javaDirectory) async {
    final javaHome = await findJavaHome(javaDirectory);
    if (javaHome == null) return false;

    return File(executablePath(javaHome.path)).exists();
  }
}
