import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../flutter_blue_plus_utils.dart';

class AbstractBluetoothDeviceUpdate<D> {
  D device;
  bool isNew;
  AbstractBluetoothDeviceUpdate({
    required this.device,
    required this.isNew,
  });
}

class AbstractBluetoothDeviceTracker<D> {
  Iterable<D> get devices => _devices;
  Stream<AbstractBluetoothDeviceUpdate> get onUpdateDevicesStream => _devicesStreamController.stream;
  Stream<D> get onCreateNewDeviceStream => _devicesStreamController.stream.where((event) => event.isNew).map((event) => event.device);
  Stream<D> get onUpdateOldDeviceStream => _devicesStreamController.stream.where((event) => !event.isNew).map((event) => event.device);
  final D Function(ScanResult result) createNewDeviceByResult;
  final Function(ScanResult result, D oldDevice)? onExistingDeviceUpdated;
  final bool Function(ScanResult result, D device) isExistingInDevices;
  AbstractBluetoothDeviceTracker({
    required List<D> devices,
    required this.isExistingInDevices,
    required this.createNewDeviceByResult,
    this.onExistingDeviceUpdated,
  }) : _devices = devices {
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(_updateResults);
  }
  final StreamController<AbstractBluetoothDeviceUpdate<D>> _devicesStreamController = StreamController.broadcast();
  final List<D> _devices;
  late final StreamSubscription _scanResultsSubscription;
  void _updateResults(List<ScanResult> results) {
    for (var result in results) {
      final device = devices
          .where((device) => isExistingInDevices(result, device))
          .firstOrNull;
      if(device == null) {
        final newDevice = createNewDeviceByResult(result);
        _devices.add(newDevice);
        _devicesStreamController.sink.add(AbstractBluetoothDeviceUpdate(
          device: newDevice,
          isNew: true,
        ));
      } else {
        onExistingDeviceUpdated?.call(result, device);
        _devicesStreamController.sink.add(AbstractBluetoothDeviceUpdate(
          device: device,
          isNew: false,
        ));
      }
    }
  }
  @mustCallSuper
  void cancel() {
    _scanResultsSubscription.cancel();
    _devicesStreamController.close();
  }
}

class AbstractBluetoothDevicesLengthTrackerChangeNotifier<D> extends FlutterBluePlusChangeNotifier {

  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();

  @mustCallSuper
  @protected
  @override
  void dispose() {
    _onChangeDevicesLengthSubscription.cancel();
    super.dispose();
  }

  @protected
  final AbstractBluetoothDeviceTracker<D> tracker;

  AbstractBluetoothDevicesLengthTrackerChangeNotifier({
    required this.tracker,
  }) {
    _onChangeDevicesLengthSubscription = tracker.onCreateNewDeviceStream.listen((device) {
      notifyListeners();
    });
  }

  late final StreamSubscription _onChangeDevicesLengthSubscription;
}

mixin AbstractBluetoothDeviceLastUpdatedTrackerChangeNotifier<D> on AbstractBluetoothDevicesLengthTrackerChangeNotifier<D> {

  AbstractBluetoothDeviceUpdate? lastUpdatedDevice;

  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    _onLastUpdateDevicesSubscription = tracker.onUpdateDevicesStream.listen((device) {
      lastUpdatedDevice = device;
      notifyListeners();
    });
    return;
  }
  @mustCallSuper
  @override
  void dispose() {
    _onLastUpdateDevicesSubscription.cancel();
    super.dispose();
  }

  late final StreamSubscription _onLastUpdateDevicesSubscription;
}
