import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_cxs_utils/flutter_blue_plus_utils.dart' show FlutterBluePlusChangeNotifier;

/// Tracks Bluetooth devices and maintains a list of discovered devices
class BluetoothDeviceTracker {
  /// Returns the list of currently tracked Bluetooth devices
  Iterable<BluetoothDevice> get bluetoothDevices => _bluetoothDevices;

  /// Stream that provides updates whenever new devices are discovered
  Stream<Iterable<BluetoothDevice>> get bluetoothDevicesStream => _devicesStreamController.stream;

  /// Constructor initializes the tracker with an initial list of devices
  BluetoothDeviceTracker({
    required List<BluetoothDevice> devices,
  }) : _bluetoothDevices = devices {
    _updateBluetoothDevicesByScanResultsSubscription = FlutterBluePlus.scanResults.listen(_updateBluetoothDevicesByScanResults);
  }

  /// Subscription to the Bluetooth scan results stream
  late final StreamSubscription _updateBluetoothDevicesByScanResultsSubscription;

  /// List of currently tracked Bluetooth devices
  final List<BluetoothDevice> _bluetoothDevices;

  /// Stream controller that broadcasts device updates
  final StreamController<Iterable<BluetoothDevice>> _devicesStreamController = StreamController.broadcast();

  /// Updates the list of devices whenever new scan results are available
  void _updateBluetoothDevicesByScanResults(List<ScanResult> results) {
    for (var result in results) {
      var device = bluetoothDevices.where((device) => device == result.device).firstOrNull;
      if (device != null) return;
      _bluetoothDevices.add(result.device);
      _devicesStreamController.sink.add(bluetoothDevices);
    }
  }

  /// Cancels subscriptions and closes the stream controller to prevent memory leaks
  @mustCallSuper
  void cancel() {
    _updateBluetoothDevicesByScanResultsSubscription.cancel();
    _devicesStreamController.close();
  }
}

/// Notifier class that listens for Bluetooth device tracking updates
class BluetoothDeviceTrackerChangeNotifier extends FlutterBluePlusChangeNotifier {
  /// Returns the list of tracked Bluetooth devices
  Iterable<BluetoothDevice> get bluetoothDevices => tracker.bluetoothDevices;

  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();

  /// Cancels the subscription when disposing to prevent memory leaks
  @mustCallSuper
  @protected
  @override
  void dispose() {
    _bluetoothDevicesSubscription.cancel();
    super.dispose();
  }

  /// Bluetooth device tracker instance
  @protected
  final BluetoothDeviceTracker tracker;

  /// Initializes the notifier and starts listening for device updates
  @override
  @protected
  @mustCallSuper
  void onInit() {
    super.onInit();
    _bluetoothDevicesSubscription = tracker.bluetoothDevicesStream.listen((_) {
      notifyListeners();
    });
  }

  /// Constructor for the change notifier
  BluetoothDeviceTrackerChangeNotifier({
    required this.tracker,
  });

  /// Subscription to the Bluetooth device tracking stream
  late final StreamSubscription _bluetoothDevicesSubscription;
}
