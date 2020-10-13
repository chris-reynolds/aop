// ignore_for_file: omit_local_variable_types
import 'dart:io';
import 'dart:convert' show jsonDecode, utf8, jsonEncode;
import 'package:path/path.dart' as path;
import 'Logger.dart';

Map<String, dynamic> config = <String, dynamic>{};
String finalFileName;

Future<Map<String, dynamic> > loadConfig([String commandLineFilename]) async {
//  String os = Platform.operatingSystem;

  // ignore: omit_local_variable_types
  String programName = Platform.script.toFilePath();
  String defaultName =
      programName.replaceAll('\.dart', '\.config\.json'); //.substring(5);
  defaultName = defaultName.replaceAll('\.aot', '\.config\.json');
  defaultName = path.basename(defaultName);
  String actualFilename = commandLineFilename ?? defaultName;
//  if (Path.dirname(actualFilename)=='.')
//    actualFilename = Path.join((await getApplicationDocumentsDirectory()).path,actualFilename); todo restore
  if (!FileSystemEntity.isFileSync(actualFilename)) {
    log.message('Invalid configuration name $actualFilename');
    config = <String,dynamic>{'dbhost':'last1.local', 'dbname': 'allourphotos_dev', 'dbport': '3306'};
  } else {
    String configContents =
        File(actualFilename).readAsStringSync(encoding: utf8);
    try {
      config = jsonDecode(configContents);
    } catch (err, st) {
      throw 'Corrupt configuration file $actualFilename \n $st';
    } // of catch
  }
  finalFileName = actualFilename;
  return config;
} // of loadConfig

Future<void> saveConfig() async {
  final String serialized = jsonEncode(config);
  try {
    await File(finalFileName).writeAsString(serialized);
  } catch (ex) {
    log.error('Failed to save config to $finalFileName \n with error $ex');
    rethrow;
  }
  return;
} // of saveConfig
