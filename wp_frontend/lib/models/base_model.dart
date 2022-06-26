import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/models/user.dart';

class BaseModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime creationDate;
  final DateTime lastUpdateDate;

  final User userCreatedBy;

  BaseModel(
     this.id,
     this.name,
     this.latitude,
     this.longitude,
     this.address,
     this.creationDate,
     this.lastUpdateDate,
     this.userCreatedBy
  );


  BaseModel.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        name = json['name'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        address = json['address'],
        lastUpdateDate =  DateTime.parse(json['last_update_date']),
        creationDate = DateTime.parse(json['creation_date']),
        userCreatedBy = Api().getUserSync(json['user_created_by']) ?? User(
          full_name: 'John Doe',
          email: 'jo',
          disabled: false,
          avatar_url: 'https://randomuser.me/api/portraits',
          username: 'jd',
        );

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'user_created_by': userCreatedBy,
        'last_update_date': lastUpdateDate.toIso8601String(),
        'creation_date': creationDate.toIso8601String(),
      };
}