import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothAdapterStateChangeNotifier extends ChangeNotifier {
  BluetoothAdapterState _adapterState = FlutterBluePlus.adapterStateNow;
  BluetoothAdapterState get adapterState => _adapterState;
  late final StreamSubscription _subscription;
  BluetoothAdapterStateChangeNotifier() {
    _subscription = FlutterBluePlus.adapterState.listen((adapterState) {
      _adapterState = adapterState;
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class BluetoothIsOnChangeNotifier extends BluetoothAdapterStateChangeNotifier {
  @protected
  @override
  BluetoothAdapterState get adapterState => super.adapterState;
  bool get isOn => adapterState == BluetoothAdapterState.on;
  BluetoothIsOnChangeNotifier();
}

class BluetoothIsScanningChangeNotifier extends ChangeNotifier {
  bool _isScanning = FlutterBluePlus.isScanningNow;
  bool get isScanning => _isScanning;
  late final StreamSubscription _subscription;
  BluetoothIsScanningChangeNotifier() {
    _subscription = FlutterBluePlus.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class ScanResultsChangeNotifier extends ChangeNotifier {
  List<ScanResult> _scanResults = [];
  Iterable<ScanResult> get scanResults => _scanResults;
  late final StreamSubscription _subscription;
  ScanResultsChangeNotifier() {
    _subscription = FlutterBluePlus.scanResults.listen((scanResults) {
      _scanResults = scanResults;
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class FlutterBluePlusUtils {
  const FlutterBluePlusUtils._();
  static Future<bool> turnOn({
    required Future<bool> Function() requestPermission,
  }) async {
    if(!await requestPermission()) return false;
    await FlutterBluePlus.turnOn();
    return true;
  }
  static Future<void> rescan({
    required Future<bool> Function() requestPermission,
    required Duration scanDuration,
  }) async {
    if(!await requestPermission()) return;
    await scanOff(requestPermission: requestPermission);
    await scanOn(requestPermission: requestPermission, scanDuration: scanDuration);
    return;
  }
  static Future<bool> toggleScan({
    required Future<bool> Function() requestPermission,
    required Duration scanDuration,
  }) async {
    if(!await requestPermission()) return false;
    return (FlutterBluePlus.isScanningNow)
        ? scanOff(requestPermission: requestPermission)
        : scanOn(requestPermission: requestPermission, scanDuration: scanDuration);
  }
  static Future<bool> scanOn({
    required Future<bool> Function() requestPermission,
    required Duration scanDuration,
  }) async {
    if(!await requestPermission()) return false;
    if(FlutterBluePlus.isScanningNow) return false;
    try {
      // android is slow when asking for all advertisements,
      // so instead we only ask for 1/8 of them
      int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
        timeout: scanDuration,
        continuousUpdates: true,
        continuousDivisor: divisor,
      );
      return true;
    } catch (e) {
      debugPrint("ERROR: scanOn: $e");
      return false;
    }
  }
  static Future<bool> scanOff({
    required Future<bool> Function() requestPermission,
  }) async {
    if(!await requestPermission()) return false;
    try {
      await FlutterBluePlus.stopScan();
      return true;
    } catch (e) {
      debugPrint("ERROR: scanOff: $e");
      return false;
    }
  }
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
      debugPrint("FBP: connect start");
      await device.connect(
        timeout: Duration(seconds: timeout),
      );
      debugPrint("FBP: connect finish");
      return true;
    } catch (e) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        debugPrint("ERROR: Connect: $e");
      }
      return false;
    }
  }
  static Future<bool> disconnect({
    required BluetoothDevice device,
    int timeout = 35,
  }) async {
    try {
      debugPrint("FBP: disconnect start");
      await device.disconnect(
        timeout: timeout,
      );
      debugPrint("FBP: disconnect finish");
      return true;
    } catch (e) {
      debugPrint("ERROR: Disconnect: $e");
      return false;
    }
  }
}
