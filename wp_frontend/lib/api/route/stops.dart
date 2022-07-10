
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:i18n_extension/default.i18n.dart';
import 'package:wp_frontend/api/base_api_functions.dart';
import 'package:wp_frontend/api/base_endpoint.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:http/http.dart' as http;
import 'package:wp_frontend/resources/strings.dart';

class StopApiEndpoint extends BaseApiEndpoint {

  StopApiEndpoint({required super.API_ENDPOINT, required super.BASE_URL});


  Future<List<Stop>> getStops(Travel travel) async {
    String finalUrl = "${BASE_URL}travels/${travel.id}/stops";
    try {
    http.Response response = await BaseApi().apiPetition(finalUrl);

    if (response.statusCode == 200) {
      final List<dynamic> dataList = jsonDecode(response.body);

      print(dataList.length);

      List<Stop> stops = <Stop>[];

      for (int i = 0; i < dataList.length; i++) {
        stops.add(await Stop.fromJson(dataList[i]));
      }

      return stops;
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

  Future<Stop> deleteStop(Stop stop) async {
    String finalUrl = "$API_ENDPOINT${stop.id}";

    try {

    print(stop.toJson());

    http.Response response = await BaseApi().apiDeletePetition(finalUrl);

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