class Logger {
  final String _name;

  Logger(this._name);

  void debug(String msg, [Object? obj = null]) {
    _print(Level.debug, msg, obj);
  }

  void error(String msg, [Object? obj = null]) {
    _print(Level.error, msg, obj);
  }

  void _print(Level level, String msg, [Object? obj = null]) {
    final showDate = false;
    final stackTracePosition = 2;
    void _printPadded(obj) {
      print("".padLeft(19) + obj.toString());
    }

    String result = DateTime.now().toString().substring(showDate ? 0 : 11, 23);
    result += " " + level.toString().substring(6).toUpperCase().padRight(5);
    result += " ${_name}#";
    List<String> list = StackTrace.current.toString().split("\n");
    if (list.length > stackTracePosition) {
      result += list[stackTracePosition].substring(8);
    }
    result += " $msg";
    print(result);
    if (obj != null) {
      _printPadded(obj);
    }
    if (obj is Exception && list.length > stackTracePosition) {
      for (var i = stackTracePosition; i < list.length; i++) {
        _printPadded(list[i]);
      }
    }
  }
}

enum Level { debug, info, warn, error }

void main() {
  var log = new Logger("Logger");
  log.debug("TEST");
  log.debug("TEST", ["eins", "zwei", "drei"]);
  try {
    throw Exception("TEST");
  } catch (e, st) {
    log.error("piff", e);
  }
}
