import 'dart:io';

void main() {
  print(Sysutils.getUserHome());
}

class Sysutils {
  static String getUserHome() {
    Map<String, String> env = Platform.environment;
    String? result;
    if (Platform.isMacOS) {
      result = env['HOME'];
    } else if (Platform.isLinux) {
      result = env['HOME'];
    } else if (Platform.isWindows) {
      result = env['UserProfile'];
    } else if (Platform.isAndroid) {
      result = env['EXTERNAL_STORAGE'];
    }
    return result ?? Platform.script.path;
  }
}
