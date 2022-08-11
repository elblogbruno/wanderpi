
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:i18n_extension/default.i18n.dart';
import 'package:wp_frontend/api/base_api_functions.dart';
import 'package:wp_frontend/api/base_endpoint.dart';
import 'package:wp_frontend/api/shared_preferences.dart';
import 'package:wp_frontend/models/token.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:wp_frontend/models/user.dart';
import 'package:wp_frontend/resources/strings.dart';

class AuthApiEndpoint extends BaseApiEndpoint {
  AuthApiEndpoint({required super.API_ENDPOINT, required super.BASE_URL});

  Future<User?> validateToken(String token) async {
    String finalUrl = "${API_ENDPOINT}validate_token";
    Token tokenObj = Token(access_token: token, token_type: "Bearer");

    try {
      http.Response response = await BaseApi().apiPostPetition(
          finalUrl, tokenObj.toJson(), needs_auth: false);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      else if (response.statusCode == 401) {
        print("Error: ${response.body}");
        return Future.error(Strings.noAuthException.i18n, StackTrace.current);
      }

      return Future.error(Strings.noInternet.i18n, StackTrace.current);
    }
    on TimeoutException catch (_) {
      return Future.error(Strings.serverTimeout.i18n, StackTrace.current);
    }
    on SocketException catch (_) {
      return Future.error(Strings.noInternet.i18n, StackTrace.current);
    }
  }

  Future<Token> login(String username, String password) async {
    try{
    Uri url = Uri.parse(API_ENDPOINT);

    // remove last slash if exists
    if (url.path.endsWith("/")) {
      url = url.replace(path: url.path.substring(0, url.path.length - 1));
    }

    print(username);
    print(password);

    final http.Response response = await http.post(url,
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
        'grant_type': 'password',
        'scope': '',
        'client_id': '',
        'client_secret': '',
      },
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      // check if response is token or error
      Token token = Token.fromJson(jsonDecode(response.body));

      SharedApi.saveToken(token);

      return token;
    } else {
      throw Exception(jsonDecode(response.body)["detail"]);
    }

    }
    on TimeoutException catch (_) {
      return Future.error(Strings.serverTimeout.i18n);
    }
    on SocketException catch (_) {
      return Future.error(Strings.noInternet.i18n);
    }
  }

  Future<Token> logout() async {
    try{
    String finalUrl = "${API_ENDPOINT}logout";

    Uri url = Uri.parse(finalUrl);

    print(finalUrl);

    final http.Response response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      Token token = Token.fromJson(jsonDecode(response.body));
      SharedApi.deleteToken();
      SharedApi.deleteUser();

      return token;
    } else {
      throw Exception(jsonDecode(response.body)["detail"]);
    }
    }
    on TimeoutException catch (_) {
      return Future.error(Strings.serverTimeout.i18n);
    }
    on SocketException catch (_) {
      return Future.error(Strings.noInternet.i18n);
    }
  }

  Future<User?> register(String username, String password, String email, String full_name) async {
    try{
      String finalUrl = "${API_ENDPOINT}register";

      // json dictionary to send
      Map<String, dynamic> json = {
        "username": username,
        "password": password,
        "email": email,
        "full_name": full_name,
      };

      http.Response response = await BaseApi().apiPostPetition(
            finalUrl, json, needs_auth: false);

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        // check if response is token or error
        User user = User.fromJson(jsonDecode(response.body));

        SharedApi.saveUser(user);

        return user;
      } else {
        throw Exception(jsonDecode(response.body)["detail"]);
      }
    }
    on TimeoutException catch (_) {
      return Future.error(Strings.serverTimeout.i18n);
    }
    on SocketException catch (_) {
      return Future.error(Strings.noInternet.i18n);
    }
  }

  Future<User> uploadProfilePicture(String user_id, String path, String imageType) async {
    try{
      String finalUrl = "${API_ENDPOINT}upload_profile_picture";

      // create multipart request
      var request = http.MultipartRequest("POST", Uri.parse(finalUrl));

      request.headers['user_id'] = user_id;

      request.files.add(await http.MultipartFile.fromPath('uploaded_file', path,
          contentType: MediaType('image', imageType)));

      // send request
      var streamedResponse = await request.send();

      print(streamedResponse.statusCode);

      var response = await http.Response.fromStream(streamedResponse);
      print(response.body);

      if (response.statusCode == 200) {
        // check if response is token or error
        User user = User.fromJson(jsonDecode(response.body));

        SharedApi.saveUser(user);

        return user;
      } else {
        throw Exception(jsonDecode(response.body)["detail"]);
      }
    }
    on TimeoutException catch (_) {
      return Future.error(Strings.serverTimeout.i18n);
    }
    on SocketException catch (_) {
      return Future.error(Strings.noInternet.i18n);
    }
  }
}