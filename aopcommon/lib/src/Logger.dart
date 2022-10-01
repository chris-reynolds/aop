///
/// Created by Chris on 21/09/2018.
///
// ignore_for_file: omit_local_variable_types

import 'DateUtil.dart';
import 'dart:io';


typedef LoggerFunc = void Function(String s);

enum eLogLevel { llMessage, llError }

List<String> _logHistory = <String>[];
// eLogLevel logLevel = eLogLevel.llMessage;

class _Log {

// setup default loggers
  static LoggerFunc onMessage = (String s) {
    String stampedMessage = '${formatDate(DateTime.now(),format: 'hh:nn:ss.lll')} $s';
    _logHistory.add(stampedMessage);
    if (_logHistory.length > 1000) _logHistory.removeAt(0);
    print(stampedMessage);
 //   if (logLevel == eLogLevel.llMessage) onMessage(stampedMessage);
  };

  static LoggerFunc onError = (String s) => onMessage('--- ERROR ---- $s');

  List<String> get logHistory => _logHistory;
  void clear() => _logHistory=<String>[];
  void message(String s) => onMessage(s);

  void error(String s) {
    onError(' $s');
  }
  String _logFilename;
  set logFilename(String s) {_logFilename=s;}

    Future<void> save() async  {
      if (_logFilename==null) return;
      IOSink fl = File(_logFilename).openWrite();
      fl.writeAll(_logHistory,'\n');
      await fl.close();
    }
    Future<void> load() async {
      if (_logFilename==null) throw 'No log Filename';
      _logHistory = await File(_logFilename).readAsLines();
    }

}  // of _log

_Log log = _Log();
