import 'dart:io';

import 'package:launcher_bootstrap/storage_manager.dart';

class LauncherStarter {
  static startLauncher() async {
    print('Starting launcher...');

    final javaPath = await _resolveJavaExecutablePath();
    
    String javaExecutable = javaPath;
    if (Platform.isWindows) {
      javaExecutable = javaPath.replaceAll('java.exe', 'javaw.exe');
      if (!await File(javaExecutable).exists()) {
        javaExecutable = javaPath;
      }
    }

    await Process.start(
        await javaExecutable, ['-jar', 'launcher.jar'],
        mode: ProcessStartMode.detached,
        workingDirectory: StorageManager.wrapperDirectory);
  }

  static _resolveJavaExecutablePath() async {
    var javaDirectory =
        await Directory('${StorageManager.wrapperDirectory}/java').list().first;

    if (Platform.isMacOS) {
      return '${javaDirectory.path}/Contents/Home/bin/java';
    } else {
      return '${javaDirectory.path}/bin/java';
    }
  }
}
