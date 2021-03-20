///
/// Created by Chris on 21/09/2018.
///
import 'DateUtil.dart';

typedef LoggerFunc = void Function(String s);

enum eLogLevel { llMessage, llError }

List<String> _logHistory = <String>[];
// eLogLevel logLevel = eLogLevel.llMessage;

class _Log {

// setup default loggers
  static LoggerFunc onMessage = (String s) {
    String stampedMessage = '${formatDate(DateTime.now(),format: 'hh:mm:ss.lll')} $s';
    _logHistory.add(stampedMessage);
    if (_logHistory.length > 100) _logHistory.removeAt(0);
 //   if (logLevel == eLogLevel.llMessage) onMessage(stampedMessage);
  };

  static LoggerFunc onError = (String s) => onMessage('--- ERROR ---- $s');

  List<String> get logHistory => _logHistory;
  void clear() => _logHistory=[];
  void message(String s) => onMessage(s);

  void error(String s) {
    onError('${formatDate(DateTime.now(),format: 'hh:mm:ss.lll')} $s');
  }
}  // of _log

_Log log = _Log();
