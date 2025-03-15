part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceRssi on CustomBluetoothDevice, CustomBluetoothDeviceDispose {

  int get rssi => _rssi;

  Stream<int> get rssiStream => _rssiController.stream;

  @override
  @mustCallSuper
  void dispose() {
    _rssiController.close();
    _rssiNotifier.dispose();
    super.dispose();
  }

  @mustCallSuper
  @override
  void onInit(BluetoothDevice bluetoothDevice) {
    super.onInit(bluetoothDevice);
    _rssiSubscription = rssiStream.listen((_) {
      _rssiNotifier.notifyListeners();
    });
  }

  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    _setRssi(scanResult.rssi);
  }

  void addRssiListener(void Function() listener) {
    _rssiNotifier.addListener(listener);
  }

  void removeRssiListener(void Function() listener) {
    _rssiNotifier.removeListener(listener);
  }

  final StreamController<int> _rssiController = StreamController.broadcast();

  int _rssi = 0;

  void _setRssi(int newRssi) {
    if(newRssi == _rssi) return;
    _rssi = newRssi;
    _rssiController.sink.add(_rssi);
  }

  final _ChangeNotifier _rssiNotifier = _ChangeNotifier();

  late final StreamSubscription<int> _rssiSubscription;
}

mixin CustomBluetoothDeviceTrackerRssi<D extends CustomBluetoothDeviceRssi> on CustomBluetoothDeviceTracker<D> {
  Timer readRssi({
    required Duration duration,
    int timeout = 15,
  }) {
    return Timer.periodic(duration, (timer) async {
      for(final device in devices.where((d) => d.bluetoothDevice.isConnected).toList()) {
        try {
          device._setRssi(await device.bluetoothDevice.readRssi(timeout: timeout));
        } catch(e) {}
      }
    });
  }
}
