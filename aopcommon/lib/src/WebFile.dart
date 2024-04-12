// ignore_for_file: omit_local_variable_types

/*
  Created by chrisreynolds on 2019-09-09
  
  Purpose: 

*/
// import 'dart:io';

import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:aopcommon/aopcommon.dart';

class WebFile {
  String url;
  String contents = '';
  Uint8List? bodyBytes;
  static String _rootUrl = ''; //'http://${config["host"]}:${config['port']}';
  // ignore: prefer_final_fields
  static String _preserve = '';
  static String get preserve => _preserve;
  static void setPreserve(String preserve) {
    _preserve = preserve;
  }

  static String get rootUrl => _rootUrl;
  static void setRootUrl(String rootUrl) {
    _rootUrl = rootUrl;
  }

  WebFile._(this.url); // private constructor

  static Future<bool> get hasWebServer async {
    try {
      var response = await loadWebFile('tagList.txt', 'blah');
      return (response.contents != 'blah');
    } catch (ex) {
      return false;
    }
  }
} // of webFile

Future<WebFile> loadWebFile(String url, String? defaultValue,
    {int timeOut = 10}) async {
  if (!url.contains('http')) {
    if (WebFile._rootUrl == '') throw Exception('No rootUrl');
    url = '${WebFile._rootUrl}$url';
  }
  log.message('loading webfile $url');
  final uri = Uri.parse(url);
  var httpClient = http.Client();
//  late http.Request request;
  late http.Response response;
  try {
    response = await httpClient.get(uri).timeout(Duration(seconds: timeOut));
    if (response.statusCode > 399) {
      throw Exception('Response ${response.statusCode} \n ${response.body}');
    }
    log.debug('Response Code ${response.statusCode}');
  } catch (ex) {
    log.error('webfile error : $ex');
    rethrow;
  }
  WebFile result = WebFile._(url);
  if (response.statusCode != 200) {
    if (defaultValue == null) throw 'Failed to load ' + url;
    result.contents = defaultValue;
  } else {
    result.contents = response.body;
    result.bodyBytes = response.bodyBytes;
    log.message('webfile loaded ${result.bodyBytes!.length} bytes');
  }
  return result;
}

Future<bool> saveWebFile(WebFile webFile, {bool silent = true}) async {
  try {
    final uri = Uri.parse(webFile.url);
    var httpClient = http.Client();
    http.Response? response;
    try {
      if (WebFile._preserve == '')
        throw Exception('Cannot preserve ${webFile.url}');
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-type': 'application/json',
        'Preserve': '${WebFile._preserve}'
      };
      response =
          await httpClient.put(uri, headers: headers, body: webFile.contents);
    } catch (ex) {
      log.error('$ex');
      return false;
    }
    if (response.statusCode != 200) {
      throw throw 'Response ${response.statusCode} from server when putting ${webFile.url}';
    }
  } catch (ex) {
    String errMessage = 'Failed to save ${webFile.url} with reason $ex';
    log.error(errMessage);
    if (silent) {
      return false;
    } else {
      rethrow;
    }
  }
  return true;
} // of saveWebFile

Future<Uint8List> loadWebBinary(String url) async {
  WebFile webFile = await loadWebFile(url, '');
  return webFile.bodyBytes!;
} // of loadWebBinary

Future<Image?> loadWebImage(String url) async {
  var bin = await loadWebBinary(url);
  var img = decodeImage(bin);
  return img;
}

// Future<String> uploadImage3(String imageName, DateTime modifiedDate,
//     String filename, String filePath, String importSource) async {
//   try {
//     String fileDateStr =
//         formatDate(modifiedDate, format: 'yyyy:mm:dd hh:nn:ss');
//     var postUrl =
//         "${WebFile._rootUrl}upload2/$fileDateStr/$imageName/$importSource";
//     var request = http.MultipartRequest("POST", Uri.parse(postUrl));
//     request.headers.addAll(
//         {'Accept': 'application/json', 'Preserve': '${WebFile._preserve}'});
//     request.files.add(http.MultipartFile.fromBytes('myfile', fileContents,
//         contentType: MediaType('image', 'jpeg')));
//     // request.files.add(await http.MultipartFile.fromPath('myfile', filePath));
//     var response = await request.send();
//     var responseBody = await response.stream.bytesToString();
//     if (response.statusCode == 200) {
//       log.debug("Uploaded $imageName");
//       return "OK: $responseBody";
//     } else {
//       log.error(
//           'Failed to upload $imageName  - code ${response.statusCode}\n $responseBody');
//       return "Error: $imageName \n reason: $responseBody"; // signal error
//     }
//   } catch (ex, st) {
//     log.error('$ex\n$st');
//     return "Error $imageName exception \n reason: '$ex\n$st"; // signal error
//   }
// } //of uploadImageFile
