import 'dart:io';

import 'package:aopserve/aopServeMain.dart';

//import 'package:angel_framework/angel_framework.dart';
//import 'package:angel_framework/http.dart';
//import 'package:file/local.dart';

const rootDir = '../testdata';

//LocalFileSystem fs = LocalFileSystem();

Future<bool> xfileDownload(String fileName,HttpResponse res) async {
  print('request $fileName');
  var file = File(fileName);
  if (!file.existsSync()) throw HttpException('not found');
//  res.addStream(file.openRead()).then((x) { res.close(); return true;});
  var fileContents = file.readAsBytesSync();
  res.add(fileContents);
//  res.download(file,filename: fileName);
  res.close();
 return true;
} // of fileDownload

void errorHandler(ex,stack) {
  print('aopServe Error: $ex \n\n\n $stack');
  exit(16);
}
void main(List<String> args)  {
    aopServerMain(args).catchError(errorHandler);
    print('aopServe launched');
} // of main

// xmain() async {
//   app.get('/', (req, res) => res.write('Hello, world!'));
//   app.get('/favicon.ico',(req,res) => fileDownload('favicon.ico',res));
//   app.get('/photos/:month/:imagename',photoHandler);
//   app.fallback((req, res) => throw HttpException.badRequest());
//   await http.startServer('localhost', 3000);
//   print('Started on ${http.server.port}');
// }

Future<bool> xphotoHandler(HttpRequest req, HttpResponse res) async {
  var fileName = '$rootDir/${req.uri.queryParameters["month"]}/${req.uri.queryParameters["imagename"]}';
  return xfileDownload(fileName, res);
} // of photoHandler




