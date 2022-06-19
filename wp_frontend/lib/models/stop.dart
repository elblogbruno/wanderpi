import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Stop {
  final String stopId;
  final String stopName;

  final double stopLatitude;
  final double stopLongitude;
  final String stopDestinationName;

  final DateTime stopCreationDate;
  final DateTime stopDateRangeStart;
  final DateTime stopDateRangeEnd;
  final String stopDescription;

  final double stopDistance;
  final double stopSpentPrice;

  final String stopThumbnailUri;
  final String stopImageUri;


  Stop({
    required this.stopId,
    required this.stopName,
    required this.stopLatitude,
    required this.stopLongitude,
    required this.stopDestinationName,
    required this.stopCreationDate,
    required this.stopDateRangeStart,
    required this.stopDateRangeEnd,
    required this.stopDescription,
    required this.stopDistance,
    required this.stopSpentPrice,
    required this.stopImageUri,
    required this.stopThumbnailUri,
  });

  Stop.fromJson(Map<dynamic, dynamic> json)
      : stopId = json['stopId'],
        stopName = json['stopName'],
        stopLatitude = json['stopLatitude'],
        stopLongitude = json['stopLongitude'],
        stopDestinationName = json['stopDestinationName'],
        stopCreationDate = DateTime.parse(json['stopCreationDate']),
        stopDateRangeStart = DateTime.parse(json['stopDateRangeStart']),
        stopDateRangeEnd = DateTime.parse(json['stopDateRangeEnd']),
        stopDescription = json['stopDescription'],
        stopDistance = json['stopDistance'],
        stopSpentPrice = json['stopSpentPrice'],
        stopImageUri = json['stopImageUri'],
        stopThumbnailUri = json['stopThumbnailUri'];


  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'stopId': stopId,
    'stopName': stopName,
    'stopLatitude': stopLatitude,
    'stopLongitude': stopLongitude,
    'stopDestinationName': stopDestinationName,
    'stopCreationDate': stopCreationDate.toIso8601String(),
    'stopDateRangeStart': stopDateRangeStart.toIso8601String(),
    'stopDateRangeEnd': stopDateRangeEnd.toIso8601String(),
    'stopDescription': stopDescription,
    'stopDistance': stopDistance,
    'stopSpentPrice': stopSpentPrice,
    'stopImageUri': stopImageUri,
    'stopThumbnailUri': stopThumbnailUri,
  };


  static Stop randomFromInt(int i, double latitude, double longitude) {
    return Stop(
      stopId: 'stopId$i',
      stopName: 'stopName$i',
      stopLatitude: latitude,
      stopLongitude:  longitude,
      stopDestinationName: 'stopDestinationName$i',
      stopCreationDate: DateTime.now(),
      stopDateRangeStart: DateTime.now().subtract(Duration(days: Random().nextInt(100))),
      stopDateRangeEnd: DateTime.now().add(Duration(days: Random().nextInt(100))),
      stopDescription: 'stopDescription$i',
      stopDistance: Random().nextDouble(),
      stopSpentPrice: Random().nextDouble(),
      stopImageUri: 'https://picsum.photos/1920/720?random=${i}',
      stopThumbnailUri: 'https://picsum.photos/400/300?random=${i}',
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
      width: 40.0,
      height: 40.0,
      point: LatLng(stopLatitude, stopLongitude),
      builder: (ctx) => Container(
        child: IconButton(
          icon: const Icon(Icons.location_on, color: Colors.red),
          color: Colors.red,
          onPressed: () {
            print("Location pressed");
            //_openOnGoogleMaps();
          },
        ),
      ),
    );
  }
}