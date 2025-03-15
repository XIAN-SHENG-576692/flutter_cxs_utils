part of 'bluetooth_widget.dart';

extension BluetoothWidgetDevice on BluetoothWidget {
  static Widget buildTitle({
    required BuildContext context,
    required String deviceName,
    required String deviceId,
  }) {
    return (deviceName.isNotEmpty)
      ? Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            deviceName,
            overflow: TextOverflow.ellipsis,
          ),
          Builder(
            builder: (context) {
              return Text(
                deviceId,
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
        ],
      )
      : Text(deviceId);
  }
}
