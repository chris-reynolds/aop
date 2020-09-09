///
/// Created by Chris on 21/09/2018.
///

typedef LoggerFunc = void Function(String s);

enum eLogLevel { llMessage, llError }

class _Log {
  eLogLevel logLevel = eLogLevel.llMessage;

// setup default loggers
  static LoggerFunc onMessage = (String s) => print('----------- $s');

  static LoggerFunc onError = (String s) => onMessage('--- ERROR ---- $s');

  List<String> logHistory = <String>[];

  void message(String s) {
    logHistory.add(s);
    if (logHistory.length > 100) logHistory.removeAt(0);
    if (logLevel == eLogLevel.llMessage) onMessage(s);
  }

  void error(String s) {
    onError(s);
  }
}  // of _log

_Log log = _Log();
