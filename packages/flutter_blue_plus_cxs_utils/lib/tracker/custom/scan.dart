part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceScan on CustomBluetoothDevice {
  bool get isScanned => _isScanned;

  @mustCallSuper
  @override
  void onInit(BluetoothDevice bluetoothDevice) {
    super.onInit(bluetoothDevice);
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      _isScanned = false;
    });
  }

  late final StreamSubscription<bool> _isScanningSubscription;

  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    _isScanned = true;
  }

  bool _isScanned = false;

  @mustCallSuper
  @override
  void dispose() {
    _isScanningSubscription.cancel();
    super.dispose();
  }
}
