import 'dart:io';
import 'dart:math';
import 'dart:ui';

class Utils {
  static String getCurrentTime() {
    var now = new DateTime.now();
    return "${now.hour}:${now.minute}:${now.second}";
  }

  static String getCurrentDate() {
    var now = new DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  static String getCurrentDateTime() {
    var now = new DateTime.now();
    return "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}";
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Color randomColor() {
    return Color(0xFF000000 + (Random().nextInt(0xFFFFFF)));
  }

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }

    return false;
  }


}