part of 'custom_bluetooth_device.dart';

/// Mixin that adds RSSI (Received Signal Strength Indicator) tracking to a CustomBluetoothDevice
mixin CustomBluetoothDeviceRssi on CustomBluetoothDevice {
  /// Returns the current RSSI value
  int get rssi => _rssi;

  /// Stream that emits updates when the RSSI value changes
  Stream<int> get rssiStream => _rssiController.stream;

  /// Updates the RSSI value from a scan result
  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    _setRssi(scanResult.rssi);
  }

  /// Cleans up resources by closing the RSSI stream controller
  @override
  @mustCallSuper
  void dispose() {
    _rssiController.close();
    super.dispose();
  }

  /// Stream controller for broadcasting RSSI updates
  final StreamController<int> _rssiController = StreamController.broadcast();

  /// Stores the current RSSI value
  int _rssi = 0;

  /// Sets the new RSSI value and notifies listeners if it has changed
  void _setRssi(int newRssi) {
    if (newRssi == _rssi) return;
    _rssi = newRssi;
    _rssiController.sink.add(_rssi);
  }
}

/// Mixin that enables periodic RSSI readings for connected devices
mixin CustomBluetoothDeviceTrackerRssi<D extends CustomBluetoothDeviceRssi> on CustomBluetoothDeviceTracker<D> {
  /// Reads the RSSI value periodically for connected devices
  Timer readRssi({
    required Duration duration,
    int timeout = 15,
  }) {
    return Timer.periodic(duration, (timer) async {
      for (final device in devices.where((d) => d.isConnected).toList(growable: false)) {
        try {
          device._setRssi(await device.bluetoothDevice.readRssi(timeout: timeout));
        } catch (e) {}
      }
    });
  }
}

/// Notifier that tracks RSSI updates across multiple devices
mixin CustomBluetoothDeviceRssiTrackerChangeNotifier<D extends CustomBluetoothDeviceRssi>
on CustomBluetoothDeviceLengthTrackerChangeNotifier<D> {
  /// Initializes the notifier and subscribes to RSSI updates
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();

    // Subscribe to RSSI updates for existing devices
    for (final device in tracker.devices) {
      _rssiSubscriptions.add(device.rssiStream.listen((_) {
        notifyListeners();
      }));
    }

    // Subscribe to RSSI updates for newly created devices
    tracker.onCreateNewDeviceStream.listen((device) {
      _rssiSubscriptions.add(device.rssiStream.listen((_) {
        notifyListeners();
      }));
    });
  }

  /// Cleans up subscriptions to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    for (final s in _rssiSubscriptions) {
      s.cancel();
    }
    _rssiSubscriptions.clear();
    super.dispose();
  }

  /// List of subscriptions to RSSI updates
  final List<StreamSubscription> _rssiSubscriptions = [];
}
