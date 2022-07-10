
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:i18n_extension/default.i18n.dart';
import 'package:wp_frontend/api/base_api_functions.dart';
import 'package:wp_frontend/api/base_endpoint.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:http/http.dart' as http;
import 'package:wp_frontend/models/wanderpi.dart';
import 'package:wp_frontend/resources/strings.dart';

class WanderpiApiEndpoint extends BaseApiEndpoint {

  WanderpiApiEndpoint({required super.API_ENDPOINT, required super.BASE_URL});


  Future<List<Wanderpi>> getWanderpis(Stop  stop) async {
    String finalUrl = "${BASE_URL}stops/${stop.id}/wanderpis";
    try {
      http.Response response = await BaseApi().apiPetition(finalUrl);

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);

        print(dataList.length);

        List<Wanderpi> wanderpis = <Wanderpi>[];

        for (int i = 0; i < dataList.length; i++) {
          wanderpis.add(await Wanderpi.fromJson(dataList[i]));
        }

        return wanderpis;
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

  Future<Wanderpi> deleteWanderpi(Wanderpi wanderpi) async {
    String finalUrl = "$API_ENDPOINT${wanderpi.id}";

    try {

      print(wanderpi.toJson());

      http.Response response = await BaseApi().apiDeletePetition(finalUrl);

      if (response.statusCode == 200) {
        return await Wanderpi.fromJson(jsonDecode(response.body));
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

  Future<Stop> createStop(Stop stop) async {
    String finalUrl = API_ENDPOINT;

    try{

      print(stop.toJson());

      http.Response response = await BaseApi().apiPostPetition(finalUrl, stop.toJson());

      if (response.statusCode == 200) {
        return Stop.fromJson(jsonDecode(response.body));
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