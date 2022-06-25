import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wp_frontend/const/design_globals.dart';

class Stop {
  final String stopId;
  final String stopName;

  final double stopLatitude;
  final double stopLongitude;
  final String stopDestinationName;

  final DateTime? stopLastUpdateDate;
  final DateTime? stopCreationDate;
  final DateTime stopDateRangeStart;
  final DateTime stopDateRangeEnd;
  final String stopDescription;

  final double? stopDistance;
  final double? stopSpentPrice;

  final String? stopThumbnailUrlSmall;
  final String? stopThumbnailUri;
  final String? stopImageUri;

  final String stopTravelId;

  Stop({
    required this.stopId,
    required this.stopName,
    required this.stopLatitude,
    required this.stopLongitude,
    required this.stopDestinationName,
    this.stopLastUpdateDate,
    this.stopCreationDate,
    required this.stopDateRangeStart,
    required this.stopDateRangeEnd,
    required this.stopDescription,
    this.stopDistance,
    this.stopSpentPrice,
    this.stopImageUri,
    this.stopThumbnailUri,
    this.stopThumbnailUrlSmall,
    required this.stopTravelId
  });

  Stop.fromJson(Map<dynamic, dynamic> json)
      : stopId = json['id'],
        stopName = json['name'],
        stopLatitude = json['latitude'],
        stopLongitude = json['longitude'],
        stopDestinationName = json['address'],
        stopLastUpdateDate = DateTime.parse(json['last_update_date']),
        stopCreationDate = DateTime.parse(json['creation_date']),
        stopDateRangeStart = DateTime.parse(json['date_range_start']),
        stopDateRangeEnd = DateTime.parse(json['date_range_end']),
        stopDescription = json['description'],
        stopDistance = json['distance'],
        stopSpentPrice = json['spent_price'],
        stopImageUri = json['image_uri'],
        stopThumbnailUri = json['thumbnail_uri'],
        stopThumbnailUrlSmall = json['thumbnail_uri_small'],
        stopTravelId = json['travel_id'];


  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'id': stopId,
    'name': stopName,
    'latitude': stopLatitude,
    'longitude': stopLongitude,
    'address': stopDestinationName,
    'last_update_date': stopLastUpdateDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    'creation_date': stopCreationDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    'date_range_start': stopDateRangeStart.toIso8601String(),
    'date_range_end': stopDateRangeEnd.toIso8601String(),
    'description': stopDescription,
    'distance': stopDistance ?? 0.0,
    'spent_price': stopSpentPrice ?? 0.0,
    'image_uri': stopImageUri ?? "https://picsum.photos/1920/720?random=0",
    'thumbnail_uri': stopThumbnailUri ?? "https://picsum.photos/1920/720?random=0",
    'thumbnail_uri_small': stopThumbnailUrlSmall ?? "https://picsum.photos/1920/720?random=0",
    'travel_id': stopTravelId
  };


  static Stop randomFromInt(int i, double latitude, double longitude) {
    return Stop(
      stopId: 'Id$i',
      stopName: 'Name$i',
      stopLatitude: latitude,
      stopLongitude:  longitude,
      stopDestinationName: 'DestinationName$i',
      stopCreationDate: DateTime.now(),
      stopDateRangeStart: DateTime.now().subtract(Duration(days: Random().nextInt(100))),
      stopDateRangeEnd: DateTime.now().add(Duration(days: Random().nextInt(100))),
      stopDescription: 'Description$i',
      stopDistance: Random().nextDouble(),
      stopSpentPrice: Random().nextDouble(),
      stopImageUri: 'https://picsum.photos/1920/720?random=$i',
      stopThumbnailUri: 'https://picsum.photos/400/300?random=$i',
      stopThumbnailUrlSmall: 'https://picsum.photos/200/100?random=$i',
      stopTravelId: '2',
        stopLastUpdateDate: DateTime.now(),
    );
  }

  static Stop getBusStop(String query, List<Stop> busStops)  {
    for (Stop busStop in busStops) {
      if (busStop.stopId == query) {
        return busStop;
      }
    }
    return busStops.first;
  }

  Marker toMarker(){
    return Marker(
      width: 50.0,
      height: 50.0,
      point: LatLng(stopLatitude, stopLongitude),
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