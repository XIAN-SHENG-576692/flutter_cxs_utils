part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceConnectable on CustomBluetoothDevice {
  bool get connectable => _connectable;

  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    _connectable = scanResult.advertisementData.connectable;
  }

  @override
  @mustCallSuper
  void dispose() {
    _connectableController.close();
    super.dispose();
  }

  final StreamController<bool> _connectableController = StreamController.broadcast();
  Stream<bool> get connectableStream => _connectableController.stream;

  bool _connectable = false;
}



mixin CustomBluetoothDeviceConnectableTrackerChangeNotifier<D extends CustomBluetoothDeviceConnectable> on CustomBluetoothDeviceLengthTrackerChangeNotifier<D> {
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    for(final device in tracker.devices) {
      _connectableSubscriptions.add(device.connectableStream.listen((_) {
        notifyListeners();
      }));
    }
    tracker.onCreateNewDeviceStream.listen((device) {
      _connectableSubscriptions.add(device.connectableStream.listen((_) {
        notifyListeners();
      }));
    });
    return;
  }
  @mustCallSuper
  @override
  void dispose() {
    for(final s in _connectableSubscriptions) {
      s.cancel();
    }
    _connectableSubscriptions.clear();
    super.dispose();
  }
  final List<StreamSubscription> _connectableSubscriptions = [];
}
