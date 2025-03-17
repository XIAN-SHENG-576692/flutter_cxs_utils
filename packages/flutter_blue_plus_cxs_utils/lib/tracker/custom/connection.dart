part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceConnectionStateTrackerChangeNotifier<D extends CustomBluetoothDevice> on CustomBluetoothDeviceLengthTrackerChangeNotifier<D> {
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    for(final device in tracker.devices) {
      _connectionStateSubscriptions.add(device.bluetoothDevice.connectionState.listen((_) {
        notifyListeners();
      }));
    }
    tracker.onCreateNewDeviceStream.listen((device) {
      _connectionStateSubscriptions.add(device.bluetoothDevice.connectionState.listen((_) {
        notifyListeners();
      }));
    });
    return;
  }
  @mustCallSuper
  @override
  void dispose() {
    for(final s in _connectionStateSubscriptions) {
      s.cancel();
    }
    _connectionStateSubscriptions.clear();
    super.dispose();
  }
  final List<StreamSubscription> _connectionStateSubscriptions = [];
}
