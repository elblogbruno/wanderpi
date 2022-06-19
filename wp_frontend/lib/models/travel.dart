import 'dart:math';

import 'package:wp_frontend/models/document.dart';
import 'package:wp_frontend/models/stop.dart';

class Travel {
  final String travelId;
  final String travelName;


  final double travelLatitude;
  final double travelLongitude;
  final String travelDestinationName;

  final DateTime travelCreationDate;
  final DateTime travelDateRangeStart;
  final DateTime travelDateRangeEnd;
  final String travelDescription;

  final double travelDistance;
  final double travelSpentPrice;

  final List<Stop> travelStops;
  final List<Document> travelDocuments;

  Travel({
    required this.travelId,
    required this.travelName,
    required this.travelLatitude,
    required this.travelLongitude,
    required this.travelDestinationName,
    required this.travelCreationDate,
    required this.travelDateRangeStart,
    required this.travelDateRangeEnd,
    required this.travelDescription,
    required this.travelDistance,
    required this.travelSpentPrice,
    required this.travelStops,
    required this.travelDocuments,
  });

  Travel.fromJson(Map<dynamic, dynamic> json)
      : travelId = json['travelId'],
        travelName = json['travelName'],
        travelLatitude = json['travelLatitude'],
        travelLongitude = json['travelLongitude'],
        travelDestinationName = json['travelDestinationName'],
        travelCreationDate = DateTime.parse(json['travelCreationDate']),
        travelDateRangeStart = DateTime.parse(json['travelDateRangeStart']),
        travelDateRangeEnd = DateTime.parse(json['travelDateRangeEnd']),
        travelDescription = json['travelDescription'],
        travelDistance = json['travelDistance'],
        travelSpentPrice = json['travelSpentPrice'],
        travelStops = (json['travelStops'] as List<dynamic>).map((e) => Stop.fromJson(e)).toList(),
        travelDocuments = (json['travelDocuments'] as List<dynamic>).map((e) => Document.fromJson(e)).toList();



  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'travelId': travelId,
        'travelName': travelName,
        'travelLatitude': travelLatitude,
        'travelLongitude': travelLongitude,
        'travelDestinationName': travelDestinationName,
        'travelCreationDate': travelCreationDate.toIso8601String(),
        'travelDateRangeStart': travelDateRangeStart.toIso8601String(),
        'travelDateRangeEnd': travelDateRangeEnd.toIso8601String(),
        'travelDescription': travelDescription,
        'travelDistance': travelDistance,
        'travelSpentPrice': travelSpentPrice,
        'travelStops': travelStops,
        'travelDocuments': travelDocuments,
  };

  //final random = Random();

  // generate random latitude and longitude
  static double generateRandomLatitude() {
    return -90 + Random().nextDouble() * 90 * 2;
  }

  static double generateRandomLongitude() {
    return  -180 + Random().nextDouble() * 180 * 2;
  }

  static Travel randomFromInt(int i) {

    double latitude = generateRandomLatitude();
    double longitude = generateRandomLongitude();

    List<Stop> stops = <Stop>[];
    List<Document> documents = <Document>[];

    for (int j = 0; j < Random().nextInt(30); j++) {
      print('Stop $j');
      stops.add(Stop.randomFromInt(j, latitude, longitude));
      documents.add(Document.randomFromInt(j, 'travelName$i'));
    }

    return Travel(
      travelId: 'travelId$i',
      travelName: 'travelName$i',
      travelLatitude: latitude,
      travelLongitude: longitude,
      travelDestinationName: 'travelDestinationName$i',
      travelCreationDate: DateTime.now(),
      travelDateRangeStart: DateTime.now().subtract(Duration(days: Random().nextInt(100))),
      travelDateRangeEnd: DateTime.now().add(Duration(days: Random().nextInt(100))),
      travelDescription: 'travelDescription$i',
      travelDistance: Random().nextDouble(),
      travelSpentPrice: Random().nextDouble(),
      travelStops: stops,
      travelDocuments: documents,
    );
  }

  static Travel getBusStop(String query, List<Travel> busStops)  {
    for (Travel busStop in busStops) {
      if (busStop.travelId == query) {
        return busStop;
      }
    }
    return busStops.first;
  }
}