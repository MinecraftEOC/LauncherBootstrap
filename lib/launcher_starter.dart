import 'dart:io';

import 'package:launcher_bootstrap/java_utils.dart';
import 'package:launcher_bootstrap/logger.dart';
import 'package:launcher_bootstrap/storage_manager.dart';

class LauncherStarter {
  static startLauncher() async {
    Logger.log('Starting launcher...');

    await Process.start(
        await _resolveJavaExecutablePath(), ['-jar', 'launcher.jar'],
        mode: ProcessStartMode.detached,
        workingDirectory: StorageManager.wrapperDirectory);
  }

  static Future<String> _resolveJavaExecutablePath() async {
    final javaDirectory =
        Directory('${StorageManager.wrapperDirectory}/java');
    final javaHome = await JavaUtils.findJavaHome(javaDirectory);

    if (javaHome == null) {
      throw Exception(
          'Java installation not found in "${javaDirectory.path}". '
          'Try deleting this folder and running the bootstrap again.');
    }

    return JavaUtils.executablePath(javaHome.path);
  }
}
