import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:aopcommon/aopcommon.dart' as aopcommon;

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = 'localhost';

final Map<String, String> _headers = {'Access-Control-Allow-Origin': '*',
'Content-Type': 'text/html'};

// for OPTIONS (preflight) requests just add headers and an empty response
shelf.Response _options(shelf.Request request) => (request.method == 'OPTIONS') ?
new shelf.Response.ok(null, headers: _headers) : null;

shelf.Response _cors(shelf.Response response) => response.change(headers: _headers);

shelf.Middleware _fixCORS = shelf.createMiddleware(
    requestHandler: _options, responseHandler: _cors);
final Router router = Router();
final shelf.Handler handler = const shelf.Pipeline()
    .addMiddleware(_fixCORS)
    .addMiddleware(shelf.logRequests())
//    .addMiddleware(exceptionResponse())
    .addHandler(router.handler);

shelf.Middleware fred = shelf.createMiddleware(requestHandler: (shelf.Request request) {
  return null; //shelf.Response.forbidden("fred.txt");
});

void check(bool condition, String errorMessage) => {if (!condition) throw(errorMessage)};

void allConfigChecks(config) {

} // allConfigChecks

void main(List<String> args) async {
  int webPort, dbPort;
  try {
    check(args.isNotEmpty,'config filename required on commandline');
    check(File(args[0]).existsSync(),'config file "${args[0]}" does not exist');
    var config = await aopcommon.loadConfig(args[0]);
    check(config['fileserver_root'] != null,'"fileserver_root" is a required configuration parameter');
    check(config['webserver_hostname'] != null,'"webserver_hostname" is a required configuration parameter');
    check(config['webserver_port'] != null,'"webserver_port" is a required configuration parameter');
    check(config['dbhost'] != null,'"dbhost" is a required configuration parameter');
    check(config['dbname'] != null,'"dbname" is a required configuration parameter');
    check(config['dbuser'] != null,'"dbuser" is a required configuration parameter');
    check(config['dbpassword'] != null,'"dbpassword" is a required configuration parameter');
    check(Directory(config['fileserver_root']).existsSync(),"fileserver root not found");
    if (config['webserver_port'] is int) {
      webPort = config['webserver_port'];
    } else {
      check(webPort>0,'Invalid webserver port number');
    }
    if (config['dbport'] is int  || config['dbport'] == null) {
      dbPort = config['dbport'] ?? 3306;
    } else {
      check(dbPort>0,'Invalid webserver port number');
    }
  } catch(ex,st) {
    stdout.writeln('$ex \n $st');
    // 64: command line usage error
    exitCode = 64;
    return;
  }



  var staticHandler = createStaticHandler('.',listDirectories: true);
  Router routes = Router()
    ..get('/zzz', _echoRequest)
    ..get('/bin/.*',staticHandler)
    ..get('/a/[id]',_echoRequest)
    ..get('/.*',_finalRequest);
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
 // .addMiddleware((innerHandler) => null)
//      .addMiddleware(shelf.createMiddleware(requestHandler: staticHandler))
      .addHandler(routes.handler);

  var server = await io.serve(routes.handler, _hostname, webPort);
  print('Serving at http://${server.address.host}:${server.port}');
}

shelf.Response _echoRequest(shelf.Request request) =>
    shelf.Response.ok('Request for "${request.url}"');

shelf.Response _finalRequest(shelf.Request request) =>
    shelf.Response.ok('Final Request for "${request.url}"');

shelf.Request _securityHandler(shelf.Request request) => request;