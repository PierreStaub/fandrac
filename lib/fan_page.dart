import 'dart:convert';
import 'package:fandrac/client.dart';
import 'package:fandrac/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'idarc_action.dart';

class FanPage extends StatefulWidget {
  const FanPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<FanPage> createState() => _FanPageState();
}

class _FanPageState extends State<FanPage> {
  late final IdracAction idracAction;
  late final Client _client;
  int _fanSpeedPercent = fanSpeedDefault;
  bool _isLoading = false;
  int? _selectedMode;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    _getClient().then(
      (Client client) {
        idracAction = IdracAction(client: _client);
        setState(() {
          _isLoading = false;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(5),
                  child: CupertinoSlidingSegmentedControl<int>(
                    backgroundColor: CupertinoColors.lightBackgroundGray,
                    thumbColor: Color.fromARGB(255, 48, 129, 236),
                    padding: const EdgeInsets.all(8),
                    groupValue: _selectedMode,
                    children: {
                      0: buildSegment("Auto"),
                      1: buildSegment("Manual"),
                    },
                    onValueChanged: (int? selectedSegment) {
                      setState(() {
                        _selectedMode = selectedSegment;
                      });
                      idracAction.setFanMode(
                        fanMode: FanMode.values.firstWhere(
                          (fanMode) {
                            return fanMode.index == selectedSegment;
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                SleekCircularSlider(
                  initialValue: _fanSpeedPercent.toDouble(),
                  min: 0,
                  max: 100,
                  appearance: const CircularSliderAppearance(),
                  onChange: (double fanSpeed) {
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
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                Text("$_client"),
              ],
            ),
            // TODO: new load button for json
            // floatingActionButton: FloatingActionButton(
            //   onPressed: _getClient,
            //   tooltip: 'Load json configuration',
            //   child: const Icon(
            //     Icons.settings_rounded,
            //   ),
            // ),
          );
  }

  Widget buildSegment(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        color: Colors.black,
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
