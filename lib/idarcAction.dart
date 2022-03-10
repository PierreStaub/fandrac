import 'package:process_run/shell.dart';

class IdracAction {
  // global variables of the class
  bool gbfanAutoMode = false;
  String giactualSpeed = "";
  String gpassword = "";
  String gip = "";
  String gUser = "";
  String gPassword = "";

  IdracAction(this.gip, this.gUser, this.gPassword) {
    // Init of the IdracAction class
  }

  Future<int> setFanModeAuto(bool liMode) async {
    int liResult = 0;
    var lShell = Shell();
    if (liMode) {
      await lShell.run(
          'C:\\ipmitool_1.8.18-dellemc_p001\\ipmitool.exe -I lanplus -H $gip -U $gUser -P \'$gPassword\' raw 0x30 0x30 0x01 0x01');
    } else {
      await lShell.run(
          'C:\\ipmitool_1.8.18-dellemc_p001\\ipmitool.exe -I lanplus -H $gip -U $gUser -P \'$gPassword\' raw 0x30 0x30 0x01 0x00');
    }
    return liResult;
  }

  int setFanSpeed(int liSpeed) {
    int liResult = 0;
    giactualSpeed = liSpeed.toRadixString(16);
    execIpmiCmd();
    return liResult;
  }

  void execIpmiCmd() async {
    var lShell = Shell();
    String lidracCmd =
        'C:\\ipmitool_1.8.18-dellemc_p001\\ipmitool.exe -I lanplus -H $gip -U $gUser -P \'$gPassword\' raw 0x30 0x30 0x02 0xff 0x$giactualSpeed';
    print(lidracCmd);
    await lShell.run(
        'C:\\ipmitool_1.8.18-dellemc_p001\\ipmitool.exe -I lanplus -H $gip -U $gUser -P \'$gPassword\' raw 0x30 0x30 0x02 0xff 0x$giactualSpeed');
  }
}
