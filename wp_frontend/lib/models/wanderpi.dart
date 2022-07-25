import 'dart:math';

import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/models/base_model.dart';
import 'package:wp_frontend/models/user.dart';

enum WanderpiType {
  image,
  video,
  audio,
  three_sixty_image,
  three_sixty_video,
}

class Wanderpi extends BaseModel {
  final WanderpiType wanderpiType;
  final String wanderpiUri;
  final String wanderpiThumbnailUri;
  final String wanderpiUsersDetected;


  Wanderpi({
    required String id,
    required String name,   // Name of the travel (e.g. "London to Paris") (required) (string) (max-size 31)
    required double latitude,
    required double longitude,
    required String  address,
    required DateTime creation_date,
    required DateTime last_update_date,
    required User user_created_by,
    required this.wanderpiType,
    required this.wanderpiUri,
    required this.wanderpiThumbnailUri,
    required this.wanderpiUsersDetected,
  }) : super(id, name, latitude, longitude, address, creation_date, last_update_date, user_created_by);

  // async function to construct a Stop from a json object calling BaseModel.fromJson()
  static Future<Wanderpi> fromJson(Map<dynamic, dynamic> json) async {
    print('Wanderpi.fromJson(): json: $json');
    final User? userCreatedBy = await Api.instance.userApiEndpoint().getUserById(json['user_created_by']);

    String usersDetected = 'No users detected';
    print('Wanderpi.fromJson(): json["users_detected"]: ${json['users_detected']}');

    if (json['users_detected'] != null) {
      print('Wanderpi.fromJson(): json["users_detected"].length: ${json['users_detected'].length}');
      usersDetected = json['users_detected'].toString();
    }

    // wanderpi type is text or image or video or three_sixty_image or three_sixty_video.
    // Find the index in WanderpiType enum  that matches the string in the json object.
    // If not found, return null.
    print('Wanderpi.fromJson(): json["type"]: ${json['type']}');

    //WanderpiType wanderpiType = WanderpiType.values.firstWhere((WanderpiType type) => type.toString() == json['type'].toString(), orElse: () => WanderpiType.image);
    WanderpiType wanderpiType = WanderpiType.values.firstWhere((WanderpiType type) => type.name.toString() == json['type'].toString());


    return Wanderpi(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      creation_date: DateTime.parse(json['creation_date']),
      last_update_date: DateTime.parse(json['last_update_date']),
      user_created_by: userCreatedBy ?? User.notExistingUser() ,
      wanderpiUsersDetected: usersDetected,
      wanderpiType: wanderpiType,
      wanderpiUri: json['uri'],
      wanderpiThumbnailUri: json['thumbnail_uri'],
    );
  }

  Wanderpi.fromJson1(Map<dynamic, dynamic> json)
      : wanderpiType = WanderpiType.values[json['wanderpiType']],
        wanderpiUri = json['wanderpiUri'],
        wanderpiThumbnailUri = json['wanderpiThumbnailUri'],
        wanderpiUsersDetected = json['wanderpiUsersDetected'],
        super.fromJson1(json);



  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'wanderpiType': wanderpiType.index,
    'wanderpiUri': wanderpiUri,
    'wanderpiThumbnailUri': wanderpiThumbnailUri,
    ...super.toJson(),
  };

  // generate random latitude and longitude
  static double generateRandomLatitude() {
    return Random().nextDouble() * (90 - -90) + -90;
  }

  static double generateRandomLongitude() {
    return Random().nextDouble() * (180 - -180) + -180;
  }

  static Wanderpi randomFromInt(int i) {
    return Wanderpi(
      id: '${i}',
      name: 'Wanderpi ${i}',
      latitude: generateRandomLatitude(),
      longitude: generateRandomLongitude(),
      address: 'Address ${i}',
      creation_date: DateTime.now(),
      last_update_date: DateTime.now(),
      user_created_by: User.notExistingUser(),
      wanderpiType: WanderpiType.values[Random().nextInt(WanderpiType.values.length)],
      wanderpiUri: 'https://picsum.photos/seed/${i}/1920/720?random=${i}',
      wanderpiThumbnailUri: 'https://picsum.photos/seed/${i}/400/300?random=${i}',
        wanderpiUsersDetected: '${i}',
    );
  }

  static Wanderpi getBusStop(String query, List<Wanderpi> busStops)  {
    for (Wanderpi busStop in busStops) {
      if (busStop.id == query) {
        return busStop;
      }
    }
    return busStops.first;
  }
}