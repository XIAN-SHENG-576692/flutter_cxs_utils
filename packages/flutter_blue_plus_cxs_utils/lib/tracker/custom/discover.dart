part of 'custom_bluetooth_device.dart';

/// Mixin that adds service discovery functionality to a CustomBluetoothDevice
mixin CustomBluetoothDeviceDiscover on CustomBluetoothDevice {
  /// Returns the list of discovered Bluetooth services
  Iterable<BluetoothService> get bluetoothServices => _bluetoothServices;

  /// Stream that emits updates when Bluetooth services change
  Stream<Iterable<BluetoothService>> get onBluetoothServicesUpdateStream => _onBluetoothServicesUpdateController.stream;

  /// Stream that emits discovered Bluetooth services when they are found
  Stream<Iterable<BluetoothService>> get onDiscoverBluetoothServicesStream => _onBluetoothServicesUpdateController.stream.where((s) => s.isNotEmpty);

  /// Stream that emits an event when all Bluetooth services are cleared
  Stream<void> get onClearBluetoothServicesStream => _onBluetoothServicesUpdateController.stream.where((s) => s.isEmpty);

  /// Discovers Bluetooth services on the device, if not already discovered
  Future<void> discover({
    bool subscribeToServicesChanged = true,
    int timeout = 15,
  }) async {
    if (bluetoothServices.isNotEmpty) return;
    _bluetoothServices = await bluetoothDevice.discoverServices(
      subscribeToServicesChanged: subscribeToServicesChanged,
      timeout: timeout,
    );
    _onBluetoothServicesUpdateController.add(_bluetoothServices);
  }

  /// Stream controller for broadcasting Bluetooth services updates
  final StreamController<Iterable<BluetoothService>> _onBluetoothServicesUpdateController = StreamController.broadcast();

  /// Initializes the discovery process and listens for disconnection events
  @mustCallSuper
  @override
  void onInit(BluetoothDevice bluetoothDevice) {
    super.onInit(bluetoothDevice);
    _onClearBluetoothServicesSubscription = bluetoothDevice
        .connectionState
        .where((state) => state == BluetoothConnectionState.disconnected)
        .listen((_) {
      if (_bluetoothServices.isEmpty) return;
      _bluetoothServices.clear();
      _onBluetoothServicesUpdateController.add(_bluetoothServices);
    });
  }

  /// Cleans up resources and cancels subscriptions
  @override
  @mustCallSuper
  void dispose() {
    _onClearBluetoothServicesSubscription.cancel();
    _bluetoothServices.clear();
    super.dispose();
  }

  /// List of discovered Bluetooth services
  List<BluetoothService> _bluetoothServices = [];

  /// Subscription for monitoring when services should be cleared
  late final StreamSubscription _onClearBluetoothServicesSubscription;
}

/// Notifier that tracks Bluetooth service updates for a device
class BluetoothDeviceDiscoverChangeNotifier extends ChangeNotifier {
  /// The Bluetooth device being tracked
  final CustomBluetoothDeviceDiscover device;

  /// Returns the list of Bluetooth services for the device
  Iterable<BluetoothService> get bluetoothServices => device.bluetoothServices;

  /// Constructor that initializes the change notifier
  BluetoothDeviceDiscoverChangeNotifier({
    required this.device,
  }) {
    _onBluetoothServicesUpdateSubscription = device.onBluetoothServicesUpdateStream.listen((_) {
      notifyListeners();
    });
  }

  /// Subscription to listen for Bluetooth service updates
  late final StreamSubscription _onBluetoothServicesUpdateSubscription;

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();

  /// Cleans up the subscription when disposing to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    _onBluetoothServicesUpdateSubscription.cancel();
    super.dispose();
  }
}

/// Notifier that tracks Bluetooth service updates across multiple devices
mixin CustomBluetoothDeviceDiscoverTrackerChangeNotifier<D extends CustomBluetoothDeviceDiscover>
on CustomBluetoothDeviceLengthTrackerChangeNotifier<D> {

  /// Initializes the notifier and subscribes to service updates
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();

    // Subscribe to service updates for existing devices
    for (final device in tracker.devices) {
      _discoverSubscriptions.add(device.onBluetoothServicesUpdateStream.listen((_) {
        notifyListeners();
      }));
    }

    // Subscribe to service updates for newly created devices
    tracker.onCreateNewDeviceStream.listen((device) {
      _discoverSubscriptions.add(device.onBluetoothServicesUpdateStream.listen((_) {
        notifyListeners();
      }));
    });
  }

  /// Cleans up subscriptions to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    for (final s in _discoverSubscriptions) {
      s.cancel();
    }
    _discoverSubscriptions.clear();
    super.dispose();
  }

  /// List of subscriptions to service discovery updates
  final List<StreamSubscription> _discoverSubscriptions = [];
}
