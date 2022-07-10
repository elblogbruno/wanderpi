import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:latlong2/latlong.dart';


enum  CardPreviewType {
  map,
  image,
  document,
}

class CardPreview extends StatefulWidget{

  final double? latitude;
  final double? longitude;

  final List<Marker>? markers;
  final String? objectPreviewName;
  final String? thumbnailUrl;
  final String? imageUrl;
  final CardPreviewType type;

  const CardPreview({Key? key, required  this.type,  this.latitude, this.longitude, this.objectPreviewName, this.markers, this.imageUrl, this.thumbnailUrl}) : super(key: key);

  @override
  State<CardPreview> createState() => _CardPreviewState();

}

class _CardPreviewState extends State<CardPreview> {

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

  Widget buildPreview() {
    return Container(
        height: 200,
        width: 550,
        //width: MediaQuery.of(context).size.width - 20,
        padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
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
        child: Stack(
            children: <Widget>[
              if (widget.type == CardPreviewType.map)
                _buildMapPreview(),
              if (widget.type == CardPreviewType.image || widget.type == CardPreviewType.document)
                buildImagePreview(),
              if (widget.type != CardPreviewType.document)
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
                        if (widget.type == CardPreviewType.map) {
                          _toggleFullScreenMap();
                        }else{
                          _toggleFullScreenImage();
                        }
                      },
                    ),
                  ),

                  buildDivider(),

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

                  buildDivider(),

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
    String url = "https://en.wikipedia.org/wiki/${widget.objectPreviewName}";

    print(url);
    final Uri _uri = Uri.parse(url);

    if (!await launchUrl(_uri)) throw 'Could not launch $url';
  }

  void _openOnGoogleMaps() async {
    String url = "https://www.google.com/maps/search/?api=1&query=${widget.objectPreviewName}";
    print(url);
    final Uri _uri = Uri.parse(url);

    if (!await launchUrl(_uri)) throw 'Could not launch $url';
  }

  void _toggleFullScreenImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Image"),
          content: Image.network(widget.imageUrl ?? Globals.notFoundImageUrl),
          actions: <Widget>[
            FlatButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            child: Expanded(child: _buildMapPreview()),
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

  FlutterMap _buildMapPreview(){
    return FlutterMap(
      options: MapOptions(
        center: LatLng(widget.latitude ?? 0.0, widget.longitude ?? 0.0),
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
          markers: widget.markers ?? [],
        ),
      ],
    );
  }

  Widget buildImagePreview() {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(widget.type == CardPreviewType.map ? 10.0 : 0.0),
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
      child: Image.network(
        widget.thumbnailUrl ?? Globals.notFoundImageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

}