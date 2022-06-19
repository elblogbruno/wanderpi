import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:latlong2/latlong.dart';
import 'package:wp_frontend/models/travel.dart';

class MapCardPreview extends StatefulWidget{
  final Travel travel;
  final List<Marker> markers;
  const MapCardPreview({Key? key, required this.travel,  required this.markers}) : super(key: key);

  @override
  State<MapCardPreview> createState() => _MapCardPreviewState();

}

class _MapCardPreviewState extends State<MapCardPreview> {

  @override
  Widget build(BuildContext context) {
    return buildTravelMapPreview();
  }

  Widget buildTravelMapPreview() {
    return Container(
        height: 200,
        width: MediaQuery
            .of(context)
            .size
            .width,
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
        child:
        Stack(
          children: <Widget>[
            _buildMap(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(Globals.radius),
                      //bottomRight: Radius.circular(Globals.radius),
                    ),
                    color: Colors.white,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen),
                    color: Colors.black,
                    onPressed: () {
                      print("Location pressed");
                      _toggleFullScreenMap();
                    },
                  ),
                ),
                const VerticalDivider(
                  color: Colors.black,
                  thickness: 5,
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      //topRight: Radius.circular(Globals.radius),
                      //bottomRight: Radius.circular(Globals.radius),
                    ),
                    color: Colors.white,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.explore),
                    color: Colors.black,
                    onPressed: () {
                      print("Location pressed");
                      _openOnGoogleMaps();
                    },
                  ),
                ),
                const VerticalDivider(
                  color: Colors.black,
                  thickness: 5,
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      //topRight: Radius.circular(Globals.radius),
                      bottomRight: Radius.circular(Globals.radius),
                    ),
                    color: Colors.white,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.info),
                    color: Colors.black,
                    onPressed: () {
                      print("Location pressed");
                      _openWikipedia();
                    },
                  ),
                ),
              ],
            ),
          ],
        )
    );
  }

  void _openWikipedia() async {
    String url = "https://en.wikipedia.org/wiki/${widget.travel.travelName}";

    print(url);
    final Uri _uri = Uri.parse(url);

    if (!await launchUrl(_uri)) throw 'Could not launch $url';
  }

  void _openOnGoogleMaps() async {
    String url = "https://www.google.com/maps/search/?api=1&query=${widget
        .travel.travelName}";
    print(url);
    final Uri _uri = Uri.parse(url);

    if (!await launchUrl(_uri)) throw 'Could not launch $url';
  }

  void _toggleFullScreenMap() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fullscreen Map'),
          content: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(Globals.radius),
                bottomRight: Radius.circular(Globals.radius),
              ),
              color: Colors.white,
            ),
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Expanded(child: _buildMap()),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  FlutterMap _buildMap(){
    return FlutterMap(
      options: MapOptions(
        center: LatLng(widget.travel.travelLatitude, widget.travel.travelLongitude),
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
          markers: widget.markers,
        ),
      ],
    );
  }



}