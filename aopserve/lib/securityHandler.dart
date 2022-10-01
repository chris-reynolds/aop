/*
  Created by chrisreynolds on 3/09/20
  
  Purpose: This handles the server security for allOurPhotos

*/
import 'dart:io';
import 'package:aopcommon/aopcommon.dart';

bool securityCheck(String token) {
  return true;
//  return token.contains('F71'); // TODO: proper security check
} // of security check

String securityToken(String username, String password ) {
  int suffixHelp = 9;
  if (config['password.' + username] == password) {
    return DateTime.now().millisecondsSinceEpoch.toRadixString(13) +
        'F' +
        (8 * suffixHelp - 1).toString();
  } else {
    return ''; // failed
  }
} // of security token

Map<String,String>cookiesFromHeader(List cookieHeader ) {
  var result = <String,String>{};
  for (var cookieLine in cookieHeader) {
    var items = cookieLine.split(';');
    for (String item in items) {
      var delimPos = item.indexOf('=');
      result[item.substring(0, delimPos)] = item.substring(delimPos + 1);
    }
  }
  return result;
} // of cookiesFromHeader

Future<bool>securityHandler(HttpRequest request,Map<String,String> mask) async {
  // request cookie property not populated for some reason, so use the request header.
  var requestCookies = cookiesFromHeader(request.headers['cookie']);
  String cookieValue =
  requestCookies.length == 0 ? 'NONE' : requestCookies['aop'];
  bool permissionDenied = !securityCheck(cookieValue);
  if (permissionDenied) request.response.statusCode = HttpStatus.forbidden;
  return permissionDenied;  // true will dictate the routes are at an end
} // of securityHandler

Future<bool>sessionHandler(HttpRequest request,Map<String,String> mask) async {
  HttpResponse response = request.response;
  String newToken = mask.length >= 2 ? securityToken(mask['user'], mask['password']) : '';
  bool permissionDenied = (newToken == '');
  if (!permissionDenied) {
    response.cookies.clear();
    var cookie = Cookie('aop', newToken);
    cookie.domain = request.requestedUri.host;
    cookie.path = '/';
    cookie.maxAge = 10000000;
    response.cookies.add(cookie);
    response.statusCode = HttpStatus.accepted;
    response.write('Ready');
    return true;
  } else {
    response.cookies.clear();
    response.statusCode = HttpStatus.unauthorized;
    response.write('nope');
    return true;
  }
} // of securityHandler
