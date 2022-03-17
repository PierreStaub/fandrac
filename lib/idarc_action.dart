import 'package:fandrac/client.dart';
import 'package:process_run/shell.dart';

enum FanMode {
  auto,
  manual,
}

class IdracAction {
  final Client client;

  IdracAction({
    required this.client,
  });

  final _lShell = Shell();

  Future<void> setFanMode({
    required FanMode fanMode,
  }) async {
    final isFanModeAuto = fanMode == FanMode.auto;

    await _lShell.run(
      'C:\\ipmitool_1.8.18-dellemc_p001\\ipmitool.exe -I lanplus -H ${client.ip} -U ${client.login} -P \'${client.password}\' raw 0x30 0x30 0x01 0x0${isFanModeAuto ? 1 : 0}',
    );
  }

  Future<void> setFanSpeed({
    required int fanSpeed,
  }) async {
    final fanSpeedHexadecimal = fanSpeed.toRadixString(16);
    return _setFanSpeed(
      fanSpeed: fanSpeedHexadecimal,
    );
  }

  Future<void> _setFanSpeed({
    required String fanSpeed,
  }) async {
    await _lShell.run(
      'C:\\ipmitool_1.8.18-dellemc_p001\\ipmitool.exe -I lanplus -H ${client.ip} -U ${client.login} -P \'${client.password}\' raw 0x30 0x30 0x02 0xff 0x$fanSpeed',
    );
  }
}
