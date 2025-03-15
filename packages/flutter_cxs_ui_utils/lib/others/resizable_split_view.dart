import 'package:flutter/material.dart';

class VerticalResizableSplitView extends StatelessWidget {
  final Widget topSection;
  final Widget bottomSection;
  final double sectionMinSize;
  final double defaultDividerRatio;
  final double dragHandleSize;
  final Color? dragHandleColor;
  final Color? dragHandleBackgroundColor;

  const VerticalResizableSplitView({
    super.key,
    required this.topSection,
    required this.bottomSection,
    required this.sectionMinSize,
    required this.defaultDividerRatio,
    required this.dragHandleSize,
    this.dragHandleColor,
    this.dragHandleBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    late double dividerPosition;
    bool first = true;
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxHeight = constraints.maxHeight;
        if(first) {
          dividerPosition = ((maxHeight - dragHandleSize) * defaultDividerRatio);
          first = false;
        }
        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: dividerPosition,
                  child: topSection,
                ),
                Positioned(
                  top: dividerPosition + dragHandleSize,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: bottomSection,
                ),
                Positioned(
                  top: dividerPosition,
                  left: 0,
                  right: 0,
                  height: dragHandleSize,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        dividerPosition += details.delta.dy;
                        dividerPosition = dividerPosition.clamp(sectionMinSize, maxHeight - sectionMinSize - dragHandleSize);
                      });
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeUpDown,
                      child: Container(
                        color: dragHandleBackgroundColor ?? Colors.grey,
                        child: Center(
                          child: Icon(
                            Icons.drag_handle,
                            color: dragHandleColor ?? Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
