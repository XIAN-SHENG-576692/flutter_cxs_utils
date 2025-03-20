import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../abstract_bluetooth_device_tracker.dart' show AbstractBluetoothDeviceLastUpdatedTrackerChangeNotifier, AbstractBluetoothDeviceTracker, AbstractBluetoothDevicesLengthTrackerChangeNotifier;

part 'connectable.dart';
part 'connection.dart';
part 'discover.dart';
part 'rssi.dart';
part 'scan.dart';

/// Represents a custom Bluetooth device with additional functionality
class CustomBluetoothDevice {
  /// Returns the device's name
  String get deviceName => bluetoothDevice.platformName;

  /// Returns the device's unique identifier
  String get deviceId => bluetoothDevice.remoteId.str;

  /// Checks if the device is currently connected
  bool get isConnected => bluetoothDevice.isConnected;

  /// The underlying Bluetooth device instance
  final BluetoothDevice bluetoothDevice;

  /// Checks if the given Bluetooth device matches this instance
  bool matchesBluetoothDevice(BluetoothDevice device) {
    return device == bluetoothDevice;
  }

  /// Checks if the scan result corresponds to this device
  bool matchesScanResult(ScanResult result) {
    return result.device == bluetoothDevice;
  }

  /// Constructor for creating a custom Bluetooth device
  CustomBluetoothDevice({
    required this.bluetoothDevice,
  }) {
    onInit(bluetoothDevice);
  }

  /// Equality operator override to compare devices
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is CustomBluetoothDevice && runtimeType == other.runtimeType && bluetoothDevice == other.bluetoothDevice);

  /// Initializes the device when created
  @mustCallSuper
  void onInit(BluetoothDevice bluetoothDevice) {
    return;
  }

  /// Updates the device based on scan result data
  @mustCallSuper
  void onUpdateByScanResult(ScanResult scanResult) {
    return;
  }

  /// Cleans up resources when the device is no longer needed
  @mustCallSuper
  void dispose() {
    return;
  }
}

/// Tracker for managing multiple CustomBluetoothDevice instances
class CustomBluetoothDeviceTracker<D extends CustomBluetoothDevice> extends AbstractBluetoothDeviceTracker<D> {
  /// Constructor for the custom Bluetooth device tracker
  CustomBluetoothDeviceTracker({
    required List<BluetoothDevice> devices,
    required D Function(BluetoothDevice device) deviceCreator,
  }) : super(
    devices: devices.map(deviceCreator).toList(),
    createNewDeviceByResult: (result) {
      final device = deviceCreator(result.device);
      return device..onUpdateByScanResult(result);
    },
    isExistingInDevices: (result, device) => device.matchesScanResult(result),
    onExistingDeviceUpdated: (result, device) => device.onUpdateByScanResult(result),
  );
}

/// Notifier for tracking the number of detected CustomBluetoothDevice instances
class CustomBluetoothDeviceLengthTrackerChangeNotifier<D extends CustomBluetoothDevice> extends AbstractBluetoothDevicesLengthTrackerChangeNotifier<D> {
  /// Constructor for the change notifier
  CustomBluetoothDeviceLengthTrackerChangeNotifier({required super.tracker});
}

/// Mixin that tracks the last updated CustomBluetoothDevice instances
mixin CustomBluetoothDeviceLastUpdatedTrackerChangeNotifier<D extends CustomBluetoothDevice> on AbstractBluetoothDeviceLastUpdatedTrackerChangeNotifier<D> {
}
