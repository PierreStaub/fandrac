import 'dart:convert';

import 'package:fandrac/client.dart';
import 'package:fandrac/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'idarc_action.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final IdracAction idracAction;
  late final Client _client;
  int _fanSpeedPercent = fanSpeedDefault;

  @override
  void initState() async {
    _client = await _getClient();
    idracAction = IdracAction(client: _client);
    super.initState();
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
            Text("Connected to $_client"),
            ElevatedButton(
              onPressed: () {
                idracAction.setFanMode(
                  fanMode: FanMode.auto,
                );
              },
              child: const Text(
                "Auto",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                idracAction.setFanMode(
                  fanMode: FanMode.manual,
                );
              },
              child: const Text(
                "Manual",
              ),
            ),
            Text(
              "$_fanSpeedPercent %",
              style: const TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            Slider(
                value: _fanSpeedPercent.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: "$_fanSpeedPercent",
                onChanged: (double fanSpeed) {
                  setState(() {
                    _fanSpeedPercent = fanSpeed.round();
                  });
                },
                onChangeEnd: (double fanSpeed) async {
                  _fanSpeedPercent = fanSpeed.round();
                  await idracAction.setFanMode(
                    fanMode: FanMode.manual,
                  );
                  idracAction.setFanSpeed(
                    fanSpeed: _fanSpeedPercent,
                  );
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getClient,
        tooltip: 'Load json configuration',
        child: const Icon(
          Icons.settings_rounded,
        ),
      ),
    );
  }

  Future<Client> _getClient() async {
    final String _idracConfigurationJson = await rootBundle.loadString(
      idracConfigurationAsset,
    );
    final idracConfiguration = await json.decode(_idracConfigurationJson);

    final List _configuration = idracConfiguration["idrac_configuration"];

    final String _ip = _configuration[0]["ip"] as String;
    final String _login = _configuration[0]["user"] as String;
    final String _password = _configuration[0]["password"] as String;

    _client = Client(
      ip: _ip,
      login: _login,
      password: _password,
    );

    print(_client);

    return _client;
  }
}
