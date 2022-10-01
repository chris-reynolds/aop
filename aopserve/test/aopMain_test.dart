//import 'dart:convert';
//import 'dart:async';
import 'package:test/test.dart';
import '../lib/aopServeMain.dart' as aopServe;
import 'aopTestSupport.dart';
//import 'package:test_api/src/backend/invoker.dart' as Fred;


void main() {
  setUp(() async {
    aopServe.aopServerMain(['testConfig.json']);
    TEST_HOST = 'http://localhost:5555';
    print('Test host is $TEST_HOST');
  });

  tearDown(() async {
   // print('teardown ');
    await aopServe.mainServer.close(force: true);
    aopServe.mainServer = null;
  });
  group('temp',(){
    login();
    logout();
  });

  group('No Login',(){
    test('should not see root ',()=>ensurePermissionDenied('/'));
    test('should not see folder ',()=>ensurePermissionDenied('/photos/2017-08'));
    test('should not see bad folder ',()=>ensurePermissionDenied('/photos/2017-08'));
    test('should not see good file ',()=>ensurePermissionDenied('/photos/2004-04/105_0565.JPG'));
    test('should not see bad file ',()=>ensurePermissionDenied('/photos/2017-08/badfile.jpeg'));
  });
  group('aopServer-', () {
    test('fail on no login ',  () async {
      var tr = TestRequest();
      var tr2 = await tr.get('/');
      tr2.uExpectHeader('content-type','text/plain');
 //     tr2.uExpectText('Not Found');
//    ..uExpectData(length,4)
      tr2.uExpectStatus(401);
    });
    test('should not see root ',  () async {
      var tr = TestRequest();
      var tr2 = await tr.get('/');
      tr2.uExpectHeader('content-type','text/plain');
      tr2.uExpectText('Permission Denied');
//    ..uExpectData(length,4)
      tr2.uExpectStatus(401);
    });
    test('should not see folder ',  () async {
      var tr = TestRequest();
      await tr.get('/2017-08')
        ..uExpectHeader('content-type','text/html')
        ..uExpectText('Not Found')
//    ..uExpectData(length,4)
        ..uExpectStatus(404);
    });
    test('can fail softly for bad folder ',  () async {
      var tr = TestRequest();
      await tr.get('/badname')
        ..uExpectStatus(404);
    });
    test('can fail softly for bad file ',  () async {
      var tr = TestRequest();
      await tr.get('/2017-08/badname.jpg')
        ..uExpectStatus(404);
    });
    test('can fail softly for bad folder and file ',  () async {
      var tr = TestRequest();
      await tr.get('/badname/badname.json')
        ..uExpectText('Not Found')
        ..uExpectStatus(404);
    });
    test('post file ',  () async {
      var tr = TestRequest();
      await tr.get('/2011-11/badname.jpg',accept:'text/html',putData:[1,2,4,8])
        ..uExpectText('Written /2011-11/badname.jpg')
        ..uExpectStatus(200);
    });
  },timeout: Timeout(Duration(seconds: 5)));
}
 void ensurePermissionDenied(String url) async {
   var tr = TestRequest();
   var tr2 = await tr.get(url);
   tr2.uExpectHeader('content-type','text/plain');
   tr2.uExpectText('Permission Denied');
//    ..uExpectData(length,4)
   tr2.uExpectStatus(401);
 }

 void login()  {
   test('login',() async {
     var tr = TestRequest();
     var tr2 = await tr.get('/located/chris/temp');
     tr2.uExpectHeader('content-type','text/plain');
     tr2.uExpectText('Ready');
//    ..uExpectData(length,4)
     tr2.uExpectStatus(202);  // HttpStatus.accepted
   });
 }
 void logout() async {
   test('logout',() async {
     var tr = TestRequest();
     var tr2 = await tr.get('/located/chris/badpassword');
     tr2.uExpectHeader('content-type','text/plain');
     tr2.uExpectText('nope');
//    ..uExpectData(length,4)
     tr2.uExpectStatus(401);  // HttpStatus.unauthorized
   });
 }

