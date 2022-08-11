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

  // async function to construct a BaseModel from a json object
  static Future<BaseModel> fromJson(Map<dynamic, dynamic> json) async {
    final User? userCreatedBy = await Api.instance.userApiEndpoint().getUserById(json['user_created_by']);
    print('From JSON $userCreatedBy');

    return BaseModel(
      json['id'],
      json['name'],
      json['latitude'],
      json['longitude'],
      json['address'],
      DateTime.parse(json['creation_date']),
      DateTime.parse(json['last_update_date']),
      userCreatedBy ?? User.fromJson(json['user_created_by']),
    );
  }

  BaseModel.fromJson1(Map<dynamic, dynamic> json)
      : id = json['id'],
        name = json['name'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        address = json['address'],
        lastUpdateDate =  DateTime.parse(json['last_update_date']),
        creationDate = DateTime.parse(json['creation_date']),
        userCreatedBy = Api.instance.userApiEndpoint().getUserSync(json['user_created_by']);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'user_created_by': userCreatedBy.id,
        'last_update_date': lastUpdateDate.toIso8601String(),
        'creation_date': creationDate.toIso8601String(),
      };
}