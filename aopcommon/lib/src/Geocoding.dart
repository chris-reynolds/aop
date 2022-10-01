///
/// Created by Chris on 8/10/2018.
/// Purpose: To reverse geocode from camera latitude/longitude to displayable name
///
// ignore_for_file: omit_local_variable_types

import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'Logger.dart';

class GeocodingSession {
  static const String _host =
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&zoom=14';
  static double calcSign(String direction, double magnitude) {
    if (direction == null) {
      return magnitude;
    }
    return ('SsWw'.contains(direction)) ? -magnitude : magnitude;
  } // of calcSign

  final double _tileSizeKms = 5.0;
  String _calcKey(double longitude, double latitude) {
    double latDegree = 111.0;
    double longDegree = 111.0 * cos(latitude * pi / 180);
    int latTiles = (latitude * latDegree / _tileSizeKms).round();
    int longTiles = (longitude * longDegree / _tileSizeKms).round();
    log.message('Geo-key $longTiles:$latTiles for ($longitude,$latitude');
    return '$longTiles:$latTiles';
  } // of _calcKey

  final Map<String, String> _cache = <String,String>{};

  int get length => _cache.length;

  Future<String> getLocation(double longitude, double latitude) async {
    final String key = _calcKey(longitude, latitude);
    if (_cache[key] == null) {
      String newLocation = await urlLookupFromCoordinates(latitude, longitude);
      _cache[key] = newLocation;
    }
    return _cache[key];
  } // of getLocation

  String removeDiacritics(String str) {
    String withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽžĀāĒēĪīŌōŪūþ';
    String withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZzAaEeIiOoUup';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  } // of removeDiacritics


  void setLocation(double longitude, double latitude, String location) {
    final String key = _calcKey(longitude, latitude);
    _cache[key] = location;
  } // of setLocation

  Future<String> urlLookupFromCoordinates(
      double latitude, double longitude) async {
    final String url = '$_host&lat=$latitude&lon=$longitude';
    log.message('Sending $url...');
    final Uri uri = Uri.parse(url);
    HttpClient httpClient = HttpClient();
    HttpClientRequest request;
    try {
      request = await httpClient.openUrl('GET', uri);
    } catch (ex) {
      log.error(ex);
    }
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    //   print("Received $responseBody...");
    Map<String,dynamic> data = jsonDecode(responseBody);
    httpClient.close();
    String result = data['display_name'];
    if (result != null) {
      return removeDiacritics(result);
    } else {
      log.error('Bad geolocation response $data');
      return null;
    }
  } // of urlLookupFromCoordinates

} // of GeocodingSession
