/* Creates a rounded box that holds a title and image */
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wp_frontend/models/document.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/ui/bar/context_bar.dart';
import 'package:wp_frontend/ui/bloc/document_card.dart';
import 'package:wp_frontend/ui/grid/base_grid.dart';
import 'package:wp_frontend/utils/maps/cached_tile_provider.dart';

import '../const/design_globals.dart';

class DocumentVaultView extends StatefulWidget{
  final Travel? travel;
  final Function onBackPressed;

  const DocumentVaultView({Key? key, this.travel, required  this.onBackPressed}) :  super(key: key);



  @override
  State<DocumentVaultView> createState() => _DocumentVaultViewState();

}

class _DocumentVaultViewState extends State<DocumentVaultView> {

  List<DocumentCard> children = [];
  List<Document> _selectedDocuments = [];

  String subtitle = "";

  String get _title {
    if (widget.travel != null) {
      return "${widget.travel!.travelName} Document Vault";
    }
    return "Global Document Vault";
  }

  void changeTitle() {
    if (_selectedDocuments.isEmpty) {
      subtitle = "";
    }else{
      subtitle = '${_selectedDocuments.length} selected';
    }
  }

  void initState() {
    super.initState();
    print('initState DocumentVaultView');

    initGrid();
  }

  @override
  void didUpdateWidget (DocumentVaultView oldWidget) {
    super.didUpdateWidget(oldWidget);

    print('didUpdateObject DocumentVaultView');
    if (widget.travel !=  null) {
      initGrid();
    }
  }

  void initGrid(){
    if (widget.travel != null) {
      print('Loading documents for ${widget.travel!.travelName}');

      for (int i  = 0; i < widget.travel!.travelDocuments!.length; i++) {

        print('Adding ${widget.travel!.travelDocuments![i].documentName}');

        Document document = widget.travel!.travelDocuments![i];

        DocumentCard card  = DocumentCard(
          document: document,
          onTap: () {
            print('Tapped ${document.documentName}');
          },
          onSelect: (Document? documentSelected) {

            if (documentSelected != null) {
              print('Selected ${document.documentName}');

              setState(() {
                _selectedDocuments.add(document);
                changeTitle();
              });
            }else{
              print('Unselected ${document.documentName}');

              setState(() {
                _selectedDocuments.remove(document);
                changeTitle();
              });
            }
          },
        );

        children.add(card);

      }

    }
  }



  @override
  Widget build(BuildContext context) {
    /* Column that holds the map and the bottom buttons */
    return ContextBar(
      showBackButton: true,
      title: _title,
      subtitle: subtitle,
      onBackPressed:  () {
        print('stop Back pressed');
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