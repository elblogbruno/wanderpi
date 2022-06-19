import 'package:flutter/material.dart';

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
