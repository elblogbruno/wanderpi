class User {
  final String username;
  final String email;
  final String full_name;
  final String avatar_url;
  final bool disabled;

  User({
    required this.username,
    required this.email,
    required this.full_name,
    required this.avatar_url,
    required this.disabled,
  });

  User.fromJson(Map<dynamic, dynamic> json)
      :  username = json['username'],
         email = json['email'],
         full_name = json['full_name'],
          avatar_url = json['avatar_url'],
         disabled = json['disabled'];



  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'username': username,
        'email': email,
        'full_name': full_name,
        'avatar_url': avatar_url,
        'disabled': disabled,
      };


}