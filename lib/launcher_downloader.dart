import 'dart:io';

import 'package:http/http.dart';
import 'package:launcher_bootstrap/config.dart';
import 'package:launcher_bootstrap/logger.dart';
import 'package:launcher_bootstrap/storage_manager.dart';

class LauncherDownloader {
  static checkLauncher() async {
    Logger.log('Checking launcher...');

    final launcherFile =
        File('${StorageManager.wrapperDirectory}/launcher.jar');

    if (await launcherFile.exists()) {
      if (await launcherFile.length() > 0) {
        Logger.log('Launcher is already installed.');
        return;
      }

      Logger.log('Launcher file is empty or corrupted. Redownloading...');
      await launcherFile.delete();
    }

    Logger.log('Launcher is not installed. Downloading...');
    await _downloadLauncher(launcherFile);
  }

  static _downloadLauncher(File launcherFile) async {
    final launcherJar = await get(Config.launcherJarUrl);
    if (launcherJar.statusCode != 200) {
      throw Exception(
          'Failed to download launcher. Status code: ${launcherJar.statusCode}');
    }

    if (launcherJar.bodyBytes.isEmpty) {
      throw Exception('Downloaded launcher file is empty.');
    }

    await launcherFile.create(recursive: true);
    await launcherFile.writeAsBytes(launcherJar.bodyBytes);

    Logger.log('Launcher downloaded successfully.');
  }
}
