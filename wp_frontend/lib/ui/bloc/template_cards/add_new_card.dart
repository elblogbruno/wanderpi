import 'package:wp_frontend/const/design_globals.dart';
import 'package:flutter/material.dart';


class AddMoreCard extends StatefulWidget{
  final Function onTap;
  final String objectToAdd;
  const AddMoreCard({Key? key, required this.onTap, required this.objectToAdd}) : super(key: key);

  @override
  State<AddMoreCard> createState() => _AddMoreCardState();

}

class _AddMoreCardState extends State<AddMoreCard> {
  @override
  Widget build(BuildContext context) {
    /* Card that holds the image and text and has bottom buttons*/
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Globals.radius),
      ),
      child: Column(
        // direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('No ${widget.objectToAdd} available. Please add a new ${widget.objectToAdd} to start having fun'),

          RaisedButton(
            onPressed: () { widget.onTap(); },
          ),
        ],
      ),
    );
  }


}