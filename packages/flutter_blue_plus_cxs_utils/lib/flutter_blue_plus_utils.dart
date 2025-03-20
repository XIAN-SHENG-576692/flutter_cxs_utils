import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Base change notifier that extends ChangeNotifier to provide notification mechanism
class FlutterBluePlusChangeNotifier extends ChangeNotifier {
  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();

  @protected
  @mustCallSuper
  void onInit() {}

  /// Constructor that initializes by calling onInit method
  FlutterBluePlusChangeNotifier() {
    onInit();
  }
}

/// Mixin for monitoring Bluetooth adapter state changes
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

  /// Dispose the subscription to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    _adapterStateSubscription.cancel();
    super.dispose();
  }
}

/// Mixin for checking if Bluetooth is turned on
mixin BluetoothIsOnChangeNotifier on BluetoothAdapterStateChangeNotifier {
  bool get isOn => adapterState == BluetoothAdapterState.on;
}

/// Mixin for monitoring Bluetooth scanning state
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

  /// Dispose the subscription to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    _isScanningSubscription.cancel();
    super.dispose();
  }
}

/// Mixin for monitoring scan result changes
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

  /// Dispose the subscription to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    super.dispose();
  }
}

/// Utility class for Bluetooth operations
class FlutterBluePlusUtils {
  const FlutterBluePlusUtils._();

  /// Attempts to turn on Bluetooth, returns false if permission is not granted
  static Future<bool> turnOn({
    required Future<bool> Function() requestPermission,
  }) async {
    if (!await requestPermission()) return false;
    await FlutterBluePlus.turnOn();
    return true;
  }

  /// Rescans Bluetooth devices by stopping and restarting scanning
  static Future<void> rescan({
    required Future<bool> Function() requestPermission,
    required Duration scanDuration,
  }) async {
    if (!await requestPermission()) return;
    await stopScan(requestPermission: requestPermission);
    await startScan(requestPermission: requestPermission, scanDuration: scanDuration);
  }

  /// Toggles scanning: stops if currently scanning, starts otherwise
  static Future<bool> toggleScan({
    required Future<bool> Function() requestPermission,
    required Duration scanDuration,
  }) async {
    if (!await requestPermission()) return false;
    return (FlutterBluePlus.isScanningNow)
        ? stopScan(requestPermission: requestPermission)
        : startScan(requestPermission: requestPermission, scanDuration: scanDuration);
  }

  /// Starts scanning for Bluetooth devices, returns false if permission is not granted or already scanning
  static Future<bool> startScan({
    required Future<bool> Function() requestPermission,
    required Duration scanDuration,
  }) async {
    if (!await requestPermission()) return false;
    if (FlutterBluePlus.isScanningNow) return false;
    try {
      // Android platform scans slower, so it requests only 1/8 of the advertisements
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

  /// Stops Bluetooth scanning, returns false if permission is not granted
  static Future<bool> stopScan({
    required Future<bool> Function() requestPermission,
  }) async {
    if (!await requestPermission()) return false;
    try {
      await FlutterBluePlus.stopScan();
      return true;
    } catch (e) {
      debugPrint("ERROR: scanOff: $e");
      return false;
    }
  }
}
