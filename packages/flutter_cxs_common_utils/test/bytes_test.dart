import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cxs_common_utils/flutter_cxs_common_utils.dart';

void main() {
  test('Uint8List to Byte Strings', () {
    Uint8List list = Uint8List.fromList([
      0x03,
      0x65,
      0xf7,
    ]);
    expect(
      list.toByteStrings(upperCase: false),
      (() sync* {
        yield "03";
        yield "65";
        yield "f7";
      })(),
    );
  });
}
