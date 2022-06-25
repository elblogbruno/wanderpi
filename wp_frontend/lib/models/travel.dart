import 'dart:math';

import 'package:wp_frontend/models/document.dart';
import 'package:wp_frontend/models/stop.dart';

class Travel {
  final String travelId;
  final String travelName; // Name of the travel (e.g. "London to Paris") (required) (string) (max-size 31)


  final double travelLatitude;
  final double travelLongitude;
  final String travelDestinationName;

  final DateTime? travelLastUpdateDate;
  final DateTime? travelCreationDate;
  final DateTime travelDateRangeStart;
  final DateTime travelDateRangeEnd;
  final String travelDescription;

  final double? travelDistance;
  final double? travelSpentPrice;

  final List<Stop>? travelStops;
  final List<Document>? travelDocuments;

  Travel({
    required this.travelId,
    required this.travelName,
    required this.travelLatitude,
    required this.travelLongitude,
    required this.travelDestinationName,
    this.travelCreationDate,
    this.travelLastUpdateDate,
    required this.travelDateRangeStart,
    required this.travelDateRangeEnd,
    required this.travelDescription,
    this.travelDistance,
    this.travelSpentPrice,
    this.travelStops,
    this.travelDocuments,
  });

  Travel.fromJson(Map<dynamic, dynamic> json)
      : travelId = json['id'],
        travelName = json['name'],
        travelLatitude = json['latitude'],
        travelLongitude = json['longitude'],
        travelDestinationName = json['address'],
        travelLastUpdateDate =  DateTime.parse(json['last_update_date']),
        travelCreationDate = DateTime.parse(json['creation_date']),
        travelDateRangeStart = DateTime.parse(json['date_range_start']),
        travelDateRangeEnd = DateTime.parse(json['date_range_end']),
        travelDescription = json['description'],
        travelDistance = json['distance'],
        travelSpentPrice = json['spent_price'],
        travelStops = (json['stops'] as List<dynamic>).map((e) => Stop.fromJson(e)).toList(),
        travelDocuments = (json['documents'] as List<dynamic>).map((e) => Document.fromJson(e)).toList();



  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'id': travelId,
        'name': travelName,
        'latitude': travelLatitude,
        'longitude': travelLongitude,
        'address': travelDestinationName,
        'last_update_date': travelLastUpdateDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'creation_date': travelCreationDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'date_range_start': travelDateRangeStart.toIso8601String(),
        'date_range_end': travelDateRangeEnd.toIso8601String(),
        'description': travelDescription,
        'distance': travelDistance ?? 0.0,
        'spent_price': travelSpentPrice ?? 0.0,
        'stops': travelStops ?? [],
        'documents': travelDocuments ?? [],

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
      documents.add(Document.randomFromInt(j, 'name$i'));
    }

    return Travel(
      travelId: 'id$i',
      travelName: 'name$i',
      travelLatitude: latitude,
      travelLongitude: longitude,
      travelDestinationName: 'DestinationName$i',
      travelCreationDate: DateTime.now(),
      travelDateRangeStart: DateTime.now().subtract(Duration(days: Random().nextInt(100))),
      travelDateRangeEnd: DateTime.now().add(Duration(days: Random().nextInt(100))),
      travelDescription: 'Description$i',
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