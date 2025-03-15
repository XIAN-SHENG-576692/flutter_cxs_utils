import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../abstract_bluetooth_device_tracker.dart' show AbstractBluetoothDeviceTracker;

part 'connectable.dart';
part 'discover.dart';
part 'mtu.dart';
part 'rssi.dart';
part 'scan.dart';

abstract class CustomBluetoothDeviceDispose {
  @mustCallSuper
  void dispose();
}

class _ChangeNotifier extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

abstract class CustomBluetoothDevice {
  @mustCallSuper
  void onInit(BluetoothDevice bluetoothDevice);
  @mustCallSuper
  void onUpdateByScanResult(ScanResult scanResult);
  BluetoothDevice get bluetoothDevice;
  bool matchesBluetoothDevice(BluetoothDevice device);
  bool matchesScanResult(ScanResult result);
}

class BasicCustomBluetoothDevice implements CustomBluetoothDevice, CustomBluetoothDeviceDispose {
  String get deviceName => bluetoothDevice.platformName;
  String get deviceId => bluetoothDevice.remoteId.str;
  @override
  final BluetoothDevice bluetoothDevice;
  @override
  bool matchesBluetoothDevice(BluetoothDevice device) {
    return device == bluetoothDevice;
  }
  @override
  bool matchesScanResult(ScanResult result) {
    return result.device == bluetoothDevice;
  }
  BasicCustomBluetoothDevice({
    required this.bluetoothDevice,
  }) {
    onInit(bluetoothDevice);
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is CustomBluetoothDevice && runtimeType == other.runtimeType && bluetoothDevice == other.bluetoothDevice);

  @mustCallSuper
  @override
  void onInit(BluetoothDevice bluetoothDevice) {
    return;
  }

  @mustCallSuper
  @override
  void onUpdateByScanResult(ScanResult scanResult) {
    return;
  }

  @mustCallSuper
  @override
  void dispose() {
    return;
  }
}

class CustomBluetoothDeviceTracker<D extends CustomBluetoothDevice> extends AbstractBluetoothDeviceTracker<D> {
  CustomBluetoothDeviceTracker({
    required super.devices,
    required super.createNewDeviceByResult,
  }) : super(
    isExistingInDevices: (result, device) => device.matchesScanResult(result),
    onExistingDeviceUpdated: (result, device) => device.onUpdateByScanResult(result),
  );
}
