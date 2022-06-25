import 'package:geocoding/geocoding.dart';
import 'dart:io' show Platform;

Future<List<double>> getLatLongFromAddress(String address) async{

  if (Platform.isWindows)
  {
    return [0.0, 0.0];
  }

  List<Location> locations = await locationFromAddress("Gronausestraat 710, Enschede");

  if (locations.isNotEmpty) {
    return [locations[0].latitude,  locations[0].longitude];
  } else {
    return [0.0, 0.0];
  }
}

