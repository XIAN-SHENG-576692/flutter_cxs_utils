import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceIsConnectedChangeNotifier extends ChangeNotifier {
  bool isConnected;
  late final StreamSubscription _subscription;
  BluetoothDeviceIsConnectedChangeNotifier({
    required BluetoothDevice bluetoothDevice,
  }) : isConnected = bluetoothDevice.isConnected {
    _subscription = bluetoothDevice.connectionState.listen((connectionState) {
      isConnected = connectionState == BluetoothConnectionState.connected;
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class BluetoothDeviceUtils {
  const BluetoothDeviceUtils._();
  static Future<bool> toggleConnection({
    required BluetoothDevice device,
  }) {
    return (device.isConnected)
      ? disconnect(device: device)
      : connect(device: device);
  }
  static Future<bool> connect({
    required BluetoothDevice device,
    int timeout = 35,
  }) async {
    try {
      // debugPrint("FBP: connect start");
      await device.connect(
        timeout: Duration(seconds: timeout),
      );
      // debugPrint("FBP: connect finish");
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
  static Future<bool> disconnect({
    required BluetoothDevice device,
    int timeout = 35,
  }) async {
    try {
      // debugPrint("FBP: disconnect start");
      await device.disconnect(
        timeout: timeout,
      );
      // debugPrint("FBP: disconnect finish");
      return true;
    } catch (e) {
      // debugPrint("ERROR: Disconnect: $e");
      return false;
    }
  }
}
