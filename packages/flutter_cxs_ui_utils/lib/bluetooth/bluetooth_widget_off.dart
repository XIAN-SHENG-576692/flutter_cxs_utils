part of 'bluetooth_widget.dart';

extension BluetoothWidgetOff on BluetoothWidget {
  static Widget buildOffScreen({
    required BuildContext context,
    required VoidCallback turnOn,
    Color? backGroundColor = Colors.lightBlue,
    Color? textColor = Colors.white,
    String message = 'Bluetooth Adapter is not available.',
    String buttonText = 'TURN ON',
  }) {
    final themeData = Theme.of(context);
    const Widget icon = Icon(
      Icons.bluetooth_disabled,
      size: 200.0,
      color: Colors.white54,
    );
    final Widget title = Builder(
      builder: (context) {
        return Text(
          message,
          style: themeData
            .primaryTextTheme
            .titleSmall
            ?.copyWith(
              color: textColor,
            ),
        );
      },
    );
    final Widget turnOnButton = Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: turnOn,
        child: Text(buttonText),
      ),
    );
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: backGroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon,
              title,
              turnOnButton,
            ],
          ),
        ),
      ),
    );
  }
}
