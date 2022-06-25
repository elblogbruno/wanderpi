/* Creates a rounded box that holds a title and image */
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wp_frontend/api/api.dart';

import 'package:wp_frontend/const/design_globals.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/ui/bloc/card_preview.dart';
import 'package:wp_frontend/ui/utils.dart';
import 'package:wp_frontend/utils/maps/cached_tile_provider.dart';

import 'card_title_preview.dart';



class TravelCard extends StatefulWidget{
  final Travel travel;
  final Function onTap;
  final ValueChanged<Travel> onDeleteClick;
  final ValueChanged<Travel?> onSelect;
  const TravelCard({Key? key, required this.travel,  required this.onTap, required this.onDeleteClick, required this.onSelect}) : super(key: key);

  @override
  State<TravelCard> createState() => _TravelCardState();

}

class _TravelCardState extends State<TravelCard> {
  List<Marker> markers = <Marker>[];

  void initState() {
    super.initState();

    if (widget.travel.travelStops!.isNotEmpty) {
      for (int i = 0; i < widget.travel.travelStops!.length; i++) {
        markers.add(
          widget.travel.travelStops![i].toMarker(),
        );
      }
    }
  }

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
          CardTitlePreview(
            objectPreviewName: widget.travel.travelName,
            objectCreationDate: widget.travel.travelCreationDate!,
            onSelect: (bool isSelected) {
              setState(() {
                if (isSelected) {
                  widget.onSelect(widget.travel);
                }else{
                  widget.onSelect(null);
                }
              });
            },
          ),
          Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.black),
                title: Text(widget.travel.travelDestinationName, style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                ),),
              ),
              buildDivider(),
              ListTile(
                leading: const Icon(Icons.moving , color: Colors.black),
                title: Text("${widget.travel.travelDistance} km", style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                ),),
              ),
              buildDivider(),
              ListTile(
                leading: const Icon(Icons.date_range , color: Colors.black),
                title: Text("${convertDateTimeDisplay(widget.travel.travelDateRangeStart)} - ${convertDateTimeDisplay(widget.travel.travelDateRangeEnd)}", style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                ),),
              ),
              buildDivider(),
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
        buildButton(context, Icons.folder_open, "", Colors.blueAccent,  () => { widget.onTap() } ),
        //buildButton(context, Icons.account_balance_wallet, "", Colors.black),
        buildButton(context, Icons.edit, "", Colors.black, () => { widget.onTap() }),
        buildButton(context, Icons.delete, "", Colors.red, () => { widget.onDeleteClick(widget.travel) }),
      ],
    );
  }

  String convertDateTimeDisplay(DateTime date) {
    return  "${date.day}/${date.month}/${date.year}";
  }

}