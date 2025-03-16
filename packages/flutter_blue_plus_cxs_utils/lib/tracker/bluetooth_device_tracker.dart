import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceTracker {

  Iterable<BluetoothDevice> get bluetoothDevices => _bluetoothDevices;

  Stream<Iterable<BluetoothDevice>> get bluetoothDevicesStream => _devicesStreamController.stream;

  BluetoothDeviceTracker({
    required List<BluetoothDevice> devices,
  }) : _bluetoothDevices = devices {
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(_updateResults);
  }

  late final StreamSubscription _scanResultsSubscription;

  final List<BluetoothDevice> _bluetoothDevices;

  final StreamController<Iterable<BluetoothDevice>> _devicesStreamController = StreamController.broadcast();

  void _updateResults(List<ScanResult> results) {
    for (var result in results) {
      var device = bluetoothDevices
        .where((device) => device == result.device)
        .firstOrNull;
      if(device != null) return;
      _bluetoothDevices.add(result.device);
      _devicesStreamController.sink.add(bluetoothDevices);
    }
  }

  @mustCallSuper
  void cancel() {
    _scanResultsSubscription.cancel();
    _devicesStreamController.close();
  }
}

class BluetoothDeviceTrackerChangeNotifier extends ChangeNotifier {

  Iterable<BluetoothDevice> get bluetoothDevices => tracker.bluetoothDevices;

  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();

  @mustCallSuper
  @protected
  @override
  void dispose() {
    _bluetoothDevicesSubscription.cancel();
    super.dispose();
  }

  @protected
  final BluetoothDeviceTracker tracker;

  BluetoothDeviceTrackerChangeNotifier({
    required this.tracker,
  }) {
    _bluetoothDevicesSubscription = tracker.bluetoothDevicesStream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription _bluetoothDevicesSubscription;
}
