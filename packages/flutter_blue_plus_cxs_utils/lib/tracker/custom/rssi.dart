part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceRssi on CustomBluetoothDevice {

  int get rssi => _rssi;

  Stream<int> get rssiStream => _rssiController.stream;

  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    _setRssi(scanResult.rssi);
  }

  @override
  @mustCallSuper
  void dispose() {
    _rssiController.close();
    super.dispose();
  }

  final StreamController<int> _rssiController = StreamController.broadcast();

  int _rssi = 0;

  void _setRssi(int newRssi) {
    if(newRssi == _rssi) return;
    _rssi = newRssi;
    _rssiController.sink.add(_rssi);
  }
}

mixin CustomBluetoothDeviceTrackerRssi<D extends CustomBluetoothDeviceRssi> on CustomBluetoothDeviceTracker<D> {
  Timer readRssi({
    required Duration duration,
    int timeout = 15,
  }) {
    return Timer.periodic(duration, (timer) async {
      for(final device in devices.where((d) => d.isConnected).toList(growable: false)) {
        try {
          device._setRssi(await device.bluetoothDevice.readRssi(timeout: timeout));
        } catch(e) {}
      }
    });
  }
}

mixin CustomBluetoothDeviceRssiTrackerChangeNotifier<D extends CustomBluetoothDeviceRssi> on CustomBluetoothDeviceTrackerChangeNotifier<D> {
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    for(final device in tracker.devices) {
      _rssiSubscriptions.add(device.rssiStream.listen((_) {
        notifyListeners();
      }));
    }
    tracker.onCreateNewDeviceStream.listen((device) {
      _rssiSubscriptions.add(device.rssiStream.listen((_) {
        notifyListeners();
      }));
    });
    return;
  }
  @mustCallSuper
  @override
  void dispose() {
    for(final s in _rssiSubscriptions) {
      s.cancel();
    }
    _rssiSubscriptions.clear();
    super.dispose();
  }
  final List<StreamSubscription> _rssiSubscriptions = [];
}
