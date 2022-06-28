import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:wp_frontend/api/shared_preferences.dart';
import 'package:wp_frontend/locales/main.i18n.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/token.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:http/http.dart' as http;
import 'package:wp_frontend/models/user.dart';
import 'package:wp_frontend/resources/strings.dart';

class Api {
  static const int TIMEOUT_TIME = 5;

  static const String API_ENDPOINT = "http://127.0.0.1:8000/";

  Future<bool> validateToken(String token) async {
    String finalUrl = "${API_ENDPOINT}token/validate_token";

    /*String json = {
      "token": token
    }.toString();*/

    Token tokenObj = Token(access_token: token, token_type: "Bearer");

    Uri url = Uri.parse(finalUrl);

    Map<String, String>? headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    http.Response response = await http.post(url, headers:headers, body: jsonEncode(tokenObj.toJson())).timeout(
      const Duration(seconds: TIMEOUT_TIME),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Travel> deleteTravel(Travel travel) async {
    String finalUrl = "${API_ENDPOINT}travels/${travel.id}";

    print(travel.toJson());

    http.Response  response =  await apiDeletePetition(finalUrl);

    if (response.statusCode == 200) {
      return Travel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create album.');
    }
  }

  Future<Travel> createTravel(Travel travel) async {
    String finalUrl = "${API_ENDPOINT}travels/";

    print(travel.toJson());

    http.Response  response =  await apiPostPetition(finalUrl, travel.toJson());

    if (response.statusCode == 200) {
      return Travel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      return Future.error(Strings.noAuthException.i18n);
    } else {
      return Future.error(Strings.noInternet.i18n);
    }
  }

  Future<List<Travel>?> getTravels() async {
    String finalUrl = "${API_ENDPOINT}travels/";

    http.Response  response =  await apiPetition(finalUrl);

    print("Response: ${response.body} Status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List<dynamic> dataList = jsonDecode(response.body);

      print(dataList.length);

      List<Travel> travel = <Travel>[];

      for (int i = 0; i < dataList.length; i++) {
        travel.add(Travel.fromJson(dataList[i]));
      }

      return travel;

    }else if (response.statusCode == 401) {
      return Future.error(Strings.noAuthException.i18n);
    } else {
      return Future.error(Strings.noInternet.i18n);
    }
  }



  Future<Stop> deleteStop(Stop stop) async {
    String finalUrl = "${API_ENDPOINT}stops/${stop.stopId}";

    //Uri url = Uri.parse(finalUrl);

    print(stop.toJson());

    http.Response  response =  await apiDeletePetition(finalUrl);

    /*final http.Response response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print(response.body);*/

    if (response.statusCode == 200) {
      return Stop.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create album.');
    }
  }

  Future<Stop> createStop(Stop stop) async {
    String finalUrl = "${API_ENDPOINT}stops/";

    //Uri url = Uri.parse(finalUrl);

    print(stop.toJson());

    http.Response  response =  await apiPostPetition(finalUrl, stop.toJson());

    /*final http.Response response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(stop.toJson()),
    );

    print(response.body);*/

    if (response.statusCode == 200) {
      return Stop.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create album.');
    }
  }

  User? getUserSync(String token) {
    getUserById(token).then((user) {
      if (user != null) {
        return user;
      }
    });

    return null;
  }

  Future<User?> getUserById(String id) async {
    String finalUrl = "${API_ENDPOINT}users/id/$id";

    http.Response  response =  await apiPetition(finalUrl);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<User> getUser() async {
    String finalUrl = "${API_ENDPOINT}users/me";

    http.Response  response =  await apiPetition(finalUrl);

    if (response.statusCode == 200) {
      User user = User.fromJson(jsonDecode(response.body));

      SharedApi.saveUser(user);

      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create album.');
    }
  }

  Future<Token> login(String username, String password) async {
    String finalUrl = "${API_ENDPOINT}token";

    Uri url = Uri.parse(finalUrl);

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


    if (response.statusCode == 200) {
      // check if response is token or error
      Token token = Token.fromJson(jsonDecode(response.body));

      SharedApi.saveToken(token);

      return token;
    } else {
      throw Exception(jsonDecode(response.body)["detail"]);
    }
  }

  Future<Token> logout () async {
    String finalUrl = "${API_ENDPOINT}token/logout";

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


  Future<http.Response> apiDeletePetition(String url) async {
    try {
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
        headers:  headers,
      );

      if (response.statusCode == 200) {
        return response;
      } else if(response.statusCode == 401) {
        return Future.error(Strings.noAuthException.i18n);
      }  else {
        return Future.error(Strings.noInternet.i18n);
      }

    }
    on TimeoutException catch (_) {
      return Future.error(Strings.serverTimeout.i18n);
    }
    on SocketException catch (_) {
      return Future.error(Strings.noInternet.i18n);
    }
  }

  Future<http.Response> apiPetition(String finalUrl) async {
    try {
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
    on TimeoutException catch (_) {
      return Future.error(Strings.serverTimeout.i18n);
    }
    on SocketException catch (_) {
      return Future.error(Strings.noInternet.i18n);
    }
  }

  Future<http.Response> apiPostPetition(String finalUrl, Object? body) async {
    try {
      Uri url = Uri.parse(finalUrl);
      print("Final get_mind_structure: $url");

      String? token = await SharedApi.getToken();

      if (token == null) {
        return Future.error(Strings.noAuthException.i18n);
      }

      Map<String, String>? headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };

      print("Headers: $headers");

      http.Response response = await http.post(url,
          headers: headers, body: jsonEncode(body)).timeout(
        const Duration(seconds: TIMEOUT_TIME),
      );

      print("Response: ${response.body}");

      return response;
    }
    on TimeoutException catch (_) {
      return Future.error(Strings.serverTimeout.i18n);
    }
    on SocketException catch (_) {
      return Future.error(Strings.noInternet.i18n);
    }
  }
}