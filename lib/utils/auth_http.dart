import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthHttp {
  static Future<http.Response> get(
      {required String url, required String apiKey}) async {
    return http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $apiKey'});
  }

  static Future<http.Response> post(
      {required String url,
      required String apiKey,
      required Map<String, dynamic> body}) async {
    return http.post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json'
        },
        body: json.encode(body));
  }
}
