import 'package:flutter/material.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:wp_frontend/models/base_model.dart';

Widget buildButton(BuildContext context, IconData icon, String text, Color color, Function onPressed){

  return IconButton(
    icon:  Icon(icon),
    iconSize: 30,
    color: color,
    highlightColor: Colors.red,
    hoverColor: Colors.green,
    focusColor: Colors.purple,
    splashColor: Colors.yellow,
    disabledColor: Colors.amber,
    onPressed: () {
      onPressed();
    },
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

String convertDateTimeDisplay(DateTime date) {
  return  "${date.day}/${date.month}/${date.year}";
}


InputDecoration getInputDecoration(String labelText, {String hintText = '', IconData? icon = Icons.location_on}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Globals.radius),
    ),
    icon: Icon(icon),
  );
}

bool arrayDifferent(List<BaseModel> a, List<BaseModel> b) {
  if (a.length != b.length) {
    return true;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i].name != b[i].name) {
      return true;
    }
  }
  return false;
}