part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceScan on CustomBluetoothDevice, CustomBluetoothDeviceDispose {
  bool get isScanned => _isScanned;

  void addScannedListener(void Function() listener) {
    _isScannedNotifier.addListener(listener);
  }

  void removeScannedListener(void Function() listener) {
    _isScannedNotifier.removeListener(listener);
  }

  final _ChangeNotifier _isScannedNotifier = _ChangeNotifier();

  _setScanned(bool newIsScanned) {
    if(newIsScanned == _isScanned) return;
    _isScanned = newIsScanned;
    _isScannedNotifier.notifyListeners();
  }

  @mustCallSuper
  @override
  void onInit(BluetoothDevice bluetoothDevice) {
    super.onInit(bluetoothDevice);
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      if(isScanning) return;
      _setScanned(false);
    });
  }

  late final StreamSubscription<bool> _isScanningSubscription;

  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    _setScanned(true);
  }

  bool _isScanned = false;

  @mustCallSuper
  @override
  void dispose() {
    _isScannedNotifier.dispose();
    _isScanningSubscription.cancel();
    super.dispose();
  }
}
