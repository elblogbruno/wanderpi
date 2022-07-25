
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:i18n_extension/default.i18n.dart';
import 'package:wp_frontend/api/base_api_functions.dart';
import 'package:wp_frontend/api/base_endpoint.dart';
import 'package:wp_frontend/models/drive.dart';
import 'package:wp_frontend/models/drive.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:http/http.dart' as http;
import 'package:wp_frontend/models/drive.dart';
import 'package:wp_frontend/resources/strings.dart';

class DrivesApiEndpoint extends BaseApiEndpoint {

  DrivesApiEndpoint({required super.API_ENDPOINT, required super.BASE_URL});


  Future<List<Drive>> getDrives() async {
    String finalUrl = "${BASE_URL}drives";
    try {
      http.Response response = await BaseApi().apiPetition(finalUrl);

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);

        print(dataList.length);

        List<Drive> drives = <Drive>[];

        for (int i = 0; i < dataList.length; i++) {
          drives.add(Drive.fromJson(dataList[i]));
        }

        return drives;
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

  Future<Drive> deleteDrive(Drive drive) async {
    String finalUrl = "$API_ENDPOINT${drive.memoryId}";

    try {

      print(drive.toJson());

      http.Response response = await BaseApi().apiDeletePetition(finalUrl);

      if (response.statusCode == 200) {
        return Drive.fromJson(jsonDecode(response.body));
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

  Future<Drive> createDrive(Drive drive) async {
    String finalUrl = API_ENDPOINT;

    try{

      print(drive.toJson());

      http.Response response = await BaseApi().apiPostPetition(finalUrl, drive.toJson());

      if (response.statusCode == 200) {
        return Drive.fromJson(jsonDecode(response.body));
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