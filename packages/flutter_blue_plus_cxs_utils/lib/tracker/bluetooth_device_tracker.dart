import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceTracker {

  Iterable<BluetoothDevice> get devices => _devices;

  Stream<Iterable<BluetoothDevice>> get devicesStream => _devicesStreamController.stream;

  BluetoothDeviceTracker({
    required List<BluetoothDevice> devices,
  }) : _devices = devices {
    _subscription = FlutterBluePlus.scanResults.listen(_updateResults);
  }

  late final StreamSubscription _subscription;

  final List<BluetoothDevice> _devices;

  final StreamController<Iterable<BluetoothDevice>> _devicesStreamController = StreamController.broadcast();

  void _updateResults(List<ScanResult> results) {
    for (var result in results) {
      var device = devices
          .where((device) => device == result.device)
          .firstOrNull;
      if(device != null) return;
      _devices.add(result.device);
      _devicesStreamController.sink.add(devices);
    }
  }

  @mustCallSuper
  void cancel() {
    _subscription.cancel();
    _devicesStreamController.close();
  }
}

class BluetoothDeviceTrackerChangeNotifier extends ChangeNotifier {

  Iterable<BluetoothDevice> get devices => tracker.devices;

  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();

  @mustCallSuper
  @protected
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @protected
  final BluetoothDeviceTracker tracker;

  BluetoothDeviceTrackerChangeNotifier({
    required this.tracker,
  }) {
    _subscription = tracker.devicesStream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;
}
