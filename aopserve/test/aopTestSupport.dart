/**
 * Created by Chris on 15/09/2018.
 */

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:test/test.dart';


const bool VERBOSE = false;
String TEST_HOST = '';

void testLog(String s) =>  VERBOSE ? print(s) : null;
class TestRequest  {
  HttpClientResponse response;
  List<String> responseText;
  dynamic responseData;

  Future<TestRequest> get(String url,{String accept:'text/plain' ,String cookie,List<int> putData}) async {
    var url2 = Uri.parse(TEST_HOST + url);
    var httpClient = HttpClient();
    HttpClientRequest request;
    if (putData == null)
      request = await httpClient.getUrl(url2);
    else {
      request = await httpClient.putUrl(url2);
      request.add(putData);
    }
    request.cookies.add(Cookie('aop',cookie));
    response = await request.close();
    responseText = await response.transform(utf8.decoder).toList();
    testLog('Response ${response.statusCode}: type ${responseText.runtimeType} $responseText');
    if (response.headers.value('content-type').contains('json')) {
      responseData = jsonDecode(responseText.join());
    } else
      responseData = null;
    httpClient.close();
    return this;
  }

  uExpectData(String key,dynamic expectedText) {
//    var actual = responseData[key];
    //  expect(actual,equals(expectedText),reason:'json key $key');
    throw 'TODO: uExpectedData method';
  } // of uExpectData

  uExpectHeader(String expectedKey,String expectedText) async {
//    print('headers: ${response.headers}');
    expect(response.headers.value(expectedKey),contains(expectedText),reason:'Header '+expectedKey );
  } // of expectHeader
  uExpectStatus(int statusCode) {
    expect(response.statusCode,statusCode,reason:'status code');
  } // of expectStatus
  uExpectText(String expectedText) {
    expect(responseText.join('\n'),contains(expectedText),reason:'expecting substring');
  } // of uExpectText
} // of TestRequest