import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart';
import 'package:launcher_bootstrap/java_utils.dart';
import 'package:launcher_bootstrap/logger.dart';
import 'package:launcher_bootstrap/storage_manager.dart';

class JavaDownloader {
  static checkJava() async {
    Logger.log('Checking Java...');

    final javaDirectory = Directory('${StorageManager.wrapperDirectory}/java');

    if (await javaDirectory.exists()) {
      if (await JavaUtils.isValidInstallation(javaDirectory)) {
        Logger.log('Java is already installed.');
        return;
      }

      Logger.log(
          'Java installation is incomplete or corrupted. Reinstalling...');
      await javaDirectory.delete(recursive: true);
    }

    Logger.log('Java is not installed. Downloading...');
    await _downloadJava(javaDirectory);
  }

  static _downloadJava(Directory javaDirectory) async {
    final javaLink = Uri.https(
      'api.azul.com',
      'metadata/v1/zulu/packages/',
      {'java_version': '17', 'os': _getOs(), 'arch': _getArch(), 'archive_type': _getExt(), 'java_package_type': 'jre', 'javafx_bundled': 'true', 'latest': 'true', 'release_status': 'ga', 'availability_types': 'CA', 'certifications': 'tck', 'page': '1', 'page_size': '1'}
    );
    final javaData = await get(javaLink);
    final body = json.decode(javaData.body);

    if (body is! List || body.isEmpty) {
      throw Exception(
          'Azul API did not return any Java build for this platform (os=${_getOs()}, arch=${_getArch()}).');
    }

    final javaZip = await get(Uri.parse(body[0]['download_url']));
    if (javaZip.statusCode != 200) {
      throw Exception(
          'Failed to download Java. Status code: ${javaZip.statusCode}');
    }

    Logger.log('Extracting Java...');
    await javaDirectory.create(recursive: true);

    try {
      Archive javaBinary;

      if (Platform.isWindows) {
        javaBinary = ZipDecoder().decodeBytes(javaZip.bodyBytes);
      } else {
        javaBinary = TarDecoder()
            .decodeBytes(GZipDecoder().decodeBytes(javaZip.bodyBytes));
      }

      for (final file in javaBinary) {
        if (file.isFile) {
          File('${javaDirectory.path}/${file.name}')
            ..createSync(recursive: true)
            ..writeAsBytesSync(file.content);
        }
      }

      if (!await JavaUtils.isValidInstallation(javaDirectory)) {
        throw Exception(
            'Java archive was extracted, but no java executable was found inside.');
      }

      Logger.log('Java installed successfully.');
    } catch (_) {
      // Не оставляем битую папку - иначе следующий запуск примет её за валидную установку.
      if (await javaDirectory.exists()) {
        await javaDirectory.delete(recursive: true);
      }
      rethrow;
    }
  }

  static _getOs() {
    return Platform.operatingSystem;
  }

  static _getArch() {
    switch (Abi.current()) {
      case Abi.linuxArm:
        return 'aarch32';

      case Abi.linuxIA32:
      case Abi.windowsIA32:
        return 'i686';

      case Abi.linuxX64:
      case Abi.macosX64:
      case Abi.windowsX64:
        return 'x64';

      case Abi.linuxArm64:
      case Abi.macosArm64:
      case Abi.windowsArm64:
        return 'aarch64';
    }
  }

  static _getExt() {
    if (Platform.isWindows) {
      return 'zip';
    }
    return "tar.gz";
  }
}
