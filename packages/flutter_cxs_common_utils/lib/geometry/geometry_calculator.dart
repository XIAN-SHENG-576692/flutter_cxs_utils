import 'dart:math';

import 'line.dart';

/// Geometry utilities class for point transformations and calculations.
class GeometryCalculator {
  GeometryCalculator._();

  /// Calculates the mirror points of a given set of points relative to a specified line.
  ///
  /// - [points]: The set of points to be mirrored.
  /// - [line]: The line relative to which the points are mirrored.
  /// Returns: An iterable containing the mirrored points.
  static Iterable<Point<double>> calculateMirrorPoints({
    required Iterable<Point<double>> points,
    required Line line,
  }) {
    final double a = line.start.y - line.end.y;
    final double b = -(line.start.x - line.end.x);
    final double c = line.start.x * line.end.y - line.end.x * line.start.y;

    final double denominator = a * a + b * b;

    return points.map((point) {
      final double factor = -2 * (a * point.x + b * point.y + c) / denominator;
      return Point(
        factor * a + point.x,
        factor * b + point.y,
      );
    });
  }

  /// Calculates the cumulative positions of a sequence of points.
  ///
  /// - [points]: The collection of points to calculate cumulative positions for.
  /// Returns: A new collection of points where each point's position is the cumulative
  ///          sum relative to the previous points.
  static Iterable<Point<double>> calculateCumulativePositions({
    required Iterable<Point<double>> points,
  }) sync* {
    if (points.isEmpty) return;
    var cumulativePoint = Point<double>(0, 0);
    for (final point in points) {
      cumulativePoint = Point<double>(
        (cumulativePoint.x + point.x),
        (cumulativePoint.y + point.y),
      );
      yield cumulativePoint;
    }
  }

}
