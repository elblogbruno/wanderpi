/* create a grid of buttons */

/* Creates a rounded box that holds a title and image */
import 'dart:io';

import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/ui/bar/context_bar.dart';
import 'package:wp_frontend/ui/bloc/travel_card.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/ui/grid/base_grid.dart';

class TravelGrid extends StatefulWidget{
  final ContentType? filter;
  final ValueChanged<Travel> onTravelSelected;

  const TravelGrid({Key? key, this.filter, required this.onTravelSelected}) :  super(key: key);

  @override
  State<TravelGrid> createState() => _TravelGridState();
}

class _TravelGridState extends State<TravelGrid> {

  final List<Travel> _selectedTravels = [];
  String title = "";
  var children = <Widget> [];

  void initState() {
    super.initState();

    for (int i = 0; i < 10; i++) {

      Travel travel = Travel.randomFromInt(i);

      children.add(
          TravelCard(
            travel: travel,
            onTap: () {
              print('Tapped ${travel.travelName}');

              widget.onTravelSelected(travel);
            },
            onSelect: (Travel? travelSelected) {

              if (travelSelected != null) {
                print('Selected ${travel.travelName}');

                setState(() {
                  _selectedTravels.add(travel);
                  changeTitle();
                });
              }else{
                print('Unselected ${travel.travelName}');

                setState(() {
                  _selectedTravels.removeWhere((element) => element.travelName == travel.travelName);
                  changeTitle();
                });
              }

            },
          )
      );
    }
  }

  void changeTitle() {
    if (_selectedTravels.isEmpty) {
      title = 'Your travels'  + ' (${_selectedTravels.length})';
    }else{
      if (_selectedTravels.length == 1) {
        title = '${_selectedTravels.first.travelName}' + ' selected';
      }else{
        title = '${_selectedTravels.first.travelName} and ' + '${_selectedTravels.length} more selected';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Selected ${_selectedTravels.length}');

    //Theme.of(context).colorScheme.background.withOpacity(0.7)
    return ContextBar(
        showBar: _selectedTravels.isNotEmpty,
        showBackButton: false,
        showContextButtons: _selectedTravels.isNotEmpty,
        title: title,
        child: Container(
            //color: Theme.of(context).colorScheme.background.withOpacity(0.7),
            child: Padding(
            padding: const EdgeInsets.all(10.0),
            child:  getCustomScrollView(context, children),
          ),
        ),
    );
  }


}