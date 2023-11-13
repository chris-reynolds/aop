// ignore_for_file: omit_local_variable_types

/*
  Created by chrisreynolds on 2019-09-09
  
  Purpose: 

*/
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:aopcommon/aopcommon.dart';

class WebFile {
  String url;
  String contents = '';
  static String _rootUrl = ''; //'http://${config["host"]}:${config['port']}';
  static String get rootUrl => _rootUrl;
  static void setRootUrl(String rootUrl) {
    _rootUrl = rootUrl;
  }

  WebFile._(this.url); // private constructor

  static Future<bool> get hasWebServer async {
    try {
      var response = await loadWebFile('', 'blah');
      return (response.contents == 'blah');
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
    if (response.statusCode > 399)
      throw Exception('Response ${response.statusCode} \n ${response.body}');
    log.message('Response Code ${response.statusCode}');
  } catch (ex) {
    log.error('webfile error : $ex');
    rethrow;
  }
  // http.Response response =
  //     await request.close().timeout(Duration(seconds: timeOut));
//  HttpResponse responseBody = await response.transform(utf8.decoder).join();
  //   print("Received $responseBody...");
  // httpClient.close();
  WebFile result = WebFile._(url);
  if (response.statusCode != 200) {
    if (defaultValue == null) throw 'Failed to load ' + url;
    result.contents = defaultValue;
  } else {
    result.contents = response.body;
//    await utf8.decoder.bind(response.bodyBytes).forEach((String x) {
//      result.contents += x;
//    });
  }
  return result;
}

Future<bool> saveWebFile(WebFile webFile, {bool silent = true}) async {
  late HttpClientResponse response;
  try {
    final uri = Uri.parse(webFile.url);
    var httpClient = HttpClient();
    HttpClientRequest request;
    try {
      request = await httpClient.openUrl('PUT', uri);
      request.write(webFile.contents);
    } catch (ex) {
      log.error('$ex');
      return false;
    }
    response = await request.close();
    httpClient.close();
    if (response.statusCode != 200) throw response.reasonPhrase;
  } catch (ex) {
    String errMessage =
        'Failed to save ${webFile.url} with reason ${response.reasonPhrase}';
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
  if (!url.contains('http:')) {
    if (WebFile._rootUrl == '') throw Exception('No rootUrl');
    url = '${WebFile._rootUrl}{url}';
  }
  final uri = Uri.parse(url);
  var httpClient = HttpClient();
  late HttpClientRequest request;
  try {
    request = await httpClient.openUrl('GET', uri);
  } catch (ex) {
    log.error('$ex');
  }
  HttpClientResponse response = await request.close();
//  HttpResponse responseBody = await response.transform(utf8.decoder).join();
  //   print("Received $responseBody...");
  httpClient.close();
  if (response.statusCode != 200) throw 'Failed to load ' + url;
  List<int> download = <int>[];
  await response.toList().then((List<List<int>> chunks) {
    chunks.forEach((List<int> chunk) {
      download.addAll(chunk);
    });
  });
  return Uint8List.fromList(download);
} // of loadWebBinary

Future<Image?> loadWebImage(String url) async =>
    decodeImage(Uint8List.fromList(await loadWebBinary(url)));

Future<void> saveWebImage(String url,
    {Image? image, int quality = 100, String? metaData}) async {
  try {
    if (!url.contains('http:')) {
      if (WebFile._rootUrl == '') throw Exception('No rootUrl');
      url = '${WebFile._rootUrl}$url';
    }
    var postUri = Uri.parse(url);
    List<int> payLoad;
    HttpClient httpClient = HttpClient();
    var request = await httpClient.putUrl(postUri);
    if (image != null) {
      payLoad = encodeJpg(image, quality: quality);
      request.add(payLoad);
    } else if (metaData != null) {
      payLoad = utf8.encode(metaData);
      request.add(payLoad);
    }
    var response = await request.close().timeout(Duration(seconds: 20));
    bool successfulResponse = (response.statusCode == 200);
    await response.drain();
    httpClient.close();
    if (successfulResponse) {
      log.message('Uploaded $url');
    } else {
      throw Exception('Failed to upload $url with $response');
    }
    payLoad = []; // clear in case this is the memory leak
    //   response = null;
    //   httpClient = null;
  } catch (ex, st) {
    throw Exception('Failed to save web image $url with $ex \n $st');
  }
} // of httpPostImage
