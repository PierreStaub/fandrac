import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FanDrac());
  doWhenWindowReady(() {
    const initialSize = Size(
      400,
      400,
    );
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class FanDrac extends StatelessWidget {
  const FanDrac({Key? key}) : super(key: key);

  static const String _title = 'iDrac Fan Control';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const HomePage(title: 'iDrac Fan Control'),
    );
  }
}
