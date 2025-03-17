import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceChangeNotifier extends ChangeNotifier {
  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();
  final BluetoothDevice bluetoothDevice;
  @mustCallSuper
  void onInit() {}
  BluetoothDeviceChangeNotifier({
    required this.bluetoothDevice,
  }) {
    onInit();
  }
}

mixin BluetoothConnectionStateChangeNotifier on BluetoothDeviceChangeNotifier {
  BluetoothConnectionState? bluetoothConnectionState;
  late final StreamSubscription _connectionStateSubscription;
  @mustCallSuper
  @override
  onInit() {
    super.onInit();
    _connectionStateSubscription = bluetoothDevice.connectionState.listen((connectionState) {
      bluetoothConnectionState = connectionState;
      notifyListeners();
    });
  }
  @mustCallSuper
  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }
}

mixin BluetoothDeviceIsConnectedChangeNotifier on BluetoothConnectionStateChangeNotifier {
  bool get isConnected => bluetoothDevice.isConnected;
}

mixin BluetoothDeviceMtuChangeNotifier on BluetoothDeviceChangeNotifier {
  int get mtuNow => bluetoothDevice.mtuNow;
  late final StreamSubscription _mtuSubscription;
  @mustCallSuper
  @override
  onInit() {
    super.onInit();
    _mtuSubscription = bluetoothDevice.mtu.listen((mtu) {
      notifyListeners();
    });
  }
  @mustCallSuper
  @override
  void dispose() {
    _mtuSubscription.cancel();
    super.dispose();
  }
}

extension BluetoothDeviceUtils on BluetoothDevice {
  Future<bool> toggleConnection() {
    return (isConnected)
      ? disconnect()
      : connect();
  }
  Future<bool> connect({
    Duration timeout = const Duration(seconds: 35),
  }) async {
    try {
      await connect(
        timeout: timeout,
      );
      return true;
    } catch (e) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        // debugPrint("ERROR: Connect: $e");
      }
      return false;
    }
  }
  Future<bool> disconnect({
    int timeout = 35,
  }) async {
    try {
      await disconnect(
        timeout: timeout,
      );
      return true;
    } catch (e) {
      // debugPrint("ERROR: Disconnect: $e");
      return false;
    }
  }
}
