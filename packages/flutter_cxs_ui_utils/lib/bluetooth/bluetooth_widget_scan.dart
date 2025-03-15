part of 'bluetooth_widget.dart';

extension BluetoothWidgetScan on BluetoothWidget {
  static Widget buildFloatingScanButton({
    required bool isScanning,
    required VoidCallback? toggleScan,
    Color? scanButtonOnScanningColor = Colors.red,
    Color? scanButtonOnNotScanningColor,
    Icon scanButtonOnScanningIcon = const Icon(Icons.stop),
    Icon scanButtonOnNotScanningIcon = const Icon(Icons.bluetooth_searching),
  }) {
    return FloatingActionButton(
      onPressed: toggleScan,
      backgroundColor: (isScanning)
          ? scanButtonOnScanningColor
          : scanButtonOnNotScanningColor,
      child: (isScanning)
          ? scanButtonOnScanningIcon
          : scanButtonOnNotScanningIcon,
    );
  }
  static Widget buildScanner({
    required Future<void> Function() rescan,
    required Widget devices,
    Widget? floatingScanButton,
  }) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: rescan,
        child: devices,
      ),
      floatingActionButton: floatingScanButton,
    );
  }
}
