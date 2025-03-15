import 'dart:typed_data';

/// Refers to https://stackoverflow.com/questions/69090275/uint8list-vs-listint-what-is-the-difference
/// Converts a `List<int>` to a [Uint8List].
///
/// Attempts to cast to a [Uint8List] first to avoid creating an unnecessary
/// copy.
extension AsUint8List on List<int> {
  Uint8List asUint8List() {
    final self = this; // Local variable to allow automatic type promotion.
    return (self is Uint8List) ? self : Uint8List.fromList(this);
  }
}

extension Uint8ListString on Uint8List {
  Iterable<String> toByteStrings({bool upperCase = true}) sync* {
    for (final byte in this) {
      final hex = byte.toRadixString(16).padLeft(2, '0');
      yield upperCase ? hex.toUpperCase() : hex;
    }
  }
}
