part of 'custom_bluetooth_device.dart';

/// Notifier that tracks connection state changes for Bluetooth devices
mixin CustomBluetoothDeviceConnectionStateTrackerChangeNotifier<D extends CustomBluetoothDevice>
on CustomBluetoothDeviceLengthTrackerChangeNotifier<D> {

  /// Initializes the notifier and subscribes to connection state changes
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();

    // Subscribe to connection state changes for existing devices
    for (final device in tracker.devices) {
      _connectionStateSubscriptions.add(device.bluetoothDevice.connectionState.listen((_) {
        notifyListeners();
      }));
    }

    // Subscribe to connection state changes for newly created devices
    tracker.onCreateNewDeviceStream.listen((device) {
      _connectionStateSubscriptions.add(device.bluetoothDevice.connectionState.listen((_) {
        notifyListeners();
      }));
    });
  }

  /// Cleans up subscriptions to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    for (final s in _connectionStateSubscriptions) {
      s.cancel();
    }
    _connectionStateSubscriptions.clear();
    super.dispose();
  }

  /// List of subscriptions to connection state updates
  final List<StreamSubscription> _connectionStateSubscriptions = [];
}
