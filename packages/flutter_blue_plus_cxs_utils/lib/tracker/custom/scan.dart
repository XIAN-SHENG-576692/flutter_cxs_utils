part of 'custom_bluetooth_device.dart';

/// Mixin that tracks whether a Bluetooth device has been scanned
mixin CustomBluetoothDeviceScan on CustomBluetoothDevice {
  /// Indicates whether the device has been scanned
  bool get isScanned => _isScanned;

  /// Initializes the mixin and resets the scanned status when a new scan starts
  @mustCallSuper
  @override
  void onInit(BluetoothDevice bluetoothDevice) {
    super.onInit(bluetoothDevice);
    _resetIsScannedSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      if (!isScanning) return;
      if (!_isScanned) return;
      _isScanned = false;
      _isScannedController.add(_isScanned);
    });
  }

  /// Subscription to listen for scanning state changes
  late final StreamSubscription<bool> _resetIsScannedSubscription;

  /// Stream controller for broadcasting scan state updates
  final StreamController<bool> _isScannedController = StreamController.broadcast();

  /// Stream that emits updates when the scan state changes
  Stream<bool> get isScannedStream => _isScannedController.stream;

  /// Updates the scan status when a new scan result is received
  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    super.onUpdateByScanResult(scanResult);
    if (_isScanned) return;
    _isScanned = true;
    _isScannedController.add(_isScanned);
  }

  /// Stores the scanned state of the device
  bool _isScanned = false;

  /// Cleans up resources and cancels subscriptions
  @mustCallSuper
  @override
  void dispose() {
    _resetIsScannedSubscription.cancel();
    _isScannedController.close();
    super.dispose();
  }
}

/// Notifier that tracks scan state updates across multiple devices
mixin CustomBluetoothDeviceScanTrackerChangeNotifier<D extends CustomBluetoothDeviceScan>
on CustomBluetoothDeviceLengthTrackerChangeNotifier<D> {

  /// Initializes the notifier and subscribes to scan state updates
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();

    // Subscribe to scan state updates for existing devices
    for (final device in tracker.devices) {
      _isScannedSubscriptions.add(device.isScannedStream.listen((_) {
        notifyListeners();
      }));
    }

    // Subscribe to scan state updates for newly created devices
    tracker.onCreateNewDeviceStream.listen((device) {
      _isScannedSubscriptions.add(device.isScannedStream.listen((_) {
        notifyListeners();
      }));
    });
  }

  /// Cleans up subscriptions to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    for (final s in _isScannedSubscriptions) {
      s.cancel();
    }
    _isScannedSubscriptions.clear();
    super.dispose();
  }

  /// List of subscriptions to scan state updates
  final List<StreamSubscription> _isScannedSubscriptions = [];
}
