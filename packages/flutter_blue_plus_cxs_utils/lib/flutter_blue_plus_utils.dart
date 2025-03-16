import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FlutterBluePlusChangeNotifier extends ChangeNotifier {
  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();
  @mustCallSuper
  void onInit() {}
  FlutterBluePlusChangeNotifier() {
    onInit();
  }
}

mixin BluetoothAdapterStateChangeNotifier on FlutterBluePlusChangeNotifier {
  BluetoothAdapterState _adapterState = FlutterBluePlus.adapterStateNow;
  BluetoothAdapterState get adapterState => _adapterState;
  late final StreamSubscription _adapterStateSubscription;
  @mustCallSuper
  @override
  onInit() {
    super.onInit();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((adapterState) {
      _adapterState = adapterState;
      notifyListeners();
    });
  }
  @mustCallSuper
  @override
  void dispose() {
    _adapterStateSubscription.cancel();
    super.dispose();
  }
}

mixin BluetoothIsOnChangeNotifier on BluetoothAdapterStateChangeNotifier {
  bool get isOn => adapterState == BluetoothAdapterState.on;
}

mixin BluetoothIsScanningChangeNotifier on FlutterBluePlusChangeNotifier {
  bool _isScanning = FlutterBluePlus.isScanningNow;
  bool get isScanning => _isScanning;
  late final StreamSubscription _isScanningSubscription;
  @mustCallSuper
  @override
  onInit() {
    super.onInit();
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      notifyListeners();
    });
  }
  @mustCallSuper
  @override
  void dispose() {
    _isScanningSubscription.cancel();
    super.dispose();
  }
}

mixin ScanResultsChangeNotifier on FlutterBluePlusChangeNotifier {
  List<ScanResult> _scanResults = [];
  Iterable<ScanResult> get scanResults => _scanResults;
  late final StreamSubscription _scanResultsSubscription;
  @mustCallSuper
  @override
  onInit() {
    super.onInit();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((scanResults) {
      _scanResults = scanResults;
      notifyListeners();
    });
  }
  @mustCallSuper
  @override
  void dispose() {
    _scanResultsSubscription.cancel();
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
    await stopScan(requestPermission: requestPermission);
    await startScan(requestPermission: requestPermission, scanDuration: scanDuration);
    return;
  }
  static Future<bool> toggleScan({
    required Future<bool> Function() requestPermission,
    required Duration scanDuration,
  }) async {
    if(!await requestPermission()) return false;
    return (FlutterBluePlus.isScanningNow)
        ? stopScan(requestPermission: requestPermission)
        : startScan(requestPermission: requestPermission, scanDuration: scanDuration);
  }
  static Future<bool> startScan({
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
  static Future<bool> stopScan({
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
}
