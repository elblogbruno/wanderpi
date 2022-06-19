/* Creates a rounded box that holds a title and image */
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wp_frontend/utils/maps/cached_tile_provider.dart';

class SlideView extends StatefulWidget{
  const SlideView({Key? key}) :  super(key: key);

  @override
  State<SlideView> createState() => _SlideViewState();

}

class _SlideViewState extends State<SlideView> {

  @override
  Widget build(BuildContext context) {



    /* Column that holds the map and the bottom buttons */
    return Column(
      children: <Widget>[
        _buildTitle(),
        _buildCarrousel(),
        Expanded(
          child: _buildMap(),
        ),
      ],
    );
  }

  Widget _buildTitle(){
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: const Text("Slide view",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  double getCorrectHeight(BuildContext context){
    /* calculate carousel correct height so the map is not cut off */
    return (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 50) / 2;
  }

  Widget _buildCarrousel(){
    return CarouselSlider(
      options: CarouselOptions(height: getCorrectHeight(context), ),
      items: [1,2,3,4,5].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: const BoxDecoration(
                    color: Colors.amber

                ),
                child: Text('text $i', style: TextStyle(fontSize: 16.0),)
            );
          },
        );
      }).toList(),
    );
  }


  Container _buildMap(){
    return Container(
        height: getCorrectHeight(context),
        width: MediaQuery.of(context).size.width,
        child: FlutterMap(
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
        ),
      );
  }
}