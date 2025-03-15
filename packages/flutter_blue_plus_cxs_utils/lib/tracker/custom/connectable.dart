part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceConnectable on CustomBluetoothDevice, CustomBluetoothDeviceDispose {
  bool get connectable => _connectable;

  void addConnectableListener(void Function() listener) {
    _connectableNotifier.addListener(listener);
  }

  void removeConnectableListener(void Function() listener) {
    _connectableNotifier.removeListener(listener);
  }

  final _ChangeNotifier _connectableNotifier = _ChangeNotifier();

  _setConnectable(bool newConnectable) {
    if(newConnectable == _connectable) return;
    _connectable = newConnectable;
    _connectableNotifier.notifyListeners();
  }

  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    _setConnectable(scanResult.advertisementData.connectable);
  }

  bool _connectable = false;

  @mustCallSuper
  @override
  void dispose() {
    _connectableNotifier.dispose();
    super.dispose();
  }
}
