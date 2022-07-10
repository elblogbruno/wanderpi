import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:wp_frontend/models/base_model.dart';
import 'package:wp_frontend/models/user.dart';

import 'wanderpi.dart';

class Stop extends BaseModel  {
  final DateTime stopDateRangeStart;
  final DateTime stopDateRangeEnd;
  final String stopDescription;

  final double? stopDistance;
  final double? stopSpentPrice;

  final String? stopThumbnailUrlSmall;
  final String? stopThumbnailUri;
  final String? stopImageUri;

  final String stopTravelId;
  final List<Wanderpi>? stopWanderpis;

  Stop({
    required String id,
    required String name,   // Name of the travel (e.g. "London to Paris") (required) (string) (max-size 31)
    required double latitude,
    required double longitude,
    required String  address,
    required DateTime creation_date,
    required DateTime last_update_date,
    required User user_created_by,
    required this.stopDateRangeStart,
    required this.stopDateRangeEnd,
    required this.stopDescription,
    this.stopDistance,
    this.stopSpentPrice,
    this.stopImageUri,
    this.stopThumbnailUri,
    this.stopThumbnailUrlSmall,
    required this.stopTravelId,
    this.stopWanderpis,
  }) : super(id, name, latitude, longitude, address, creation_date, last_update_date, user_created_by);

  // async function to construct a Stop from a json object calling BaseModel.fromJson()
  static Future<Stop> fromJson(Map<dynamic, dynamic> json) async {
    print('Stop.fromJson(): json: $json');
    final User? userCreatedBy = await Api().userApiEndpoint().getUserById(json['user_created_by']);

    List<Wanderpi> wanderpis = [];

    if (json['wanderpis'] != null && (json['wanderpis'] as List<dynamic>).isNotEmpty) {
      // parse stops from json as list
      print((json['wanderpis'] as List<dynamic>).length);

      wanderpis = await Future.wait((json['wanderpis'] as List<dynamic>).map((stopJson) async {
        return await Wanderpi.fromJson(stopJson);
      }).toList());
    }

    return Stop(
        id: json['id'],
        name: json['name'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        address: json['address'],
        creation_date: DateTime.parse(json['creation_date']),
        last_update_date: DateTime.parse(json['last_update_date']),
        user_created_by: userCreatedBy ?? User.notExistingUser() ,
      stopDateRangeStart: DateTime.parse(json['date_range_start']),
      stopDateRangeEnd: DateTime.parse(json['date_range_end']),
      stopDescription: json['description'],
      stopDistance: json['distance'],
      stopSpentPrice: json['spent_price'],
      stopImageUri: json['image_uri'],
      stopThumbnailUri: json['thumbnail_uri'],
      stopThumbnailUrlSmall: json['thumbnail_uri_small'],
      stopTravelId: json['travel_id'],
      stopWanderpis: wanderpis,
    );
  }

  Stop.fromJson1(Map<dynamic, dynamic> json)
      : stopDateRangeStart = DateTime.parse(json['date_range_start']),
        stopDateRangeEnd = DateTime.parse(json['date_range_end']),
        stopDescription = json['description'],
        stopDistance = json['distance'],
        stopSpentPrice = json['spent_price'],
        stopImageUri = json['image_uri'],
        stopThumbnailUri = json['thumbnail_uri'],
        stopThumbnailUrlSmall = json['thumbnail_uri_small'],
        stopTravelId = json['travel_id'],
        stopWanderpis = (json['wanderpis'] as List<dynamic>).map((e) => Wanderpi.fromJson1(e)).toList(),
        super.fromJson1(json);


  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'date_range_start': stopDateRangeStart.toIso8601String(),
    'date_range_end': stopDateRangeEnd.toIso8601String(),
    'description': stopDescription,
    'distance': stopDistance ?? 0.0,
    'spent_price': stopSpentPrice ?? 0.0,
    'image_uri': stopImageUri ?? "https://picsum.photos/1920/720?random=0",
    'thumbnail_uri': stopThumbnailUri ?? "https://picsum.photos/1920/720?random=0",
    'thumbnail_uri_small': stopThumbnailUrlSmall ?? "https://picsum.photos/1920/720?random=0",
    'travel_id': stopTravelId,
    ...super.toJson(),
  };


  static Stop randomFromInt(int i, double latitude, double longitude) {
    return Stop(
      id: "stop_${i}",
      name: "Stop ${i}",
      latitude: latitude + Random().nextDouble() * 0.01,
      longitude: longitude + Random().nextDouble() * 0.01,
      address: "Address ${i}",
      creation_date: DateTime.now(),
      last_update_date: DateTime.now(),
      user_created_by: User.notExistingUser(),
      stopDateRangeStart: DateTime.now().subtract(Duration(days: Random().nextInt(100))),
      stopDateRangeEnd: DateTime.now().add(Duration(days: Random().nextInt(100))),
      stopDescription: 'Description$i',
      stopDistance: Random().nextDouble(),
      stopSpentPrice: Random().nextDouble(),
      stopImageUri: 'https://picsum.photos/1920/720?random=$i',
      stopThumbnailUri: 'https://picsum.photos/400/300?random=$i',
      stopThumbnailUrlSmall: 'https://picsum.photos/200/100?random=$i',
      stopTravelId: '2',
    );
  }

  static Stop getBusStop(String query, List<Stop> busStops)  {
    for (Stop busStop in busStops) {
      if (busStop.id == query) {
        return busStop;
      }
    }
    return busStops.first;
  }

  Marker toMarker(){
    return Marker(
      width: 50.0,
      height: 50.0,
      point: LatLng(latitude, longitude),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(4.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(Globals.radius)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: Offset(
                0.0, // horizontal, move right 10
                0.0, // vertical, move down 10
              ),
            ),
          ],
        ),
        child:
        Image.network(
          stopThumbnailUrlSmall!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}