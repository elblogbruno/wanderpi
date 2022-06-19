/* create a grid of buttons */

/* Creates a rounded box that holds a title and image */
import 'dart:io';

import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/wanderpi.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/models/wanderpi.dart';
import 'package:wp_frontend/ui/bar/context_bar.dart';
import 'package:wp_frontend/ui/bloc/wanderpi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:wp_frontend/ui/bloc/wanderpi_card.dart';
import 'package:wp_frontend/ui/grid/base_grid.dart';

class WanderpiGrid extends StatefulWidget{
  final ContentType? filter;
  final Travel travel;
  final Stop stop;
  final ValueChanged<Wanderpi> onWanderpiSelected;
  final Function onBackPressed;

  const WanderpiGrid({Key? key, this.filter, required this.travel, required this.stop, required this.onWanderpiSelected, required this.onBackPressed}) :  super(key: key);

  @override
  State<WanderpiGrid> createState() => _WanderpiGridState();
}

class _WanderpiGridState extends State<WanderpiGrid> {

  final List<Wanderpi> _selectedWanderpi = [];

  String title = "";
  var children = <Widget> [];

  void initState() {
    super.initState();
    title = widget.stop.stopName;


    for (int i = 0; i < 10; i++) {

      Wanderpi wanderpi = Wanderpi.randomFromInt(i);

      children.add(
          WanderpiCard(
            wanderpi: wanderpi,
            onTap: () {
              print('Tapped ${wanderpi.wanderpiName}');

              widget.onWanderpiSelected(wanderpi);
            },
            onSelect: (Wanderpi? travelSelected) {

              if (travelSelected != null) {
                print('Selected ${wanderpi.wanderpiName}');

                setState(() {
                  _selectedWanderpi.add(wanderpi);
                  changeTitle();
                });
              }else{
                print('Unselected ${wanderpi.wanderpiName}');

                setState(() {
                  _selectedWanderpi.removeWhere((element) => element.wanderpiName == wanderpi.wanderpiName);
                  changeTitle();


                });
              }


            },
          )
      );

    }
  }

  void changeTitle() {
    if (_selectedWanderpi.isEmpty) {
      title = widget.stop.stopName;
    }else{
      title = '${_selectedWanderpi.length} selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Selected ${_selectedWanderpi.length}');
    //Theme.of(context).colorScheme.background.withOpacity(0.7)
    return
      ContextBar(
        showBackButton: true,
        showContextButtons: _selectedWanderpi.isNotEmpty,
        title: title,
        onBackPressed: () {
          print('Wanderpi Back pressed');
          widget.onBackPressed();
        },
        child: Container(
          color: Theme.of(context).colorScheme.background.withOpacity(0.7),
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child:  getCustomScrollView(context, children)
          ),
        ),
    );
  }

}