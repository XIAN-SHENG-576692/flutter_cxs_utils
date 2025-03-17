import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../abstract_bluetooth_device_tracker.dart' show AbstractBluetoothDeviceTracker, AbstractBluetoothDeviceTrackerChangeNotifier;

part 'connectable.dart';
part 'connection.dart';
part 'discover.dart';
part 'rssi.dart';
part 'scan.dart';

class CustomBluetoothDevice {
  String get deviceName => bluetoothDevice.platformName;
  String get deviceId => bluetoothDevice.remoteId.str;
  bool get isConnected => bluetoothDevice.isConnected;
  final BluetoothDevice bluetoothDevice;
  bool matchesBluetoothDevice(BluetoothDevice device) {
    return device == bluetoothDevice;
  }
  bool matchesScanResult(ScanResult result) {
    return result.device == bluetoothDevice;
  }
  CustomBluetoothDevice({
    required this.bluetoothDevice,
  }) {
    onInit(bluetoothDevice);
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is CustomBluetoothDevice && runtimeType == other.runtimeType && bluetoothDevice == other.bluetoothDevice);

  @mustCallSuper
  void onInit(BluetoothDevice bluetoothDevice) {
    return;
  }

  @mustCallSuper
  void onUpdateByScanResult(ScanResult scanResult) {
    return;
  }

  @mustCallSuper
  void dispose() {
    return;
  }
}

class CustomBluetoothDeviceTracker<D extends CustomBluetoothDevice> extends AbstractBluetoothDeviceTracker<D> {
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

class CustomBluetoothDeviceTrackerChangeNotifier<D extends CustomBluetoothDevice> extends AbstractBluetoothDeviceTrackerChangeNotifier<D> {
  @mustCallSuper
  void onInit() {
    return;
  }
  CustomBluetoothDeviceTrackerChangeNotifier({required super.tracker}) {
    onInit();
  }
}
