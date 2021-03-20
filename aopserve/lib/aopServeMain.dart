/*
  Created by chrisreynolds on 30/08/20
  
  Purpose: This is the main server logic for the AllOurPhotos server

*/
import 'dart:io';
import 'dart:async';
import 'dart:convert' show jsonDecode, utf8;
import 'package:http_server/http_server.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path/path.dart' as path;
import 'package:aopcommon/aopcommon.dart';
import 'FileServer.dart';
import 'SimpleRouter.dart';
import 'photoMetadataHandler.dart';
import 'package:aopserve/db/dbAllOurPhotos.dart';
import 'securityHandler.dart';

String VERSION = '2020.09.01';
HttpServer mainServer;
VirtualDirectory _staticFileRoot;
SimpleRouter _router = SimpleRouter();
bool closedown = false;
DbAllOurPhotos fred = DbAllOurPhotos();
FileServer _fileServer;

Future<void> aopServerMain(List<String> args) async {
  if (args.isEmpty)  throw 'Invalid Usage: aopServer configFileName';
  mainServer = await setupServer(args);
  await for (HttpRequest request in mainServer) {
    await _router.execute(request);
    if (closedown) break;
  }
}
Future<HttpServer> setupServer(List<String> args) async {
  await loadConfig(args[0]);
  int webServerPort = int.tryParse(config['webserver_port']??'8888') ?? 8888;
  _staticFileRoot = VirtualDirectory(config['fileserver_root'],pathPrefix: 'photos');
  _fileServer = FileServer(config['fileserver_root']);
//  await fred.initConnection(config);
  mainServer = await HttpServer.bind(
    InternetAddress.anyIPv6,
    webServerPort,
  );

  _router
    ..get('located/:user/:password',sessionHandler)
    ..get('favicon.ico', (req,mask) => true)
    ..addRoute('ANY', '*', securityHandler)  // everything goes through trhe security handler first
    ..get('photos/:month/:image', photoGetHandler)
    ..put('photos/:month/:image', photoPutHandler)
    ..post('photos/:month/:image', photoPostHandler)
    ..get('exif/:month/:image', photoMetadataHandler)
    ..get('quitt',quitHandler)
    ..onException = exceptionHandler
    //..onNoMatch = (req,res)=> processRequest(req);  // old style handler
    ..onNoMatch = (req,mask)=>plainResponse(req.response,HttpStatus.notFound,'$mask not found');

  print('AOP Server: $VERSION running on ${mainServer.port}');
  return mainServer;
} // of setupServer




String get slash => Platform.pathSeparator;
String localFileName(Map<String,String> mask) {
  return _staticFileRoot.root + slash + mask['month'] + slash + mask['image'];
}


bool plainResponse(HttpResponse response,int thisStatusCode, String text) {
  response
    ..statusCode = thisStatusCode
    ..headers.contentType = ContentType('text', 'plain')
    ..write(text);
  response.close();
  return true;
} // of plainResponse

Future<bool> processRequest(HttpRequest request) async {
  print('processRequest ------  ${request.method} request for ${request.uri.path}');
  final response = request.response;


  String cookieValue =
  response.cookies.length == 0 ? 'NONE' : response.cookies[0].value;
  bool permissionDenied = securityCheck(cookieValue);
  List<String> bits = request.uri.path.split('/');
  if (request.method == 'GET') {
    if (request.uri.path.length > 8 &&
        request.uri.path.substring(0, 8) == '/located') {
      String newToken = bits.length == 4 ? securityToken(bits[2], bits[3]) : '';
      permissionDenied = (newToken == '');
      if (!permissionDenied) {
        response.cookies.clear();
        response.cookies.add(Cookie('aop', newToken));
        plainResponse(response, HttpStatus.accepted, 'Ready');
      }
    }
    if (request.uri.path == '/quit') {
      response
        ..headers.contentType = ContentType('text', 'plain')
        ..write('Goodbytttte from the server');
      response.close();
      closedown = true;
    } else if (permissionDenied) {
      // failed security check
      response
        ..statusCode = HttpStatus.unauthorized
        ..headers.contentType = ContentType('text', 'plain')
        ..write('Permission Denied');
      response.close();
    } else if (bits[1].toLowerCase() == 'exif') {
      bits.removeAt(1);
      String pictureFile = config['fileserver_root'] + bits.join('/');
      if (File(pictureFile).existsSync()) {
        // now extract the exif data
        plainResponse(response, HttpStatus.accepted, await extractExiff(pictureFile));
      } else
        plainResponse(response, HttpStatus.notFound, '$pictureFile not found');
    } else {
      await _staticFileRoot.serveRequest(request);
    }
  } else if (request.method == 'PUT') {
    String filePath = config['fileserver_root'] + request.uri.toFilePath();
    HttpRequestBody body = await HttpBodyHandler.processRequest(
      request,
    );
    if (body.type == 'binary') {
      try {
// force the existence of the directory on the server
        String dirName = path.dirname(filePath);
        if (!Directory(dirName).existsSync()) {
          Directory(dirName).createSync(recursive: true);
          print('Creating directory $dirName');
        }
        File(filePath).writeAsBytesSync(body.body, flush: true);
        plainResponse(response,
            200, 'Written ${request.uri.path} with ${body.body.length}');
      } catch (ex) {
        print('Exception on PUT : $ex');
        plainResponse(response, HttpStatus.internalServerError, 'Failed to write $filePath \n $ex');
      } // of catch
    } else
      plainResponse(response, HttpStatus.badRequest, 'Todo put non-binary $filePath');
  } else
    plainResponse(response,
        HttpStatus.methodNotAllowed, 'Invalid method${request.method}');
} // of process request

Future<bool>exceptionHandler(HttpRequest request,Map<String,String> mask) async {
  plainResponse(request.response,
      HttpStatus.internalServerError, 'Exception :${mask["Error"]}\n${mask["Stack"]}');
} // of exceptionHandler

Future<bool>photoGetHandler(HttpRequest request,Map<String,String> mask) async {
  File pictureFile = File(localFileName(mask));
  if (pictureFile.existsSync()) {
    await _staticFileRoot.serveRequest( request);
  } else {
    plainResponse(request.response, HttpStatus.notFound, '${localFileName(mask)} not found');
  }
  return true;
} // of Handler

Future<bool> photoMetadataHandler(HttpRequest req, mask) async {
  String pictureFileName = localFileName(mask);
  if (File(pictureFileName).existsSync()) {
    var exifData = await extractExiff(pictureFileName);
    plainResponse(req.response, HttpStatus.accepted, exifData);
  } else {
    plainResponse(req.response, HttpStatus.notFound, '$pictureFileName not found');
  }
  return true;
} // of photoMetadataHandler

Future<bool>photoPutHandler(HttpRequest request,Map<String,String> mask) async {

} // of photoPutHandler

Future<bool>photoPostHandler(HttpRequest request,Map<String,String> mask) async {

} // of photoPostHandler

Future<bool>quitHandler(HttpRequest request,Map<String,String> mask) async {
  request.response
    ..headers.contentType = ContentType('text', 'plain')
    ..write('Goodbyee from the server');
  request.response.close();
  closedown = true;   // remote closedown
} // of quitHandler

/*  blank handler for code copying
Future<bool>Handler(HttpRequest request,HttpResponse response) {

} // of Handler
*/
