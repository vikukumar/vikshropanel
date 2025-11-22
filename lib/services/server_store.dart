import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/server.dart';
import 'package:uuid/uuid.dart';

class ServerStore {
  static const _serversKey = 'vikshro_servers';
  final _secure = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<Server>> getServers() async {
    await init();
    final raw = _prefs!.getStringList(_serversKey) ?? [];
    return raw.map((r) => Server.fromJson(jsonDecode(r))).toList();
  }

  Future<void> addServer(
      {required String name,
      required String baseUrl,
      required String apiKey}) async {
    await init();
    final id = const Uuid().v4();
    final s = Server(id: id, name: name, baseUrl: baseUrl);
    final list = _prefs!.getStringList(_serversKey) ?? [];
    list.add(jsonEncode(s.toJson()));
    await _prefs!.setStringList(_serversKey, list);
    await _secure.write(key: 'api_$id', value: apiKey);
  }

  Future<String?> getApiKey(String id) => _secure.read(key: 'api_$id');

  Future<void> deleteServer(String id) async {
    await init();
    final list = _prefs!.getStringList(_serversKey) ?? [];
    list.removeWhere((r) => Server.fromJson(jsonDecode(r)).id == id);
    await _prefs!.setStringList(_serversKey, list);
    await _secure.delete(key: 'api_$id');
  }
}
