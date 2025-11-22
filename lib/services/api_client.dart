import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// API client implementing signature from your API doc at /mnt/data/api.pdf
class ApiClient {
  final String baseUrl;
  final String apiKey;
  String? cookies;

  ApiClient({required this.baseUrl, required this.apiKey});

  String _md5(String s) => md5.convert(utf8.encode(s)).toString();

  Map<String, String> _signed(Map<String, dynamic> body) {
    final requestTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final token = _md5(requestTime + _md5(apiKey));
    final out = <String, String>{};
    body.forEach((k, v) => out[k] = v.toString());
    out['request_time'] = requestTime;
    out['request_token'] = token;
    return out;
  }

  String _join(String base, String path) {
    if (base.endsWith('/') && path.startsWith('/'))
      return base + path.substring(1);
    if (!base.endsWith('/') && !path.startsWith('/')) return base + '/' + path;
    return base + path;
  }

  Future<Map<String, dynamic>> postAction(String actionPath,
      [Map<String, dynamic>? params]) async {
    final uri = Uri.parse(_join(baseUrl, actionPath));
    final resp = await http
        .post(uri, body: _signed(params ?? {}))
        .timeout(const Duration(seconds: 20));
    cookies = resp.headers['cookies'];
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSystemTotal() =>
      postAction('/system?action=GetSystemTotal');
  Future<Map<String, dynamic>> getNetWork() =>
      postAction('/system?action=GetNetWork');
  Future<Map<String, dynamic>> getFileBody(String path) =>
      postAction('/files?action=GetFileBody', {'path': path});
  Future<Map<String, dynamic>> saveFileBody(String path, String data) =>
      postAction('/files?action=SaveFileBody', {'path': path, 'data': data});

  Future<Map<String, dynamic>> getWebsiteLists() => postAction(
      '/v2/data?action=getData&table=sites&limit=10000',
      {'table': 'sites', 'limit': 100});

  Future<Map<String, dynamic>> getPanelConfig() =>
      postAction('/v2/panel/public/get_public_config_simple');
}
