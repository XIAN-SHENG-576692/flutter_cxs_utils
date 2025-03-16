part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceConnectable on CustomBluetoothDevice {
  bool get connectable => _connectable;

  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    _connectable = scanResult.advertisementData.connectable;
  }

  bool _connectable = false;
}
