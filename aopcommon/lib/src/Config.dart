// ignore_for_file: omit_local_variable_types
import 'dart:io';
import 'dart:collection';
import 'dart:convert' show jsonDecode, utf8, jsonEncode;
import 'package:path/path.dart' as path;
import 'Logger.dart';

class MapWithDirty with MapMixin<String,dynamic> {
  Map<String,dynamic> _map = {};
  bool dirty = false;
  Iterable<String> get keys  => _map.keys;
  void clear() => _map.clear();
  void remove(Object key) => _map.remove(key);
  dynamic operator [] (Object key) => _map[key];
  operator []=(Object key,dynamic value) {
    if (_map[key] == value) return;
    _map[key] = value;
    dirty = true;
  }
  void init(Map map) {
    clear;
    dirty = false;
    addAll(map);
  } // init

} // of MapWithDirty


//Map<String, dynamic> config = <String, dynamic>{};
var config = MapWithDirty();

String finalFileName;

Future<Map<String, dynamic> > loadConfig([String commandLineFilename]) async {
  const DEFAULT_CONFIG = <String,dynamic>{'dbhost':'192.168.1.198', 'dbname': 'allourphotos_dev', 'dbport': '3306'};

  // ignore: omit_local_variable_types
  String actualFilename = commandLineFilename;
  if (actualFilename == null) {
    String programName = Platform.script.toFilePath();
    String defaultName =
    programName.replaceAll('\.dart', '\.config\.json'); //.substring(5);
    defaultName = defaultName.replaceAll('\.aot', '\.config\.json');
    actualFilename = path.basename(defaultName);
  }
//  if (Path.dirname(actualFilename)=='.')
//    actualFilename = Path.join((await getApplicationDocumentsDirectory()).path,actualFilename); todo restore
  if (!FileSystemEntity.isFileSync(actualFilename)) {
    log.message('Invalid configuration name $actualFilename');
    config.init(DEFAULT_CONFIG);
  } else {
    String configContents =
        File(actualFilename).readAsStringSync(encoding: utf8);
    try {
      config.init(jsonDecode(configContents));
    } catch (err, st) {
      log.error('Corrupt configuration file $actualFilename \n $st');
      config.init(DEFAULT_CONFIG);
    } // of catch
  }
  finalFileName = actualFilename;
  return config;
} // of loadConfig

Future<void> saveConfig() async {
  if (!config.dirty) {
    log.message('CONFIG IS UNCHANGED');
    return;
  }
  final String serialized = jsonEncode(config);
  try {
    await File(finalFileName).writeAsString(serialized);
    config.dirty = false;  // saved to no longer dirty
    log.message('Config saved');
  } catch (ex) {
    log.error('Failed to save config to $finalFileName \n with error $ex');
    rethrow;
  }
  return;
} // of saveConfig
