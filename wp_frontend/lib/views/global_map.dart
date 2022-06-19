/* Creates a rounded box that holds a title and image */
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/ui/bar/context_bar.dart';
import 'package:wp_frontend/utils/maps/cached_tile_provider.dart';

import '../const/design_globals.dart';

class GlobalMapView extends StatefulWidget{
  final Travel? travel;
  final Function onBackPressed;

  const GlobalMapView({Key? key, this.travel, required  this.onBackPressed}) :  super(key: key);



  @override
  State<GlobalMapView> createState() => _GlobalMapViewState();

}

class _GlobalMapViewState extends State<GlobalMapView> {

  String get _title {
    if (widget.travel != null) {
      return "${widget.travel!.travelName} Map View";
    }
    return "Global Map View";
  }

  @override
  Widget build(BuildContext context) {
    /* Column that holds the map and the bottom buttons */
    return ContextBar(
      showBackButton: true,
      title: _title,
      onBackPressed:  () {
        print('stop Back pressed');
        widget.onBackPressed();
      },
      child: _buildMap(),
    );
  }

  Widget _buildBottomButtons(){
    return Positioned(
      bottom: 0,
      left : 0,
      right: 0,
      top: 45,
      child:
        Container(
        decoration:  const BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.all(Radius.circular(Globals.radius)),
        ),
        height: 50,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildBottomButton(context, "Map", Icons.map),
            _buildBottomButton(context, "Satellite", Icons.map),
            _buildBottomButton(context, "Hybrid", Icons.map),
          ],
        ),
      ),

    );
  }

  Widget _buildTitle(){
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: const Text("Global Map",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, String text, IconData icon){
    return FlatButton(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon),
          Text(text),
        ],
      ),
      onPressed: (){},
    );
  }

  FlutterMap _buildMap(){
    return FlutterMap(
      options: MapOptions(
        center: LatLng(51.5, -0.09),
        zoom: 8.0,
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
          markers:  widget.travel != null ? widget.travel!.travelStops.map((stop) => stop.toMarker()).toList() : [],
        ),
      ],
    );
  }
}