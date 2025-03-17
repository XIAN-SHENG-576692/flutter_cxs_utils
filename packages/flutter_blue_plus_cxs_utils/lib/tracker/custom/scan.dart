part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceScan on CustomBluetoothDevice {
  bool get isScanned => _isScanned;

  @mustCallSuper
  @override
  void onInit(BluetoothDevice bluetoothDevice) {
    super.onInit(bluetoothDevice);
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      if(!_isScanned) return;
      _isScanned = false;
      _isScannedController.add(_isScanned);
    });
  }

  late final StreamSubscription<bool> _isScanningSubscription;
  final StreamController<bool> _isScannedController = StreamController.broadcast();
  Stream<bool> get isScannedStream => _isScannedController.stream;

  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    if(_isScanned) return;
    _isScanned = true;
    _isScannedController.add(_isScanned);
  }

  bool _isScanned = false;

  @mustCallSuper
  @override
  void dispose() {
    _isScanningSubscription.cancel();
    _isScannedController.close();
    super.dispose();
  }
}

mixin CustomBluetoothDeviceScanTrackerChangeNotifier<D extends CustomBluetoothDeviceScan> on CustomBluetoothDeviceLengthTrackerChangeNotifier<D> {
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    for(final device in tracker.devices) {
      _isScannedSubscriptions.add(device.isScannedStream.listen((_) {
        notifyListeners();
      }));
    }
    tracker.onCreateNewDeviceStream.listen((device) {
      _isScannedSubscriptions.add(device.isScannedStream.listen((_) {
        notifyListeners();
      }));
    });
    return;
  }
  @mustCallSuper
  @override
  void dispose() {
    for(final s in _isScannedSubscriptions) {
      s.cancel();
    }
    _isScannedSubscriptions.clear();
    super.dispose();
  }
  final List<StreamSubscription> _isScannedSubscriptions = [];
}
