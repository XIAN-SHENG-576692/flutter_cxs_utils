import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory?> getSystemDownloadDirectory() async {
  try {
    if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    } else {
      Directory download = Directory('/storage/emulated/0/Download');
      // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
      // ignore: avoid_slow_async_io
      if (await download.exists()) {
        return download;
      } else {
        return getExternalStorageDirectory();
      }
    }
  } catch (err, stack) {
    debugPrint("Cannot get _application_documents_directory");
  }
  return null;
}

Future<String> getSystemAssetPath({
  required Directory temporaryDirectory,
  required String assetPath,
}) async {
  final find = '/';
  final replaceWith = '-';
  final temporaryAssetPath = assetPath.replaceAll(find, replaceWith);
  final tempFile = File("$temporaryDirectory/$temporaryAssetPath");
  if(!(await tempFile.exists())) {
    final byteData = await rootBundle.load(assetPath);
    await tempFile
      .writeAsBytes(
        byteData
        .buffer
        .asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
  }
  return tempFile.absolute.path;
}
