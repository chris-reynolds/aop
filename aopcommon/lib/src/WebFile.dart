/*
  Created by chrisreynolds on 2019-09-09
  
  Purpose: 

*/
import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart';
import 'package:aopcommon/aopcommon.dart';

String get rootUrl => 'http://${config["dbhost"]}:3333';

class WebFile {
  String url;
  String contents = '';

  WebFile._(this.url); // private constructor
}

Future<WebFile> loadWebFile(String url, String defaultValue) async {
  if (!url.contains('http:')) url = rootUrl + '/' + url;
  final uri = Uri.parse(url);
  var httpClient = HttpClient();
  HttpClientRequest request;
  try {
    request = await httpClient.openUrl('GET', uri);
  } catch (ex) {
    log.error(ex);
  }
  HttpClientResponse response = await request.close();
//  HttpResponse responseBody = await response.transform(utf8.decoder).join();
  //   print("Received $responseBody...");
  httpClient.close();
  WebFile result = WebFile._(url);
  if (response.statusCode != 200) {
    if (defaultValue == null) throw 'Failed to load ' + url;
    result.contents = defaultValue;
  } else
    await utf8.decoder.bind(response).forEach((x) {
      result.contents += x;
    });
  return result;
}

Future<bool> saveWebFile(WebFile webFile, {bool silent = true}) async {
  HttpClientResponse response;
  try {
    final uri = Uri.parse(webFile.url);
    var httpClient = HttpClient();
    HttpClientRequest request;
    try {
      request = await httpClient.openUrl('PUT', uri);
      request.write(webFile.contents);
    } catch (ex) {
      log.error(ex);
      return false;
    }
    response = await request.close();
    httpClient.close();
    if (response.statusCode != 200) throw response.reasonPhrase;
  } catch (ex) {
    String errMessage = 'Failed to save ${webFile.url} with reason ${response.reasonPhrase}';
    log.error(errMessage);
    if (silent)
      return false;
    else
      rethrow;
  }
  return true;
} // of saveWebFile

Future<List<int>> loadWebBinary(String url) async {
  if (!url.contains('http:')) url = rootUrl + '/' + url;
  final uri = Uri.parse(url);
  var httpClient = HttpClient();
  HttpClientRequest request;
  try {
    request = await httpClient.openUrl('GET', uri);
  } catch (ex) {
    log.error(ex);
  }
  HttpClientResponse response = await request.close();
//  HttpResponse responseBody = await response.transform(utf8.decoder).join();
  //   print("Received $responseBody...");
  httpClient.close();
  if (response.statusCode != 200) throw 'Failed to load ' + url;
  List<int> download = [];
  await response.toList().then((chunks) {
    chunks.forEach((chunk) {
      download.addAll(chunk);
    });
  });
  return download;
} // of loadWebBinary

Future<Image> loadWebImage(String url) async => decodeImage(await loadWebBinary(url));
//Future<Image> loadWebImage(String url) async {
//  if (!url.contains('http:')) url = rootUrl + '/' + url;
//  final uri = Uri.parse(url);
//  var httpClient = HttpClient();
//  HttpClientRequest request;
//  try {
//    request = await httpClient.openUrl('GET', uri);
//  } catch (ex) {
//    log.error(ex);
//  }
//  HttpClientResponse response = await request.close();
////  HttpResponse responseBody = await response.transform(utf8.decoder).join();
//  //   print("Received $responseBody...");
//  httpClient.close();
//  if (response.statusCode != 200) throw 'Failed to load ' + url;
//  List<int> download = [];
//  await response.toList().then((chunks) {
//    chunks.forEach((chunk) {
//      download.addAll(chunk);
//    });
//  });
//  Image result = decodeImage(download);
//  return result;
//}

Future<void> saveWebImage(String urlString,
    {Image image, int quality = 100, String metaData}) async {
  var postUri = Uri.parse(urlString);
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
    var response = await request.close();
    bool successfulResponse = (response.statusCode == 200);
    await response.drain();
    await httpClient.close();
    if (successfulResponse)
      log.message("Uploaded $urlString");
    else
      throw Exception('Failed to upload $urlString with $response');
  payLoad = [];  // clear in case this is the memory leak
  response = null;
  httpClient = null;
} // of httpPostImage
