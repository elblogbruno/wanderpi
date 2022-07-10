/* Creates a rounded box that holds a title and image */
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wp_frontend/models/wanderpi.dart';
import 'package:wp_frontend/ui/bar/context_bar.dart';
import 'package:wp_frontend/utils/maps/cached_tile_provider.dart';

import '../const/design_globals.dart';

class SingleWanderpiView extends StatefulWidget{
  final Wanderpi wanderpi;
  final Function onBackPressed;
  const SingleWanderpiView({Key? key, required this.wanderpi, required this.onBackPressed}) :  super(key: key);


  @override
  State<SingleWanderpiView> createState() => _SingleWanderpiViewState();

}

class _SingleWanderpiViewState extends State<SingleWanderpiView> {

  double _widthRatio = 0.75;
  double _heightRatio = 0.75;

  @override
  Widget build(BuildContext context) {
    /* Column that holds the map and the bottom buttons */
    return
      ContextBar(
        title: widget.wanderpi.name,
        onBackPressed: () {
      widget.onBackPressed();
    },
    showBackButton: true,
    showContextButtons: false,
    child:
      Column(
      //mainAxisAlignment: MainAxisAlignment.center,

      children: <Widget>[
        /*ContextBar(
          title: widget.wanderpi.wanderpiName,
          onBackPressed: () {
            widget.onBackPressed();
          },
          showBackButton: true,
          showContextButtons: false,
        ),*/
        _buildImage(),
        SizedBox(height: 10),
        _buildInfo(),

        /*Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildImage(),
            _buildInfo(),
          ],
        ),*/

        /*Padding(
          padding: const EdgeInsets.all(10.0) ,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(Globals.radius),
                bottomRight: Radius.circular(Globals.radius),
              ),
              color: Colors.white,
            ),
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Expanded(child: _buildMap()),
          ),
        ),*/

      ],
    ),
    );
  }

  Widget _showMapDialog(){
    return AlertDialog(
      title: Text("${widget.wanderpi.name } is located at ${widget.wanderpi.address}"),
      content: Padding(
        padding: const EdgeInsets.all(10.0) ,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Globals.radius),
              bottomRight: Radius.circular(Globals.radius),
            ),
            color: Colors.white,
          ),
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.5,
          child: Expanded(child: _buildMap()),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildImage(){

    return Container(
      height: MediaQuery.of(context).size.height  * _heightRatio,
      width: MediaQuery.of(context).size.width  * _widthRatio,
      padding: const EdgeInsets.all(10.0),
      decoration: const
      BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Globals.radius),
          topRight: Radius.circular(Globals.radius),
        ),
        color: Colors.white,
      ),
      child: Image.network(
        widget.wanderpi.wanderpiUri,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInfo(){
    return Container(
      //height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width *  _widthRatio,
      padding: const EdgeInsets.all(10.0),
      decoration: const
      BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Globals.radius),
          bottomRight: Radius.circular(Globals.radius),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildTitle(),
          _buildLocationInfoBox(),

          RaisedButton(
            child: Text("Show Map"),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => _showMapDialog(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfoBox(){
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Globals.radius),
          bottomRight: Radius.circular(Globals.radius),
        ),
        color: Colors.white,
      ),
      child: Column (
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
            Text(
              widget.wanderpi.address,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            Text(
                "${widget.wanderpi.latitude}, ${widget.wanderpi.longitude}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
            ),

        ],
      ),
    );
  }

  Widget _buildTitle(){
    return
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.wanderpi.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          Text(
            widget.wanderpi.creationDate.toIso8601String(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color : Colors.black,
            ),
          ),

          Text(widget.wanderpi.lastUpdateDate.toIso8601String(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color : Colors.black,
            ),
          ),
        ],

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
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(51.5, -0.09),
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
}