/* Creates a rounded box that holds a title and image */
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wp_frontend/const/design_globals.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/ui/bloc/card_preview.dart';
import 'package:wp_frontend/utils/maps/cached_tile_provider.dart';



class TravelCard extends StatefulWidget{
  final Travel travel;
  final Function onTap;
  final ValueChanged<Travel?> onSelect;
  const TravelCard({Key? key, required this.travel,  required this.onTap, required this.onSelect}) : super(key: key);

  @override
  State<TravelCard> createState() => _TravelCardState();

}

class _TravelCardState extends State<TravelCard> {
  bool _isSelected = false;
  List<Marker> markers = <Marker>[];


  void initState() {
    super.initState();

    for (int i = 0; i < widget.travel.travelStops.length; i++) {
      markers.add(
        widget.travel.travelStops[i].toMarker(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = const EdgeInsets.all(10.0);

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
           CardPreview(
             latitude: widget.travel.travelLatitude,
             longitude: widget.travel.travelLongitude,
             objectPreviewName: widget.travel.travelName,
             markers: markers,
             type: CardPreviewType.map,
           ),
           buildContentInfoPart(context),
        ],
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

  Widget buildContentInfoPart(BuildContext context) {
    /* Middle part of the card that holds the title and the image  in a grey background  of the same width as the card*/
    return Container(
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Globals.radius),
          bottomRight: Radius.circular(Globals.radius),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
          <Widget>[
            Padding(padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text( widget.travel.travelName,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text( "${widget.travel.travelLatitude},${widget.travel.travelLongitude}",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          widget.travel.travelCreationDate.toString(),
                          textAlign: TextAlign.start,

                          style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Colors.black,
                            fontSize: 12,
                          ),
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

                          if (_isSelected) {
                            widget.onSelect(widget.travel);
                          }else{
                            widget.onSelect(null);
                          }

                        });
                      },
                    ),
                ],
                )

              ),
            ),
            Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.black),
                      title: Text(widget.travel.travelDestinationName, style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Colors.black,
                      ),),
                    ),

                    /*ListTile(
                      leading: const Icon(Icons.punch_clock, color: Colors.black),
                      title: Text(widget.travel.travelCreationDate.toString(), style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Colors.black,
                      ),),
                    ),*/

                    ListTile(
                      leading: const Icon(Icons.moving , color: Colors.black),
                      title: Text("${widget.travel.travelDistance} km", style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Colors.black,
                      ),),
                    ),

                    ListTile(
                      leading: const Icon(Icons.date_range , color: Colors.black),
                      title: Text("${convertDateTimeDisplay(widget.travel.travelDateRangeStart)} - ${convertDateTimeDisplay(widget.travel.travelDateRangeEnd)}", style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Colors.black,
                      ),),
                    )
                  ],
                ),
            const SizedBox(height: 10,),
            buildRowOfButtons(context),
            const SizedBox(height: 10,),

          ],
      ),
    );
  }

  Widget buildRowOfButtons(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        buildButton(context, Icons.folder_open, "", Colors.blueAccent),
        buildButton(context, Icons.account_balance_wallet, "", Colors.black),
        buildButton(context, Icons.edit, "", Colors.black),
        buildButton(context, Icons.delete, "", Colors.red),
      ],
    );
  }

  Widget buildButton(BuildContext context, IconData icon, String text, Color color){

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
        widget.onTap();
      },
    );

  }

  String convertDateTimeDisplay(DateTime date) {
    return  "${date.day}/${date.month}/${date.year}";
  }

}