import 'package:wp_frontend/api/api.dart';
import 'package:path/path.dart';

class User {
  final String username;
  final String email;
  final String full_name;
  final String avatar_url;
  final String id;
  final bool disabled;

  User({
    required this.username,
    required this.email,
    required this.full_name,
    required this.avatar_url,
    required this.disabled,
    required this.id,
  });

  User.fromJson(Map<dynamic, dynamic> json)
      :  username = json['username'],
         email = json['email'],
         full_name = json['full_name'],
          avatar_url = json['avatar_url'],
         disabled = json['disabled'],
          id = json['id'];

  static User notExistingUser() {
    return User(
      username: '',
      email: '',
      full_name: '',
      avatar_url: '',
      disabled: false,
      id: '',
    );
  }

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'username': username,
        'email': email,
        'full_name': full_name,
        'avatar_url': avatar_url,
        'disabled': disabled,
        'id': id,
      };


}