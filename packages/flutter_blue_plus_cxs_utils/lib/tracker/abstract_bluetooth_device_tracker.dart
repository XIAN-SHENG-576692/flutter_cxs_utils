import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AbstractBluetoothDeviceTracker<D> {
  Iterable<D> get devices => _devices;
  Stream<D> get newDevicesStream => _newDevicesStreamController.stream;
  Stream<D> get oldDevicesStream => _oldDevicesStreamController.stream;
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
  final StreamController<D> _newDevicesStreamController = StreamController.broadcast();
  final StreamController<D> _oldDevicesStreamController = StreamController.broadcast();
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
        _newDevicesStreamController.sink.add(newDevice);
      } else {
        onExistingDeviceUpdated?.call(result, device);
        _oldDevicesStreamController.sink.add(device);
      }
    }
  }
  @mustCallSuper
  void cancel() {
    _scanResultsSubscription.cancel();
    _newDevicesStreamController.close();
    _oldDevicesStreamController.close();
  }
}

class _ChangeNotifier extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class AbstractBluetoothDeviceTrackerChangeNotifier<D> extends ChangeNotifier {

  Iterable<D> get devices => tracker.devices;

  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() => super.notifyListeners();

  @mustCallSuper
  @protected
  @override
  void dispose() {
    _newDeviceSubscription.cancel();
    _oldDeviceSubscription.cancel();
    super.dispose();
  }

  @protected
  final AbstractBluetoothDeviceTracker<D> tracker;
  @protected
  void Function(D device, void Function() notifyListeners)? onNewDevicesFounded;
  @protected
  void Function(D device, void Function() notifyListeners)? onOldDevicesUpdated;

  AbstractBluetoothDeviceTrackerChangeNotifier({
    required this.tracker,
    this.onNewDevicesFounded,
    this.onOldDevicesUpdated,
  }) {
    _newDeviceSubscription = tracker.newDevicesStream.listen((device) {
      onNewDevicesFounded?.call(device, notifyListeners);
    });
    _oldDeviceSubscription = tracker.oldDevicesStream.listen((device) {
      onNewDevicesFounded?.call(device, notifyListeners);
    });
  }

  late final StreamSubscription _newDeviceSubscription;
  late final StreamSubscription _oldDeviceSubscription;
}

class AbstractBluetoothDeviceTrackerNotifier<D> {

  Iterable<D> get devices => tracker.devices;

  final _ChangeNotifier _notifierNew = _ChangeNotifier();
  final _ChangeNotifier _notifierOld = _ChangeNotifier();

  @mustCallSuper
  void dispose() {
    _newDeviceSubscription.cancel();
    _oldDeviceSubscription.cancel();
  }

  void addNewDevicesListener(void Function() listener) {
    _notifierNew.addListener(listener);
  }

  void removeNewDevicesListener(void Function() listener) {
    _notifierOld.removeListener(listener);
  }

  void addOldDevicesListener(void Function() listener) {
    _notifierNew.addListener(listener);
  }

  void removeOldDevicesListener(void Function() listener) {
    _notifierOld.removeListener(listener);
  }

  @protected
  final AbstractBluetoothDeviceTracker<D> tracker;

  AbstractBluetoothDeviceTrackerNotifier({
    required this.tracker,
  }) {
    _newDeviceSubscription = tracker.newDevicesStream.listen((device) {
      _notifierNew.notifyListeners();
    });
    _oldDeviceSubscription = tracker.oldDevicesStream.listen((device) {
      _notifierOld.notifyListeners();
    });
  }

  late final StreamSubscription _newDeviceSubscription;
  late final StreamSubscription _oldDeviceSubscription;

}
