part of 'custom_bluetooth_device.dart';

/// Mixin that adds connectable functionality to a CustomBluetoothDevice
mixin CustomBluetoothDeviceConnectable on CustomBluetoothDevice {
  /// Returns whether the device is connectable
  bool get connectable => _connectable;

  /// Updates the connectable status from scan result advertisement data
  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    _connectable = scanResult.advertisementData.connectable;
  }

  /// Cleans up resources by closing the stream controller
  @override
  @mustCallSuper
  void dispose() {
    _connectableController.close();
    super.dispose();
  }

  /// Stream controller for broadcasting connectable status updates
  final StreamController<bool> _connectableController = StreamController.broadcast();

  /// Stream that emits updates on whether the device is connectable
  Stream<bool> get connectableStream => _connectableController.stream;

  /// Stores the connectable status of the device
  bool _connectable = false;
}

/// Notifier that tracks connectable status updates for devices
mixin CustomBluetoothDeviceConnectableTrackerChangeNotifier<D extends CustomBluetoothDeviceConnectable>
on CustomBluetoothDeviceLengthTrackerChangeNotifier<D> {
  /// Initializes the notifier and subscribes to connectable status changes
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();

    // Subscribe to connectable stream of existing devices
    for (final device in tracker.devices) {
      _connectableSubscriptions.add(device.connectableStream.listen((_) {
        notifyListeners();
      }));
    }

    // Subscribe to connectable stream of newly created devices
    tracker.onCreateNewDeviceStream.listen((device) {
      _connectableSubscriptions.add(device.connectableStream.listen((_) {
        notifyListeners();
      }));
    });
  }

  /// Cleans up subscriptions to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    for (final s in _connectableSubscriptions) {
      s.cancel();
    }
    _connectableSubscriptions.clear();
    super.dispose();
  }

  /// List of subscriptions to connectable status updates
  final List<StreamSubscription> _connectableSubscriptions = [];
}
