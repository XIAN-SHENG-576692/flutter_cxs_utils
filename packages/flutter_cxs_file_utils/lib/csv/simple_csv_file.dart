import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../constants.dart' as global;

class SimpleCsvFile {
  SimpleCsvFile({
    required String path,
    this.delimiterColumn = ",",
    this.delimiterRow = "\n",
  }) : file = File(path);
  final File file;
  final String delimiterColumn;
  final String delimiterRow;
  Future clear({
    bool bom = false,
    bool flush = false,
  }) {
    return file.writeAsBytes(
      global.bom,
      mode: FileMode.write,
      flush: flush,
    );
  }
  Future writeAsBytes({
    required Uint8List bytes,
    bool flush = false,
  }) {
    return file.writeAsBytes(
      bytes,
      mode: FileMode.append,
      flush: flush,
    );
  }
  Future<void> writeAsString({
    required Iterable<String> data,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    final contents = data.isEmpty
        ? delimiterRow
        : data.join(delimiterColumn) + delimiterRow;
    return file.writeAsString(
      contents,
      mode: FileMode.append,
      encoding: encoding,
      flush: flush,
    );
  }
  Future<Iterable<Iterable<String>>> read({
    Encoding encoding = utf8,
    bool flush = false,
  }) async {
    return file
      .readAsString(encoding: encoding)
      .then((value) => value
        .split(delimiterRow)
        .map((e) => e.split(delimiterColumn))
      );
  }
}
