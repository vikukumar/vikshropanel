import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class WebsiteAPI {
  final String baseUrl;
  final String apiKey;

  WebsiteAPI({required this.baseUrl, required this.apiKey});

  String _md5(String input) => md5.convert(utf8.encode(input)).toString();

  /// Generate aaPanel-style auth
  Map<String, String> _auth() {
    final time = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final token = _md5(time + _md5(apiKey));
    return {
      "request_time": time,
      "request_token": token,
    };
  }

  /// Get website list
  Future<List<dynamic>> getWebsiteList() async {
    final url = Uri.parse("$baseUrl/data?action=getData&table=sites");

    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode(_auth());

    final res = await http.post(url, headers: headers, body: body);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json["data"]; // site list
    } else {
      throw Exception("Failed to load websites");
    }
  }
}
