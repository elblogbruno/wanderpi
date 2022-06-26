import 'dart:math';
import 'dart:ui';

import 'package:wp_frontend/models/base_model.dart';
import 'package:wp_frontend/models/document.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/user.dart';

class Travel extends BaseModel {
  final DateTime travelDateRangeStart;
  final DateTime travelDateRangeEnd;
  final String travelDescription;

  final double? travelDistance;
  final double? travelSpentPrice;

  final List<Stop>? travelStops;
  final List<Document>? travelDocuments;

  Travel({
    required String id,
    required String name,   // Name of the travel (e.g. "London to Paris") (required) (string) (max-size 31)
    required double latitude,
    required double longitude,
    required String  address,
    required DateTime creation_date,
    required DateTime last_update_date,
    required User user_created_by,
    required this.travelDateRangeStart,
    required this.travelDateRangeEnd,
    required this.travelDescription,
    this.travelDistance,
    this.travelSpentPrice,
    this.travelStops,
    this.travelDocuments,
  }) : super(id, name, latitude, longitude, address, creation_date, last_update_date, user_created_by);

  Travel.fromJson(Map<dynamic, dynamic> json)
      : travelDateRangeStart = DateTime.parse(json['date_range_start']),
        travelDateRangeEnd = DateTime.parse(json['date_range_end']),
        travelDescription = json['description'],
        travelDistance = json['distance'],
        travelSpentPrice = json['spent_price'],
        travelStops = (json['stops'] as List<dynamic>).map((e) => Stop.fromJson(e)).toList(),
        travelDocuments = (json['documents'] as List<dynamic>).map((e) => Document.fromJson(e)).toList(),
        super.fromJson(json);



  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'date_range_start': travelDateRangeStart.toIso8601String(),
        'date_range_end': travelDateRangeEnd.toIso8601String(),
        'description': travelDescription,
        'distance': travelDistance ?? 0.0,
        'spent_price': travelSpentPrice ?? 0.0,
        'stops': travelStops ?? [],
        'documents': travelDocuments ?? [],
        ...super.toJson(),
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

    User user = User(
      username: 'dd',
          email: 'dd',
      full_name: 'ddd',
      disabled: false, avatar_url: 'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50?s=200',
    );

    return Travel(
      id: 'id$i',
      name: 'name$i',
      latitude: latitude,
      longitude: longitude,
      address: 'DestinationName$i',
      creation_date: DateTime.now(),
      last_update_date: DateTime.now(),
      user_created_by: user,
      travelDateRangeStart: DateTime.now().subtract(Duration(days: Random().nextInt(100))),
      travelDateRangeEnd: DateTime.now().add(Duration(days: Random().nextInt(100))),
      travelDescription: 'Description$i',
      travelDistance: Random().nextDouble(),
      travelSpentPrice: Random().nextDouble(),
      travelStops: stops,
      travelDocuments: documents,

    );
  }

}