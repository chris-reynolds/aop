/*
  Created by chris reynolds on 28/08/20
  
  Purpose: This provides a simple way of attaching router handlers to routes

*/
import 'dart:async';
import 'dart:io';

typedef FutureOr<bool> SimpleRouteHandler(HttpRequest req, Map<String, String> mask);

class Route {
  String verb;
  List<String> route;
  SimpleRouteHandler handler;

  Route(this.verb, this.route, this.handler);

  Map<String, String> matches(String aVerb, List<String> url) {
    if (aVerb != verb && verb != 'ANY') return null; // verb doesn't match
    if (route[0] == '*' && route.length == 1) return {}; // match everything
    if (route.length != url.length) return null; // match nothing
    var result = <String, String>{};
    for (int i = 0; i < route.length; i++) {
      var bit = route[i];
      if (bit.startsWith(':')) {
        result[bit.substring(1)] = url[i];
      } else if (bit != url[i]) return null; // do not match one of the segments
    }
    return result;
  } // of matches

  FutureOr<bool> execute(HttpRequest req, Map<String, String> mask) async {
//    req.uri.queryParameters.addAll(pathVariables);
    return await handler(req, mask) ?? false;
  } // of execute
} // of _Handler

class SimpleRouter {
  var _routes = <Route>[];
  SimpleRouteHandler onNoMatch;
  SimpleRouteHandler onException;
  SimpleRouteHandler onFinal;

  SimpleRouter addRoute(String verb, String url, SimpleRouteHandler handler) {
    _routes.add(Route(verb, url.split('/'), handler));
    return this;
  }

  SimpleRouter any(String url, SimpleRouteHandler handler) => addRoute('ANY', url, handler);

  SimpleRouter get(String url, SimpleRouteHandler handler) => addRoute('GET', url, handler);

  SimpleRouter head(String url, SimpleRouteHandler handler) => addRoute('HEAD', url, handler);

  SimpleRouter put(String url, SimpleRouteHandler handler) => addRoute('PUT', url, handler);

  SimpleRouter post(String url, SimpleRouteHandler handler) => addRoute('POST', url, handler);

  SimpleRouter delete(String url, SimpleRouteHandler handler) => addRoute('DELETE', url, handler);

  int get length => _routes.length;

  void get clear => _routes = [];

  List<Route> routesForUrl(String verb, List<String> url) =>
      _routes.where((route) => route.matches(verb, url) != null).toList();

  Future<bool> execute(HttpRequest req) async {
    //   var routes = routesForUrl(req.method, req.uri.pathSegments);
    try {
      var done = false;
      for (var route in _routes) {
        var mask = route.matches(req.method, req.uri.pathSegments);
        if (mask != null) {
          print('try route ${route.route}');
          if (await route.execute(req, mask)) {
            print('completed on ${route.route}');
            done = true;
            break;
          }
        }
      }
      if (!done && onNoMatch !=null) {
        await onNoMatch(req,{});
      }
    } catch (ex, stack) {
      if (onException != null) await onException(req, {'Error': ex.toString(), 'Stack': stack.toString()});
      return false;
    } finally {
      if (onFinal != null) await onFinal(req, {});
    } // of try
    return true;
  } // of execute

} // of SimpleRouter
