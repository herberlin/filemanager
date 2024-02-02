class Logger {
  void debug(String msg, [Object? obj]) {
    _print(Level.debug, msg, obj);
  }

  void info(String msg, [Object? obj]) {
    _print(Level.info, msg, obj);
  }

  void warn(String msg, [Object? obj]) {
    _print(Level.warn, msg, obj);
  }

  void error(String msg, [Object? obj]) {
    _print(Level.error, msg, obj);
  }

  void _print(Level level, String msg, [Object? obj]) {
    const showDate = false;
    const stackTracePosition = 2;
    void printPadded(obj) {
      print("".padLeft(19) + obj.toString());
    }

    String result = DateTime.now().toString().substring(showDate ? 0 : 11, 23);
    result += " ${level.toString().substring(6).toUpperCase().padRight(5)} ";
    List<String> list = StackTrace.current.toString().split("\n");
    if (list.length > stackTracePosition) {
      result += list[stackTracePosition].substring(8);
    }
    result += " $msg";
    print(result);
    if (obj != null) {
      printPadded(obj);
    }
    if (obj is Exception && list.length > stackTracePosition) {
      for (var i = stackTracePosition; i < list.length; i++) {
        printPadded(list[i]);
      }
    }
  }
}

enum Level { debug, info, warn, error }

final Logger log = Logger();

void main() {
  log.debug("TEST");
  log.debug("TEST", ["eins", "zwei", "drei"]);
  try {
    throw Exception("TEST");
  } catch (e) {
    log.error("piff", e);
  }
}
