import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:latlong2/latlong.dart';


class CardTitlePreview extends StatefulWidget{

  final String objectPreviewName;
  final DateTime objectCreationDate;

  final ValueChanged<bool> onSelect;

  const CardTitlePreview({Key? key, required this.objectPreviewName,required this.objectCreationDate, required this.onSelect}) : super(key: key);

  @override
  State<CardTitlePreview> createState() => _CardTitlePreviewState();

}

class _CardTitlePreviewState extends State<CardTitlePreview> {
  bool _isSelected = false;

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
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  AutoSizeText(widget.objectPreviewName,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    minFontSize: 15,
                    maxFontSize: 25,
                  ),
                  AutoSizeText(
                    widget.objectCreationDate.toString(),
                    textAlign: TextAlign.start,

                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    maxFontSize: 15,
                  ),

                ],
              ),
              Checkbox(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Globals.radius),
                ),
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith(getColor),
                value: _isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    _isSelected = value!;
                    print("_isSelected: $_isSelected");
                    widget.onSelect(_isSelected);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }






}