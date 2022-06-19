/* Creates a rounded box that holds a title and image */
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:wp_frontend/const/design_globals.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/ui/bloc/card_preview.dart';
import 'package:wp_frontend/ui/utils.dart';
import 'package:wp_frontend/utils/maps/cached_tile_provider.dart';



class StopCard extends StatefulWidget{
  final Stop stop;
  final Function onTap;
  final ValueChanged<Stop?> onSelect;
  const StopCard({Key? key, required this.stop,  required this.onTap, required this.onSelect}) : super(key: key);

  @override
  State<StopCard> createState() => _StopCardState();

}

class _StopCardState extends State<StopCard> {
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
          CardPreview(
            objectPreviewName: widget.stop.stopDestinationName,
            imageUrl: widget.stop.stopImageUri,
            thumbnailUrl: widget.stop.stopThumbnailUri,
            type: CardPreviewType.image,
          ),
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
      child: _buildMap(),
    );
  }

  FlutterMap _buildMap(){
    return FlutterMap(
      options: MapOptions(
        center: LatLng(widget.stop.stopLatitude, widget.stop.stopLongitude),
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          attributionBuilder: (_) {
            return const Text("© OpenStreetMap contributors");
          },
          //tileProvider: const CachedTileProvider(),
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(widget.stop.stopLatitude, widget.stop.stopLongitude),
              builder: (ctx) =>
                  Container(
                    child: FlutterLogo(),
                  ),
            ),
          ],
        ),
      ],
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
                        Text( widget.stop.stopName,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.stop.stopCreationDate.toString(),
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
                            widget.onSelect(widget.stop);
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
                title: Text(widget.stop.stopDestinationName, style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                ),),
              ),

              /*ListTile(
                      leading: const Icon(Icons.punch_clock, color: Colors.black),
                      title: Text(widget.stop.stopCreationDate.toString(), style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Colors.black,
                      ),),
                    ),*/

              ListTile(
                leading: const Icon(Icons.moving , color: Colors.black),
                title: Text("${widget.stop.stopDistance} km", style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                ),),
              ),

              ListTile(
                leading: const Icon(Icons.date_range , color: Colors.black),
                title: Text("${convertDateTimeDisplay(widget.stop.stopDateRangeStart)} - ${convertDateTimeDisplay(widget.stop.stopDateRangeEnd)}", style: Theme.of(context).textTheme.bodyText1?.copyWith(
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
        buildButton(context, Icons.folder_open, "", Colors.blueAccent, widget.onTap),
        buildButton(context, Icons.account_balance_wallet, "", Colors.black, widget.onTap),
        buildButton(context, Icons.edit, "", Colors.black, widget.onTap),
        buildButton(context, Icons.delete, "", Colors.red, widget.onTap),
      ],
    );
  }
}