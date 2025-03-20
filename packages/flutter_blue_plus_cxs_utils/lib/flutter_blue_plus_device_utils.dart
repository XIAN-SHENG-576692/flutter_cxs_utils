import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'flutter_blue_plus_utils.dart' show FlutterBluePlusChangeNotifier;

/// ChangeNotifier for monitoring Bluetooth device state changes
class BluetoothDeviceChangeNotifier extends FlutterBluePlusChangeNotifier {
  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();

  final BluetoothDevice bluetoothDevice;

  @override
  @protected
  @mustCallSuper
  void onInit() {
    super.onInit();
  }

  /// Constructor that initializes the Bluetooth device notifier
  BluetoothDeviceChangeNotifier({
    required this.bluetoothDevice,
  });
}

/// Mixin for monitoring Bluetooth connection state changes
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

  /// Dispose the subscription to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }
}

/// Mixin for checking if a Bluetooth device is connected
mixin BluetoothDeviceIsConnectedChangeNotifier on BluetoothConnectionStateChangeNotifier {
  bool get isConnected => bluetoothDevice.isConnected;
}

/// Mixin for monitoring Bluetooth device MTU changes
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

  /// Dispose the subscription to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    _mtuSubscription.cancel();
    super.dispose();
  }
}

/// Extension for handling Bluetooth device connection utilities
extension BluetoothDeviceUtils on BluetoothDevice {
  /// Toggles the Bluetooth connection: disconnects if connected, connects otherwise
  static Future<bool> toggleConnection({
    required BluetoothDevice device,
  }) {
    return (device.isConnected)
        ? disconnect(device: device)
        : connect(device: device);
  }

  /// Connects to a Bluetooth device with a timeout
  static Future<bool> connect({
    required BluetoothDevice device,
    Duration timeout = const Duration(seconds: 35),
  }) async {
    try {
      await device.connect(
        timeout: timeout,
      );
      return true;
    } catch (e) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // Ignore connections canceled by the user
      } else {
        // debugPrint("ERROR: Connect: $e");
      }
      return false;
    }
  }

  /// Disconnects a Bluetooth device with a timeout
  static Future<bool> disconnect({
    required BluetoothDevice device,
    int timeout = 35,
  }) async {
    try {
      await device.disconnect(
        timeout: timeout,
      );
      return true;
    } catch (e) {
      // debugPrint("ERROR: Disconnect: $e");
      return false;
    }
  }
}
