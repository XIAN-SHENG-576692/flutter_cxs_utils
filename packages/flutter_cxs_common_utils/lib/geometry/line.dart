import 'dart:math';

/// Represents a line defined by two points or other mathematical properties.
class Line {
  final Point<double> start;
  final Point<double> end;

  /// Private constructor to enforce controlled creation through factory methods.
  const Line._({
    required this.start,
    required this.end,
  });

  /// Creates a line from two points.
  factory Line.fromPoints({
    required Point<double> start,
    required Point<double> end,
  }) {
    return Line._(
      start: start,
      end: end,
    );
  }

  /// Creates a line from slope and y-intercept.
  ///
  /// - [slope]: The slope of the line.
  /// - [yIntercept]: The y-intercept of the line (where it crosses the y-axis).
  factory Line.fromSlopeAndIntercept({
    required double slope,
    required double yIntercept,
    required double rangeStart,
    required double rangeEnd,
  }) {
    return Line._(
      start: Point<double>(rangeStart, slope * rangeStart + yIntercept),
      end: Point<double>(rangeEnd, slope * rangeEnd + yIntercept),
    );
  }

  /// Creates a vertical line with a constant x-coordinate.
  factory Line.vertical({
    required double x,
    required double rangeStart,
    required double rangeEnd,
  }) {
    return Line._(
      start: Point(x, rangeStart),
      end: Point(x, rangeEnd),
    );
  }

  /// Creates a horizontal line with a constant y-coordinate.
  factory Line.horizontal({
    required double y,
    required double rangeStart,
    required double rangeEnd,
  }) {
    return Line._(
      start: Point(rangeStart, y),
      end: Point(rangeEnd, y),
    );
  }

  /// Creates a line from a string equation in the form "y = mx + b".
  ///
  /// Example input: "y = 2x + 3"
  factory Line.fromEquation({
    required String equation,
    required double rangeStart,
    required double rangeEnd,
  }) {
    final match = RegExp(r'y\s*=\s*([+-]?\d*\.?\d*)x\s*([+-]\s*\d+\.?\d*)')
        .firstMatch(equation.replaceAll(' ', ''));

    if (match == null) {
      throw ArgumentError('Invalid equation format. Expected "y = mx + b".');
    }

    return Line.fromSlopeAndIntercept(
      slope: double.tryParse(match.group(1) ?? '1') ?? 1,
      yIntercept: double.tryParse(match.group(2)!.replaceAll(' ', '')) ?? 0,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  factory Line.fromCenter({
    required Point<double> center,
    required double length,
    required double radians,
  }) {
    return Line._(
      start: center,
      end: Point(
        center.x + (length * cos(radians)),
        center.y + (length * sin(radians)),
      ),
    );
  }

  @override
  String toString() => 'Line(start: $start, end: $end)';
}
