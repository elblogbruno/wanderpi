import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:wp_frontend/models/user.dart';
import 'package:wp_frontend/ui/bar/corner_profile_picture.dart';



class CardPeoplePreview extends StatelessWidget {

  final List<User> users;
  final ValueChanged<User> onSelect;

  const CardPeoplePreview({Key? key, required this.users, required this.onSelect}) : super(key: key);

  // bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return buildPreview();
  }

  Widget buildDivider() {
    return  const SizedBox(
      height: 0,
      width: 35,
      child: Divider(
        color: Colors.black,
        thickness: 1.0,
      ),
    );
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.black;
  }

  Widget buildPreview() {

    List<Widget> _users = [];

    for (int i = 0; i < users.length; i++) {
      print(users[i].id);


      _users.add(
        GestureDetector(
          onTap: () {
            onSelect(users[i]);
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                CornerProfilePicture(
                    userAvatarUrl: users[i].avatar_url,
                    radius: i == 0 ? 20 : 15),
                // CircleAvatar(
                //   backgroundImage: NetworkImage(users[i].avatar_url),
                //   radius: i == 0 ? 20 : 15,
                // ),
                const SizedBox(
                  width: 5,
                ),
                AutoSizeText(
                  users[i].full_name,
                  maxLines: 1,
                  minFontSize: i == 0 ? 20 : 15,
                  style: TextStyle(
                    fontSize:  i == 0 ? 20 : 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(Globals.radius),
          ),
          alignment: Alignment.center,
          width: 400,
          height: 50 * users.length + 15 * (users.length - 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children : _users,
          ),
        ),
    );
  }






}