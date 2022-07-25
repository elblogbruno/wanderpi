import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:i18n_extension/default.i18n.dart';
import 'package:wp_frontend/api/shared_preferences.dart';
import 'package:wp_frontend/resources/strings.dart';
import 'package:http/http.dart' as http;

class BaseApi {
  static const int TIMEOUT_TIME = 5;

  Future<String> get API_BASE_URL async {
    String? apiEndpoint =  await SharedApi.getServerUri();

    if (apiEndpoint!.isEmpty) {
      return Future.error(Strings.noServerUrlAvailable);
    } else {
      return apiEndpoint;
    }
  }

  Future<http.Response> apiDeletePetition(String url) async {
      Uri uri = Uri.parse(url);

      String? token = await SharedApi.getToken();

      if (token == null) {
        return Future.error(Strings.noAuthException.i18n);
      }

      Map<String, String>? headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };

      print("Headers: $headers");

      final http.Response response = await http.delete(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        return Future.error(Strings.noAuthException.i18n);
      } else {
        return Future.error(Strings.noInternet.i18n);
      }
  }

  Future<http.Response> apiPetition(String finalUrl) async {
    Uri url = Uri.parse(finalUrl);
    print("Final url: $url");

    String? token = await SharedApi.getToken();

    if (token == null) {
      return Future.error(Strings.noAuthException.i18n);
    }

    print("Token: $token");

    Map<String, String>? headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    print("Headers: $headers");

    return http.get(url,
        headers: headers).timeout(
      const Duration(seconds: TIMEOUT_TIME),
    );
  }

  Future<http.Response> apiPostPetition(String finalUrl, Object? body,
      {bool needs_auth = true}) async {
    Uri url = Uri.parse(finalUrl);
    print("Final get_mind_structure: $url");

    String? token = await SharedApi.getToken();

    if (token == null) {
      return Future.error(Strings.noAuthException.i18n);
    }

    Map<String, String>? headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (needs_auth) {
      headers['Authorization'] = 'Bearer $token';
    }

    print("Headers: $headers");

    http.Response response = await http.post(url,
        headers: headers, body: jsonEncode(body)).timeout(
      const Duration(seconds: TIMEOUT_TIME),
    );

    print("Response: ${response.body}");

    return response;
  }

}