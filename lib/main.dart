import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'idarc_action.dart';

void main() {
  runApp(const FanDrac());
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int fanspeedpourcent = 50;
  List configuration = [];
  String ip = "";
  String user = "";
  String password = "";

  var idracAction = IdracAction("192.168.1.1", "user", "password");

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/config/idracConf.json');
    final data = await json.decode(response);

    setState(() {
      configuration = data["idrac_configuration"];
    });

    ip = configuration[0]["ip"];
    user = configuration[0]["user"];
    password = configuration[0]["password"];

    print("ip $ip user $user password $password");
  }

  void setFanSpeedAuto() {
    idracAction.setFanModeAuto(true);
  }

  void setFanSpeedManu() {
    idracAction.setFanModeAuto(false);
  }

  void setFanspeed(int lfanspeed) {
    idracAction.setFanSpeed(lfanspeed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Connected to $user@$ip"),
            ElevatedButton(
                onPressed: setFanSpeedAuto, child: const Text("Auto")),
            ElevatedButton(
                onPressed: setFanSpeedManu, child: const Text("Manu")),
            Text(
              "$fanspeedpourcent %",
              style:
                  const TextStyle(fontSize: 40.0, fontWeight: FontWeight.w900),
            ),
            Slider(
                value: fanspeedpourcent.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: "$fanspeedpourcent",
                onChanged: (double value) {
                  setState(() {
                    fanspeedpourcent = value.round();
                  });
                },
                onChangeEnd: (value) {
                  fanspeedpourcent = value.round();
                  setFanspeed(fanspeedpourcent);
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: readJson,
        tooltip: 'Load json configuration',
        child: const Icon(Icons.settings),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
