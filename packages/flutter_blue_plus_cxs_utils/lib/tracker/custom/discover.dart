part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceDiscover on CustomBluetoothDevice, CustomBluetoothDeviceDispose {
  Iterable<BluetoothService> get services => _services;

  void addClearListener(void Function() listener) {
    _clearChangeNotifier.addListener(listener);
  }
  void removeClearListener(void Function() listener) {
    _clearChangeNotifier.removeListener(listener);
  }
  void addDiscoverListener(void Function() listener) {
    _discoverChangeNotifier.addListener(listener);
  }
  void removeDiscoverListener(void Function() listener) {
    _discoverChangeNotifier.removeListener(listener);
  }

  @mustCallSuper
  @override
  void onInit(BluetoothDevice bluetoothDevice) {
    super.onInit(bluetoothDevice);
    _onDisconnectedSubscription = bluetoothDevice
        .connectionState
        .where((state) => state == BluetoothConnectionState.disconnected)
        .listen((_) {
      _services.clear();
      _clearChangeNotifier.notifyListeners();
    });
  }

  Future<void> discover({
    bool subscribeToServicesChanged = true,
    int timeout = 15,
  }) async {
    if(services.isNotEmpty) return;
    _services = await bluetoothDevice.discoverServices(
      subscribeToServicesChanged: subscribeToServicesChanged,
      timeout: timeout,
    );
    _discoverChangeNotifier.notifyListeners();
  }

  @override
  @mustCallSuper
  void dispose() {
    _onDisconnectedSubscription.cancel();
    _discoverChangeNotifier.dispose();
    _clearChangeNotifier.dispose();
    _services.clear();
    super.dispose();
  }

  List<BluetoothService> _services = [];
  final _ChangeNotifier _clearChangeNotifier = _ChangeNotifier();
  final _ChangeNotifier _discoverChangeNotifier = _ChangeNotifier();
  late final StreamSubscription _onDisconnectedSubscription;
}

class BluetoothDeviceDiscoverChangeNotifier extends ChangeNotifier {
  final CustomBluetoothDeviceDiscover device;
  Iterable<BluetoothService> get services => device.services;
  BluetoothDeviceDiscoverChangeNotifier({
    required this.device,
  }) {
    device.addClearListener(notifyListeners);
    device.addDiscoverListener(notifyListeners);
  }

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();

  @mustCallSuper
  @override
  void dispose() {
    device.removeClearListener(notifyListeners);
    device.removeDiscoverListener(notifyListeners);
    super.dispose();
  }
}
