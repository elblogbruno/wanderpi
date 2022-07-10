/* Base design of stateful widgets */
/* builds a widget for error handling */
import 'package:flutter/material.dart';

class BaseDesign extends StatelessWidget {
  final Color color;
  final Color textColor;

  final Widget child;

  BaseDesign({required this.color, required this.child, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle( style:  TextStyle(fontSize: 36, color: textColor)  ,
        child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: child ,
            ),
    ));
  }
}