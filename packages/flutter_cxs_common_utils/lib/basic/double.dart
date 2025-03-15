import 'dart:math';

extension Precision on double {
  double toPrecision(int n) {
    return (this * pow(10, n)).roundToDouble() / pow(10, n);
  }
}
