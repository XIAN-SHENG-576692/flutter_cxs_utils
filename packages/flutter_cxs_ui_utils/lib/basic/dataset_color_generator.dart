import 'dart:math';

import 'package:flutter/widgets.dart';

class DatasetColorGenerator {
  DatasetColorGenerator._();

  // Helper method to clamp a value within a specified range
  static double _clamp(double value, double minValue, double maxValue) {
    return max(min(value, maxValue), minValue);
  }

  /// Generates a grayscale color
  ///
  /// [alpha]: Opacity of the color (0.0 to 1.0)
  /// [index]: The current index in the dataset
  /// [length]: The total number of elements in the dataset
  static Color grayscale({
    required double alpha,
    required int index,
    required int length,
  }) {
    final brightness = _clamp(255.0 * index / length, 0.0, 255.0);
    return HSVColor.fromAHSV(
      alpha,
      0.0, // Grayscale colors have no hue
      0.0, // Saturation is always 0 for grayscale
      brightness,
    ).toColor();
  }

  /// Generates a rainbow color
  ///
  /// [alpha]: Opacity of the color (0.0 to 1.0)
  /// [index]: The current index in the dataset
  /// [length]: The total number of elements in the dataset
  static Color rainbow({
    required double alpha,
    required int index,
    required int length,
  }) {
    final hue = _clamp(255.0 * index / length, 0.0, 255.0);
    return HSVColor.fromAHSV(
      alpha,
      hue, // Hue varies across the dataset
      1.0, // Saturation is at maximum
      1.0, // Brightness is at maximum
    ).toColor();
  }

  /// Generates a rainbow color with layers
  ///
  /// [alpha]: Opacity of the color (0.0 to 1.0)
  /// [index]: The index within the current layer
  /// [length]: The total number of elements in the current layer
  /// [arrayIndex]: The index of the current layer
  /// [arrayLength]: The total number of layers
  static Color rainbowGroup({
    required double alpha,
    required int index,
    required int length,
    required int groupIndex,
    required int groupLength,
  }) {
    final hue = _clamp(255.0 * groupIndex / groupLength, 0.0, 255.0);
    final brightness = _clamp(1.0 * index / length, 0.0, 1.0);
    return HSVColor.fromAHSV(
      alpha,
      hue, // Hue changes based on the layer index
      1.0, // Saturation is at maximum
      brightness, // Brightness varies within the layer
    ).toColor();
  }
}
