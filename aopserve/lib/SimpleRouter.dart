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
  bool selfClosing = false;
  Route(this.verb, this.route, this.handler, {this.selfClosing =false});

  Map<String, String>? matches(String aVerb, List<String> url) {
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
  SimpleRouteHandler? onNoMatch;
  SimpleRouteHandler? onException;
  SimpleRouteHandler? onFinal;

  Future<bool> closeResponse (HttpRequest req, Map<String, String> mask) async {
    HttpResponse res = req.response;
    res.cookies.addAll(req.cookies);
    print('cookie length = ${res.cookies.length}');
    res.close();
    return true;
  }

  SimpleRouter addRoute(String verb, String url, SimpleRouteHandler handler,{selfClosing:false}) {
    _routes.add(Route(verb, url.split('/'), handler,selfClosing: selfClosing));
    return this;
  }

  SimpleRouter any(String url, SimpleRouteHandler handler,{selfClosing:false}) => addRoute('ANY', url, handler,selfClosing: selfClosing);

  SimpleRouter get(String url, SimpleRouteHandler handler,{selfClosing:false}) => addRoute('GET', url, handler,selfClosing: selfClosing);

  SimpleRouter head(String url, SimpleRouteHandler handler,{selfClosing:false}) => addRoute('HEAD', url, handler,selfClosing: selfClosing);

  SimpleRouter put(String url, SimpleRouteHandler handler,{selfClosing:false}) => addRoute('PUT', url, handler,selfClosing: selfClosing);

  SimpleRouter post(String url, SimpleRouteHandler handler,{selfClosing:false}) => addRoute('POST', url, handler,selfClosing: selfClosing);

  SimpleRouter delete(String url, SimpleRouteHandler handler,{selfClosing:false}) => addRoute('DELETE', url, handler,selfClosing: selfClosing);

  int get length => _routes.length;

  void get clear => _routes = [];

  List<Route> routesForUrl(String verb, List<String> url) =>
      _routes.where((route) => route.matches(verb, url) != null).toList();

  Future<bool> execute(HttpRequest req) async {
    bool _selfClosing = false;
    try {
      var done = false;
      for (var route in _routes) {
        var mask = route.matches(req.method, req.uri.pathSegments);
        if (mask != null) {
          print('try route ${route.route}');
          done = await route.execute(req, mask);
          if (done) {
            done = true;
            _selfClosing = route.selfClosing; // route should close itself later
            break;
          }
        }
      }
      if (!done && onNoMatch !=null) {
        return await onNoMatch(req,{});
      }
    } catch (ex, stack) {
      if (onException != null) await onException(req, {'Error': ex.toString(), 'Stack': stack.toString()});
      return false;
    } finally {
      if (onFinal != null)
        return await onFinal(req, {});
      else  if (_selfClosing)
        return true;
      else
        return await closeResponse(req, {});
    } // of try
    return true;
  } // of execute

} // of SimpleRouter
