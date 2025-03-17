part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceDiscover on CustomBluetoothDevice {
  Iterable<BluetoothService> get bluetoothServices => _bluetoothServices;

  Stream<Iterable<BluetoothService>> get onBluetoothServicesUpdateStream => _onBluetoothServicesUpdateController.stream;
  Stream<Iterable<BluetoothService>> get onDiscoverBluetoothServicesStream => _onBluetoothServicesUpdateController.stream.where((s) => s.isNotEmpty);
  Stream<void> get onClearBluetoothServicesStream => _onBluetoothServicesUpdateController.stream.where((s) => s.isEmpty);

  Future<void> discover({
    bool subscribeToServicesChanged = true,
    int timeout = 15,
  }) async {
    if(bluetoothServices.isNotEmpty) return;
    _bluetoothServices = await bluetoothDevice.discoverServices(
      subscribeToServicesChanged: subscribeToServicesChanged,
      timeout: timeout,
    );
    _onBluetoothServicesUpdateController.add(_bluetoothServices);
  }

  final StreamController<Iterable<BluetoothService>> _onBluetoothServicesUpdateController = StreamController.broadcast();

  @mustCallSuper
  @override
  void onInit(BluetoothDevice bluetoothDevice) {
    super.onInit(bluetoothDevice);
    _onDisconnectedSubscription = bluetoothDevice
      .connectionState
      .where((state) => state == BluetoothConnectionState.disconnected)
      .listen((_) {
        if(_bluetoothServices.isEmpty) return;
        _bluetoothServices.clear();
        _onBluetoothServicesUpdateController.add(_bluetoothServices);
    });
  }

  @override
  @mustCallSuper
  void dispose() {
    _onDisconnectedSubscription.cancel();
    _bluetoothServices.clear();
    super.dispose();
  }

  List<BluetoothService> _bluetoothServices = [];
  late final StreamSubscription _onDisconnectedSubscription;
}

class BluetoothDeviceDiscoverChangeNotifier extends ChangeNotifier {
  final CustomBluetoothDeviceDiscover device;
  Iterable<BluetoothService> get bluetoothServices => device.bluetoothServices;

  BluetoothDeviceDiscoverChangeNotifier({
    required this.device,
  }) {
    _subscription = device.onBluetoothServicesUpdateStream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();

  @mustCallSuper
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

mixin CustomBluetoothDeviceDiscoverTrackerChangeNotifier<D extends CustomBluetoothDeviceDiscover> on CustomBluetoothDeviceLengthTrackerChangeNotifier<D> {
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    for(final device in tracker.devices) {
      _discoverSubscriptions.add(device.onBluetoothServicesUpdateStream.listen((_) {
        notifyListeners();
      }));
    }
    tracker.onCreateNewDeviceStream.listen((device) {
      _discoverSubscriptions.add(device.onBluetoothServicesUpdateStream.listen((_) {
        notifyListeners();
      }));
    });
    return;
  }
  @mustCallSuper
  @override
  void dispose() {
    for(final s in _discoverSubscriptions) {
      s.cancel();
    }
    _discoverSubscriptions.clear();
    super.dispose();
  }
  final List<StreamSubscription> _discoverSubscriptions = [];
}
