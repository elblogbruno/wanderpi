import 'dart:math';

enum WanderpiType {
  image,
  video,
  audio,
  three_sixty_image,
  three_sixty_video,
}

class Wanderpi {
  final String wanderpiId;
  final String wanderpiName;
  final WanderpiType wanderpiType;

  final double wanderpiLatitude;
  final double wanderpiLongitude;
  final String wanderpiAddress;

  final DateTime wanderpiCreationDate;
  final DateTime wanderpiLastUpdateDate;

  final String wanderpiUri;
  final String wanderpiThumbnailUri;


  Wanderpi({
    required this.wanderpiId,
    required this.wanderpiName,
    required this.wanderpiLatitude,
    required this.wanderpiLongitude,
    required this.wanderpiAddress,
    required this.wanderpiCreationDate,
    required this.wanderpiLastUpdateDate,
    required this.wanderpiType,
    required this.wanderpiUri,
    required this.wanderpiThumbnailUri,
  });

  Wanderpi.fromJson(Map<dynamic, dynamic> json)
      : wanderpiId = json['wanderpiId'],
        wanderpiName = json['wanderpiName'],
        wanderpiLatitude = json['wanderpiLatitude'],
        wanderpiLongitude = json['wanderpiLongitude'],
        wanderpiAddress = json['wanderpiAddress'],
        wanderpiCreationDate = DateTime.parse(json['wanderpiCreationDate']),
        wanderpiLastUpdateDate = DateTime.parse(json['wanderpiLastUpdateDate']),
        wanderpiType = WanderpiType.values[json['wanderpiType']],
        wanderpiUri = json['wanderpiUri'],
        wanderpiThumbnailUri = json['wanderpiThumbnailUri'];



  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'wanderpiId': wanderpiId,
    'wanderpiName': wanderpiName,
    'wanderpiLatitude': wanderpiLatitude,
    'wanderpiLongitude': wanderpiLongitude,
    'wanderpiDestinationName': wanderpiAddress,
    'wanderpiCreationDate': wanderpiCreationDate.toIso8601String(),
    'wanderpiLastUpdateDate': wanderpiLastUpdateDate.toIso8601String(),
    'wanderpiType': wanderpiType.index,
    'wanderpiUri': wanderpiUri,
    'wanderpiThumbnailUri': wanderpiThumbnailUri,
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
      wanderpiId: 'wanderpiId$i',
      wanderpiName: 'wanderpiName$i',
      wanderpiLatitude: generateRandomLatitude(),
      wanderpiLongitude: generateRandomLongitude(),
      wanderpiAddress: 'wanderpiAddress$i',
      wanderpiCreationDate: DateTime.now(),
      wanderpiLastUpdateDate: DateTime.now(),
      wanderpiType: WanderpiType.values[Random().nextInt(WanderpiType.values.length)],
      wanderpiUri: 'https://picsum.photos/seed/${i}/1920/720?random=${i}',
      wanderpiThumbnailUri: 'https://picsum.photos/seed/${i}/400/300?random=${i}',
    );
  }

  static Wanderpi getBusStop(String query, List<Wanderpi> busStops)  {
    for (Wanderpi busStop in busStops) {
      if (busStop.wanderpiId == query) {
        return busStop;
      }
    }
    return busStops.first;
  }
}