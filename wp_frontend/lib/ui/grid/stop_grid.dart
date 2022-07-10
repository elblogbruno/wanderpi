/* create a grid of buttons */

/* Creates a rounded box that holds a title and image */
import 'dart:io';

import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/models/user.dart';
import 'package:wp_frontend/ui/bar/context_bar.dart';
import 'package:wp_frontend/ui/bloc/template_cards/add_new_card.dart';
import 'package:wp_frontend/ui/bloc/template_cards/stop_card.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/ui/dialogs/new_stop_dialog.dart';
import 'package:wp_frontend/ui/grid/base_grid.dart';
import 'package:wp_frontend/ui/state_widgets/base_future_builder.dart';
import 'package:wp_frontend/ui/utils.dart';

class StopGrid extends StatefulWidget{
  final ContentType? filter;
  final Travel travel;
  final ValueChanged<Stop> onStopSelected;
  final Function onBackPressed;
  final User currentUser;

  const StopGrid({Key? key, this.filter, required this.currentUser, required this.travel, required this.onStopSelected, required this.onBackPressed}) :  super(key: key);

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
        print('Tapped ${stop.name}');

        widget.onStopSelected(stop);
      },
      onSelect: (Stop? travelSelected) {

        if (travelSelected != null) {
          print('Selected ${stop.name}');

          setState(() {
            _selectedTravels.add(stop);
            changeTitle();
          });
        }else{
          print('Unselected ${stop.name}');

          setState(() {
            _selectedTravels.removeWhere((element) => element.name == stop.name);
            changeTitle();


          });
        }


      },
    );
  }

  List<Widget> buildStopCardListFromList(List<Stop> stops){
    var children1 = <Widget> [];
    for (int i = 0; i < stops.length; i++) {

      Stop stop = stops[i];

      children1.add(
          getStop(stop)
      );
    }

    return children1;
  }

  void initState() {
    super.initState();
    title = widget.travel.name;

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
          currentUser: widget.currentUser,
          onStopCreated: (Stop stop) async {
            //Stop finalStop = await Api().stopApiEndpoint().createStop(stop);
            await Api().stopApiEndpoint().createStop(stop);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Stop created!')),
            );

            // setState(() {
            //   children.add(
            //       getStop(finalStop)
            //   );
            // });

            setState(() {
              _calculation = Api().stopApiEndpoint().getStops(widget.travel);
            });
          },
        );
      },
    );
  }


  late Future<List<Stop>> _calculation = Api().stopApiEndpoint().getStops(widget.travel);


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
              child:  BaseFutureBuilder<List<Stop>>(
                calculation: _calculation,
                builder: (context, stops) {
                  if (stops!.isEmpty || children.isNotEmpty) { // if there are no stops or if there are already stops in the list, show the list
                    // if we have stops we checked if they changed from the latest server version, if so we need to update the list
                    if (arrayDifferent(stops, widget.travel.travelStops!)) {
                      setState(() {
                        children = buildStopCardListFromList(stops);
                        child = getCustomScrollView(context, children);
                      });
                    }

                    return child;
                  }
                  // we get them from the server and show them
                  return getCustomScrollView(context, buildStopCardListFromList(stops)); // if there are no stops, show the add more card
                },
              )
          ),
        ),
      );
  }



}