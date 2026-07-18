import 'dart:io';

import 'package:launcher_bootstrap/storage_manager.dart';

/// Пишет сообщения одновременно в stdout и в файл `bootstrap.log`,
/// чтобы вывод не терялся при закрытии консоли (двойной клик по exe).
class Logger {
  static File? _logFile;

  static Future<void> init() async {
    final directory = Directory(StorageManager.wrapperDirectory);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    _logFile = File('${StorageManager.wrapperDirectory}/bootstrap.log');
    await _logFile!.writeAsString(
      '\n--- ${DateTime.now()} ---\n',
      mode: FileMode.append,
    );
  }

  static void log(String message) {
    print(message);
    _logFile?.writeAsStringSync('$message\n', mode: FileMode.append);
  }
}
