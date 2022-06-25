/* create a grid of buttons */

/* Creates a rounded box that holds a title and image */
import 'dart:io';

import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/ui/bar/context_bar.dart';
import 'package:wp_frontend/ui/bloc/add_new_card.dart';
import 'package:wp_frontend/ui/bloc/stop_card.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/ui/dialogs/new_stop_dialog.dart';
import 'package:wp_frontend/ui/grid/base_grid.dart';

class StopGrid extends StatefulWidget{
  final ContentType? filter;
  final Travel travel;
  final ValueChanged<Stop> onStopSelected;
  final Function onBackPressed;

  const StopGrid({Key? key, this.filter, required this.travel, required this.onStopSelected, required this.onBackPressed}) :  super(key: key);

  @override
  State<StopGrid> createState() => _StopGridState();
}

class _StopGridState extends State<StopGrid> {

  final List<Stop> _selectedTravels = [];

  String title = "", subtitle = "";

  var children = <Widget> [];
  //var children1 = <Widget> [];

  StopCard getStop(Stop stop){
    return StopCard(
      stop: stop,
      onTap: () {
        print('Tapped ${stop.stopName}');

        widget.onStopSelected(stop);
      },
      onSelect: (Stop? travelSelected) {

        if (travelSelected != null) {
          print('Selected ${stop.stopName}');

          setState(() {
            _selectedTravels.add(stop);
            changeTitle();
          });
        }else{
          print('Unselected ${stop.stopName}');

          setState(() {
            _selectedTravels.removeWhere((element) => element.stopName == stop.stopName);
            changeTitle();


          });
        }


      },
    );
  }

  void initState() {
    super.initState();
    title = widget.travel.travelName;

    for (int i = 0; i < widget.travel.travelStops!.length; i++) {

      Stop stop =  widget.travel.travelStops![i];

      children.add(
          getStop(stop)
      );

    }
  }

  void changeTitle() {
    if (_selectedTravels.isEmpty) {
      subtitle = "";
    }else{
      subtitle = '${_selectedTravels.length} selected';
    }
  }

  void onAddClicked() {
    showDialog<void>(
      context: context,
      builder: (dialogContex) {
        return NewStopDialog(
          travel: widget.travel,
          onStopCreated: (Stop stop) async {
            Stop finalStop = await Api().createStop(stop);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Stop created!')),
            );

            setState(() {
              children.add(
                  getStop(finalStop)
              );
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Selected ${_selectedTravels.length}');

    Widget child = Center(
        child: AddMoreCard(
          objectToAdd: 'Stop',
          onTap: () { onAddClicked(); },
        )
    );

    if (children.isNotEmpty){
      child = getCustomScrollView(context, children);
    }

    return ContextBar(
        onAddClicked: onAddClicked,
        showBackButton: true,
        showDeleteButton: _selectedTravels.isNotEmpty,
        showContextButtons: true,
        title: title,
        subtitle: subtitle,
        onBackPressed:  () {
          print('stop Back pressed');
          widget.onBackPressed();
        },
        child: Container(
          color: Theme.of(context).colorScheme.background.withOpacity(0.7),
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child:  child
          ),
        ),
      );
  }



}