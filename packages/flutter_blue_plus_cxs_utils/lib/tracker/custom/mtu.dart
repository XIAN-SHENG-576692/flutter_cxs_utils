part of 'custom_bluetooth_device.dart';

mixin CustomBluetoothDeviceMtu on CustomBluetoothDevice, CustomBluetoothDeviceDispose {
  int get mtuNow => bluetoothDevice.mtuNow;

  @mustCallSuper
  @override
  void onInit(BluetoothDevice bluetoothDevice) {
    super.onInit(bluetoothDevice);
    _mtuSubscription = bluetoothDevice.mtu.listen((mtu) {
      _mtuNotifier.notifyListeners();
    });
  }

  void addMtuListener(void Function() listener) {
    _mtuNotifier.addListener(listener);
  }

  void removeMtuListener(void Function() listener) {
    _mtuNotifier.removeListener(listener);
  }

  final _ChangeNotifier _mtuNotifier = _ChangeNotifier();

  @override
  @mustCallSuper
  void dispose() {
    _mtuNotifier.dispose();
    super.dispose();
  }

  late final StreamSubscription<int> _mtuSubscription;
}
