import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../flutter_blue_plus_utils.dart';

/// Represents an update event for a tracked Bluetooth device
class AbstractBluetoothDeviceUpdate<D> {
  D device;
  int index;
  bool isNew;

  /// Constructor for device update events
  AbstractBluetoothDeviceUpdate({
    required this.device,
    required this.index,
    required this.isNew,
  });
}

/// Abstract tracker for monitoring Bluetooth devices
class AbstractBluetoothDeviceTracker<D> {
  /// Returns the list of currently tracked devices
  Iterable<D> get devices => _devices;

  /// Stream that emits update events when devices are added or modified
  Stream<AbstractBluetoothDeviceUpdate> get onUpdateDevicesStream => _devicesStreamController.stream;

  /// Stream that emits newly discovered devices
  Stream<D> get onCreateNewDeviceStream => _devicesStreamController.stream
      .where((event) => event.isNew)
      .map((event) => event.device);

  /// Stream that emits updates for existing devices
  Stream<D> get onUpdateOldDeviceStream => _devicesStreamController.stream
      .where((event) => !event.isNew)
      .map((event) => event.device);

  /// Function to create a new device from scan results
  final D Function(ScanResult result) createNewDeviceByResult;

  /// Callback for handling updates on existing devices
  final Function(ScanResult result, D oldDevice)? onExistingDeviceUpdated;

  /// Function to check if a scanned device already exists in the tracker
  final bool Function(ScanResult result, D device) isExistingInDevices;

  /// Constructor for the Bluetooth device tracker
  AbstractBluetoothDeviceTracker({
    required List<D> devices,
    required this.isExistingInDevices,
    required this.createNewDeviceByResult,
    this.onExistingDeviceUpdated,
  }) : _devices = devices {
    _updateDevicesByScanResultsSubscription = FlutterBluePlus.scanResults.listen(_updateDevicesByScanResults);
  }

  /// Stream controller for broadcasting device updates
  final StreamController<AbstractBluetoothDeviceUpdate<D>> _devicesStreamController = StreamController.broadcast();

  /// Internal list of tracked devices
  final List<D> _devices;

  /// Subscription for scan results
  late final StreamSubscription _updateDevicesByScanResultsSubscription;

  /// Updates the tracked devices list based on scan results
  void _updateDevicesByScanResults(List<ScanResult> results) {
    for (var result in results) {
      final device = devices
          .indexed
          .where((device) => isExistingInDevices(result, device.$2))
          .firstOrNull;

      if (device == null) {
        final newDevice = createNewDeviceByResult(result);
        _devices.add(newDevice);
        _devicesStreamController.sink.add(AbstractBluetoothDeviceUpdate(
          device: newDevice,
          index: (_devices.length - 1),
          isNew: true,
        ));
      } else {
        onExistingDeviceUpdated?.call(result, device.$2);
        _devicesStreamController.sink.add(AbstractBluetoothDeviceUpdate(
          device: device.$2,
          index: device.$1,
          isNew: false,
        ));
      }
    }
  }

  /// Cancels subscriptions and closes the stream controller to prevent memory leaks
  @mustCallSuper
  void cancel() {
    _updateDevicesByScanResultsSubscription.cancel();
    _devicesStreamController.close();
  }
}

/// Notifier that tracks the number of Bluetooth devices detected
class AbstractBluetoothDevicesLengthTrackerChangeNotifier<D> extends FlutterBluePlusChangeNotifier {
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
    _onChangeDevicesLengthSubscription.cancel();
    super.dispose();
  }

  /// Initializes the notifier and starts listening for device creates
  @override
  @protected
  @mustCallSuper
  void onInit() {
    super.onInit();
    _onChangeDevicesLengthSubscription = tracker.onCreateNewDeviceStream.listen((device) {
      notifyListeners();
    });
  }

  /// Bluetooth device tracker instance
  @protected
  final AbstractBluetoothDeviceTracker<D> tracker;

  /// Constructor for the change notifier
  AbstractBluetoothDevicesLengthTrackerChangeNotifier({
    required this.tracker,
  });

  /// Subscription to track new device additions
  late final StreamSubscription _onChangeDevicesLengthSubscription;
}

/// Mixin that tracks the last updated Bluetooth device
mixin AbstractBluetoothDeviceLastUpdatedTrackerChangeNotifier<D> on AbstractBluetoothDevicesLengthTrackerChangeNotifier<D> {
  /// Stores the last updated device
  AbstractBluetoothDeviceUpdate? lastUpdatedDevice;

  /// Initializes the mixin and starts listening for device updates
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    _onLastUpdateDevicesSubscription = tracker.onUpdateDevicesStream.listen((device) {
      lastUpdatedDevice = device;
      notifyListeners();
    });
  }

  /// Cancels the subscription when disposing to prevent memory leaks
  @mustCallSuper
  @override
  void dispose() {
    _onLastUpdateDevicesSubscription.cancel();
    super.dispose();
  }

  /// Subscription to track the last updated device
  late final StreamSubscription _onLastUpdateDevicesSubscription;
}
