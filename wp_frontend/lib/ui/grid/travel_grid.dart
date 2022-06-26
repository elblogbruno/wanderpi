/* create a grid of buttons */

/* Creates a rounded box that holds a title and image */
import 'dart:io';

import 'package:i18n_extension/default.i18n.dart';
import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/models/user.dart';
import 'package:wp_frontend/resources/strings.dart';
import 'package:wp_frontend/ui/bar/context_bar.dart';
import 'package:wp_frontend/ui/bloc/add_new_card.dart';
import 'package:wp_frontend/ui/bloc/travel_card.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/ui/dialogs/new_travel_dialog.dart';
import 'package:wp_frontend/ui/grid/base_grid.dart';

class TravelGrid extends StatefulWidget{
  final ContentType? filter;
  final User currentUser;
  final ValueChanged<Travel> onTravelSelected;

  const TravelGrid({Key? key, this.filter, required this.onTravelSelected, required this.currentUser}) :  super(key: key);

  @override
  State<TravelGrid> createState() => _TravelGridState();
}

class _TravelGridState extends State<TravelGrid> {

  List<Travel> _travelList = [];
  final List<Travel> _selectedTravels = [];
  String title = "";

  List<Widget> buildTravelCardListFromList(List<Travel> travels){
    var children = <Widget> [];

    changeTitle();

    for (int i = 0; i < travels.length; i++) {

      Travel travel = travels[i];

      children.add(
          TravelCard(
            travel: travel,
            onDeleteClick: (Travel travelSelected) async {
              await Api().deleteTravel(travelSelected);

              setState(() {
                _calculation = Api().getTravels();
              });
            },
            onTap: () {
              print('Tapped ${travel.name}');

              widget.onTravelSelected(travel);
            },
            onSelect: (Travel? travelSelected) {

              if (travelSelected != null) {
                print('Selected ${travel.name}');

                setState(() {
                  _selectedTravels.add(travel);
                  changeTitle();
                });
              }else{
                print('Unselected ${travel.name}');

                setState(() {
                  _selectedTravels.removeWhere((element) => element.name == travel.name);
                  changeTitle();
                });
              }

            },
          )
      );
    }

    return children;
  }

  void bulkDelete() async
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleting $title')),
    );

    for (int i = 0; i < _selectedTravels.length; i++){
      await Api().deleteTravel(_selectedTravels[i]);
    }

    setState(() {
      _calculation = Api().getTravels();
    });
  }

  void changeTitle() {
    if (_selectedTravels.isEmpty) {
      title = 'Your travels - ${_travelList.length}';
    }else{
      if (_selectedTravels.length == 1) {
        title = '${_selectedTravels.first.name} selected';
      }else{
        title = '${_selectedTravels.first.name} and  ${_selectedTravels.length - 1} more selected';
      }
    }
  }

  void onAddClicked() {
    showDialog<void>(
      context: context,
      builder: (dialogContex) {
        return NewTravelDialog(
          currentUser: widget.currentUser,
          onTravelCreated: (Travel travel) async {
            await Api().createTravel(travel);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Travel created!')),
            );

            setState(() {
              _calculation = Api().getTravels();
            });
          },
        );
      },
    );
  }

  Future<List<Travel>?> _calculation = Api().getTravels();

  @override
  Widget build(BuildContext context) {
    print('Selected ${_selectedTravels.length}');

    //Theme.of(context).colorScheme.background.withOpacity(0.7)
    return ContextBar(
        showBar: true,
        onDeleteClicked: bulkDelete,
        onAddClicked: onAddClicked,
        showBackButton: false,
        showContextButtons: true,
        showDeleteButton:  _selectedTravels.isNotEmpty,
        title: title,
        child:
        FutureBuilder<List<Travel>?>(
          future: _calculation, // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<List<Travel>?> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              _travelList = snapshot.data!;

              if (_travelList.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: getCustomScrollView(context,
                      buildTravelCardListFromList(_travelList)),
                );
              }else{
                return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child:  Center(
                    child: AddMoreCard(
                      objectToAdd: 'Travel',
                      onTap: () { },
                    )
                    ),
                );
              }
            } else if (snapshot.hasError) {
              children = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center,),
                ),
                InkWell(
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.red,
                        size: 60,
                      ),
                    ),
                    onTap: () => setState(() { _calculation = Api().getTravels(); })
                )
              ];

            } else {
              children = <Widget>[
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(Strings.waitText.i18n),
                ),

              ];
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            );
          },
        ),



    );
  }


}