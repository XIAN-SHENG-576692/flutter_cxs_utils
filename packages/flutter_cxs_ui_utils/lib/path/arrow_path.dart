import 'dart:math';
import 'dart:ui';

import 'package:flutter_cxs_common_utils/geometry/geometry_calculator.dart';
import 'package:flutter_cxs_common_utils/geometry/line.dart';

extension ArrowPath on Path {
  /// Creates an arrow-shaped path with specified properties.
  void addArrow({
    required Point<double> center,
    required double length,
    required double radians,
  }) {

    // Pre-computed constants
    final bodyLength = length * 0.6; // Length of the arrow body
    final headLength = length - bodyLength; // Length of the arrow head
    final width = length * 0.3; // Total width of the arrow
    final halfWidth = width / 2;
    final eaves = width / 4;

    // Calculate the peak of the arrowhead
    final Point<double> peak = Point(
      center.x + length * cos(radians),
      center.y + length * sin(radians),
    );

    // Calculate the base points of the arrow
    final Iterable<Point<double>> points = GeometryCalculator.calculateCumulativePositions(
      points: [
        center,
        Point(
          halfWidth * cos(radians - (pi / 2)),
          halfWidth * sin(radians - (pi / 2)),
        ),
        Point(
          bodyLength * cos(radians),
          bodyLength * sin(radians),
        ),
        Point(
          eaves * cos(radians - (pi / 2)),
          eaves * sin(radians - (pi / 2)),
        ),
      ],
    ).skip(1);

    // Generate mirrored points for the other half of the arrow
    final Iterable<Point<double>> mirrorPoints = GeometryCalculator.calculateMirrorPoints(
      points: points,
      line: Line.fromPoints(
        start: center,
        end: peak,
      ),
    );

    // Construct the path
    this
      ..moveTo(center.x, center.y)
      ..addPolygon(
        points.map((p) => Offset(p.x, p.y)).toList(),
        false,
      )
      ..lineTo(peak.x, peak.y)
      ..addPolygon(
        mirrorPoints.toList().reversed.map((p) => Offset(p.x, p.y)).toList(),
        false,
      )
      ..close();

    return;
  }
}
