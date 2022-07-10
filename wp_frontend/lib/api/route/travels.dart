
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:i18n_extension/default.i18n.dart';
import 'package:wp_frontend/api/base_api_functions.dart';
import 'package:wp_frontend/api/base_endpoint.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:http/http.dart' as http;
import 'package:wp_frontend/resources/strings.dart';

class TravelApiEndpoint extends BaseApiEndpoint {
  TravelApiEndpoint({required super.API_ENDPOINT, required super.BASE_URL});

  Future<Travel> deleteTravel(Travel travel) async {
    String finalUrl = "$API_ENDPOINT${travel.id}";

    print(travel.toJson());
    try {
      http.Response response = await BaseApi().apiDeletePetition(finalUrl);


      if (response.statusCode == 200) {
        return Travel.fromJson(jsonDecode(response.body));
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

  Future<Travel> createTravel(Travel travel) async {
    String finalUrl = API_ENDPOINT;
    try {
      print(travel.toJson());

      http.Response response = await BaseApi().apiPostPetition(finalUrl, travel.toJson());

      if (response.statusCode == 200) {
        return Travel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        return Future.error(Strings.noAuthException.i18n);
      } else {
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

  Future<List<Travel>?> getTravels() async {
    String finalUrl = API_ENDPOINT;
    try {
      http.Response response = await BaseApi().apiPetition(finalUrl);

      print("Response: ${response.body} Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);

        print(dataList.length);

        List<Travel> travel = <Travel>[];

        for (int i = 0; i < dataList.length; i++) {
          travel.add(await Travel.fromJson(dataList[i]));
        }

        return travel;
      } else if (response.statusCode == 401) {
        return Future.error(Strings.noAuthException.i18n);
      } else {
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
}
