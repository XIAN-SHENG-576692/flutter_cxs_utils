part of 'line_chart_change_notifier_manager.dart';

class LineChartChangeNotifier extends ChangeNotifier {
  LineChartChangeNotifierManager manager;
  void _init() {}
  LineChartChangeNotifier({
    required this.manager,
  }) {
    _init();
  }
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

mixin LineChartXChangeNotifier on LineChartChangeNotifier {
  @mustCallSuper
  @override
  void _init() {
    manager.addXListener(notifyListeners);
    super._init();
  }
  @mustCallSuper
  @override
  void dispose() {
    manager.removeXListener(notifyListeners);
    super.dispose();
  }
}


mixin LineChartDatasetChangeNotifier on LineChartChangeNotifier {
  @mustCallSuper
  @override
  void _init() {
    manager.addDatasetListener(notifyListeners);
    super._init();
  }
  @mustCallSuper
  @override
  void dispose() {
    manager.removeDatasetListener(notifyListeners);
    super.dispose();
  }
}
