
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:i18n_extension/default.i18n.dart';
import 'package:wp_frontend/api/base_api_functions.dart';
import 'package:wp_frontend/api/base_endpoint.dart';
import 'package:wp_frontend/api/shared_preferences.dart';
import 'package:wp_frontend/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:wp_frontend/resources/strings.dart';

class UserApiEndpoint extends BaseApiEndpoint {
  UserApiEndpoint({required super.API_ENDPOINT, required super.BASE_URL});

  User getUserSync(String token) {
    User _user = User(
      id: '1',
      full_name: 'John Doe',
      email: 'jo',
      disabled: false,
      avatar_url: 'https://www.gravatar.com/avatar/',
      username: 'jd',
    );

    getUserById(token).then((user) {
      if (user != null) {
        _user = user;
      }
    });

    return _user;
  }

  Future<User?> getUserById(String id) async {
    String finalUrl = "${API_ENDPOINT}id/$id";
    try {
      http.Response response = await BaseApi().apiPetition(finalUrl);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    }
    on TimeoutException catch (_) {
    return Future.error(Strings.serverTimeout.i18n);
    }
    on SocketException catch (_) {
    return Future.error(Strings.noInternet.i18n);
    }
  }

  Future<User> getUser() async {
    try {
    String finalUrl = "${API_ENDPOINT}me";

    http.Response response = await BaseApi().apiPetition(finalUrl);

    if (response.statusCode == 200) {
      User user = User.fromJson(jsonDecode(response.body));

      SharedApi.saveUser(user);

      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create album.');
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
