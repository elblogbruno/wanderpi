/* Creates a rounded box that holds a title and image */
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:wp_frontend/const/design_globals.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/models/wanderpi.dart';
import 'package:wp_frontend/ui/bloc/card_title_preview.dart';
import 'package:wp_frontend/ui/utils.dart';
import 'package:wp_frontend/utils/maps/cached_tile_provider.dart';



class WanderpiCard extends StatefulWidget{
  final Wanderpi wanderpi;
  final Function onTap;
  final ValueChanged<Wanderpi?> onSelect;
  const WanderpiCard({Key? key, required this.wanderpi,  required this.onTap, required this.onSelect}) : super(key: key);

  @override
  State<WanderpiCard> createState() => _WanderpiCardState();

}

class _WanderpiCardState extends State<WanderpiCard> {
  bool _isSelected = false;

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
          buildTravelMapPreview(context),
          buildContentInfoPart(context),

        ],
      ),
    );
  }

  Widget buildTravelMapPreview(BuildContext context){
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10.0),
      decoration: const
      BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Globals.radius),
          topRight: Radius.circular(Globals.radius),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            spreadRadius: 2.0,
            offset: Offset(
              0.0, // horizontal, move right 10
              0.0, // vertical, move down 10
            ),
          ),
        ],
      ),
      child: _buildThumbnail(),
    );
  }

  Widget _buildThumbnail(){
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Globals.radius),
        image: DecorationImage(
          image: NetworkImage(widget.wanderpi.wanderpiThumbnailUri),
          fit: BoxFit.cover,
        ),
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
            objectPreviewName: widget.wanderpi.name,
            objectCreationDate: widget.wanderpi.creationDate,
            onSelect: (bool isSelected) {
              setState(() {
                if (isSelected) {
                  widget.onSelect(widget.wanderpi);
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
                title: Text(widget.wanderpi.address, style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                ),),
              ),

              /*ListTile(
                      leading: const Icon(Icons.punch_clock, color: Colors.black),
                      title: Text(widget.wanderpi.wanderpiCreationDate.toString(), style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Colors.black,
                      ),),
                    ),*/

              ListTile(
                leading: const Icon(Icons.moving , color: Colors.black),
                title: Text("${widget.wanderpi.lastUpdateDate} km", style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                ),),
              ),
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
        buildButton(context, Icons.folder_open, "", Colors.blueAccent, widget.onTap),
        buildButton(context, Icons.edit, "", Colors.black, widget.onTap),
        buildButton(context, Icons.delete, "", Colors.red, widget.onTap),
      ],
    );
  }


}