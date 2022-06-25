import 'dart:math';

import 'package:wp_frontend/models/document.dart';
import 'package:wp_frontend/models/stop.dart';

class Token {
  final String access_token;
  final String token_type;

  Token({
    required this.access_token,
    required this.token_type,
  });

  Token.fromJson(Map<dynamic, dynamic> json)
      : access_token = json['access_token'],
        token_type = json['token_type'];



  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'access_token': access_token,
    'token_type': token_type,
  };


}