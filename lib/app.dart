import 'dart:io';

import 'package:launcher_bootstrap/java_downloader.dart';
import 'package:launcher_bootstrap/launcher_downloader.dart';
import 'package:launcher_bootstrap/launcher_starter.dart';
import 'package:launcher_bootstrap/logger.dart';

class App {
  static Future<void> run(List<String> arguments) async {
    await Logger.init();

    try {
      await JavaDownloader.checkJava();
      await LauncherDownloader.checkLauncher();
      await LauncherStarter.startLauncher();
    } catch (e, stackTrace) {
      Logger.log('Bootstrap failed: $e');
      Logger.log(stackTrace.toString());
      Logger.log('Press Enter to close this window...');
      stdin.readLineSync();
      exit(1);
    }
  }
}
