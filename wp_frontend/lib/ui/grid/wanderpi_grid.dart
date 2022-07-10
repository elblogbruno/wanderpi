/* create a grid of buttons */

/* Creates a rounded box that holds a title and image */
import 'dart:io';

import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/wanderpi.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/ui/bar/context_bar.dart';
import 'package:wp_frontend/ui/bloc/template_cards/add_new_card.dart';
import 'package:wp_frontend/ui/bloc/template_cards/wanderpi_card.dart';
import 'package:flutter/material.dart';

import 'package:wp_frontend/ui/grid/base_grid.dart';
import 'package:wp_frontend/ui/state_widgets/base_future_builder.dart';
import 'package:wp_frontend/ui/utils.dart';

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

  Widget getWanderpi(Wanderpi wanderpi){
    return WanderpiCard(
      wanderpi: wanderpi,
      onTap: () {
        print('Tapped ${wanderpi.name}');

        widget.onWanderpiSelected(wanderpi);
      },
      onSelect: (Wanderpi? travelSelected) {

        if (travelSelected != null) {
          print('Selected ${wanderpi.name}');

          setState(() {
            _selectedWanderpi.add(wanderpi);
            changeTitle();
          });
        }else{
          print('Unselected ${wanderpi.name}');
          setState(() {
            _selectedWanderpi.removeWhere((element) => element.name == wanderpi.name);
            changeTitle();
          });
        }
      },
    );
  }

  List<Widget> buildWanderpiCardListFromList(List<Wanderpi> wanderpis){
    var children1 = <Widget> [];
    for (int i = 0; i < wanderpis.length; i++) {

      Wanderpi wanderpi = wanderpis[i];

      children1.add(
          getWanderpi(wanderpi)
      );
    }

    return children1;
  }


  @override
  void initState() {
    super.initState();
    title = widget.stop.name;

    print('WanderpiGrid initState ${widget.stop.name} ${widget.travel.name} ${widget.stop.stopWanderpis!.length}');

    for (int i = 0; i < widget.stop.stopWanderpis!.length; i++) {

      Wanderpi wanderpi =  widget.stop.stopWanderpis![i];

      children.add(
          getWanderpi(wanderpi)
      );

    }
  }

  void changeTitle() {
    if (_selectedWanderpi.isEmpty) {
      title = widget.stop.name;
    }else{
      title = '${_selectedWanderpi.length} selected';
    }
  }

  void onAddClicked() {
    print('Add clicked');
    //widget.onBackPressed();
  }

  @override
  Widget build(BuildContext context) {
    print('Selected ${_selectedWanderpi.length}');

    Widget child = Center(
        child: AddMoreCard(
          objectToAdd: 'Wanderpi',
          onTap: () { onAddClicked(); },
        )
    );

    if (children.isNotEmpty){
      print('WanderpiGrid build ${widget.stop.name} ${widget.travel.name} ${widget.stop.stopWanderpis!.length}');
      child = getCustomScrollView(context, children);
    }

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
              child:  BaseFutureBuilder<List<Wanderpi>>(
                calculation: Api().wanderpiApiEndpoint().getWanderpis(widget.stop),
                builder: (context, wanderpis) {
                  if (wanderpis!.isEmpty || children.isNotEmpty) { // if there are no stops or if there are already stops in the list, show the list
                    print('WanderpiGrid  isEmpty ${wanderpis.isEmpty}');
                    // if we have stops we checked if they changed from the latest server version, if so we need to update the list
                    if (arrayDifferent(wanderpis, widget.stop.stopWanderpis!)) {
                      print('WanderpiGrid arrayDifferent ${wanderpis.length} ${widget.travel.travelStops!.length}');
                      children = buildWanderpiCardListFromList(wanderpis);
                      child = getCustomScrollView(context, children);
                    }

                    return child;
                  }
                  // we get them from the server and show them
                  return getCustomScrollView(context, buildWanderpiCardListFromList(wanderpis)); // if there are no stops, show the add more card
                },
              )
          ),
        ),
    );
  }

}