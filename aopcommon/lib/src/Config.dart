/// Config cmap using localstorage

import 'package:localstorage/localstorage.dart';

class Config {
  Map<String, dynamic> _map = {};
  bool dirty = false;

  late LocalStorage _storage;
  Iterable<String> get keys => _map.keys;

  void clear() => _map.clear();

  dynamic remove(Object? key) => _map.remove(key);

  dynamic operator [](Object? key) => _map[key];

  operator []=(Object key, dynamic value) {
    if (_map[key] == value) return;
    _map[key as String] = value;
    dirty = true;
  }

  void addAll(Map<String, dynamic> values) => _map.addAll(values);

  Future init(String skey) async {
    _storage = LocalStorage(skey);
    _map = _storage.getItem('config');
  }

  Future save() async {
    await _storage.setItem('config', _map);
  }

  Map<String, dynamic> values() => _map;
} // of Config class

Config config = Config();
