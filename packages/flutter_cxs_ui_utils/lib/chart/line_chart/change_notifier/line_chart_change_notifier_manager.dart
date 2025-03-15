import 'package:flutter/widgets.dart';

part 'line_chart_change_notifier.dart';

class _ChangeNotifier extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class LineChartChangeNotifierManager<X> extends ChangeNotifier {
  final _ChangeNotifier _notifierDataset = _ChangeNotifier();
  void notifyDatasetListeners() {
    _notifierDataset.notifyListeners();
  }
  void addDatasetListener(void Function() listener) {
    _notifierDataset.addListener(listener);
  }
  void removeDatasetListener(void Function() listener) {
    _notifierDataset.removeListener(listener);
  }

  final _ChangeNotifier _notifierX = _ChangeNotifier();
  X _x;
  X get x => _x;
  set x(X newX) {
    _x = newX;
    if(x == newX) return;
    _notifierX.notifyListeners();
  }
  void notifyXListeners() {
    _notifierX.notifyListeners();
  }
  void addXListener(void Function() listener) {
    _notifierX.addListener(listener);
  }
  void removeXListener(void Function() listener) {
    _notifierX.removeListener(listener);
  }

  LineChartChangeNotifierManager({
    required X x,
  }) : _x = x;

  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
  }

  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  @override
  void dispose() {
    _notifierDataset.dispose();
    _notifierX.dispose();
    super.dispose();
  }
}
