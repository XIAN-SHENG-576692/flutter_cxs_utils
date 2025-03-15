import 'dart:math';

class LineChartXAxisHandler {
  /// Finds the maximum X value across multiple collections of points.
  ///
  /// - [pointCollections]: A collection of point sets to search.
  /// - Returns: The maximum X value, or null if no points exist.
  static T? findMaxX<T extends num>({
    required Iterable<Iterable<Point<T>>> pointCollections,
  }) {
    final allXCoordinates = pointCollections.expand((points) => points.map((point) => point.x));
    return allXCoordinates.isEmpty ? null : allXCoordinates.reduce((a, b) => a > b ? a : b);
  }
  /// Finds the minimum X value across multiple collections of points.
  ///
  /// - [pointCollections]: A collection of point sets to search.
  /// - Returns: The minimum X value, or null if no points exist.
  static T? findMinX<T extends num>({
    required Iterable<Iterable<Point<T>>> pointCollections,
  }) {
    final allXCoordinates = pointCollections.expand((points) => points.map((point) => point.x));
    return allXCoordinates.isEmpty ? null : allXCoordinates.reduce((a, b) => a < b ? a : b);
  }
  /// Adjusts the X-axis range of each set of points to ensure consistent minimum and maximum X values.
  ///
  /// - [pointCollections]: A collection of point sets to adjust.
  /// - Returns: Adjusted point sets with uniform X-axis ranges.
  static Iterable<Iterable<Point<T>>> alignXRange<T extends num>({
    required Iterable<Iterable<Point<T>>> pointCollections,
  }) {
    final globalMinX = findMinX(pointCollections: pointCollections);
    final globalMaxX = findMaxX(pointCollections: pointCollections);

    if (globalMinX == null || globalMaxX == null) return pointCollections;

    return pointCollections.map((points) sync* {
      if (points.isEmpty) return;
      if (points.first.x != globalMinX) yield Point(globalMinX, points.first.y);
      yield* points;
      if (points.last.x != globalMaxX) yield Point(globalMaxX, points.last.y);
    });
  }
}