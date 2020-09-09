/*
  Created by chrisreynolds on 28/08/20
  
  Purpose: This tests the SimpleRouter

*/
import 'package:test/test.dart';
import 'package:aopserve/SimpleRouter.dart';

void main() {
  var _router = SimpleRouter();
  List<Route> routeMatch(String verb, String url) => _router.routesForUrl(verb, url.split('/'));
  int countRoutes(String verb, String url) => routeMatch(verb, url).length;

  group('Router add', () {
    setUp(() {
      _router.clear;
      _router.get('/blah/blah', (req, res) => null);
      _router.get('/:bling/blah', (req, res) => null);
    });
    test('router gets a new route', () {
      var oldCount = _router.length;
      _router.get('/blah2/blah2', (req, res) => null);
      _router.get('/bling/blang/bling', (req, res) => null);
      expect(_router.length, equals(oldCount + 2));
    });

    test('get match 1 no parameters no route', () {
      expect(_router.routesForUrl('GET', 'blah/blah'.split('/')).length, equals(0));
      expect(_router.routesForUrl('GET', '/blah/blah'.split('/')).length, equals(2));
      expect(_router.routesForUrl('PUT', '/blah/blah'.split('/')).length, equals(0));
    });
    test('any verb route', () {
      _router.any('/:blong/blong', (req, res) => null);
      expect(countRoutes('GET', '/aaa/blong'), 1);
      expect(countRoutes('PUT', '/aaa/blong'), 1);
      expect(countRoutes('POST', '/aaa/blong'), 1);
    });
  });
}
