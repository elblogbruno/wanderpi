/* Creates a rounded box that holds a title and image */
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:wp_frontend/const/design_globals.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/models/document.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/ui/bloc/card_preview.dart';
import 'package:wp_frontend/ui/utils.dart';
import 'package:wp_frontend/utils/maps/cached_tile_provider.dart';



class DocumentCard extends StatefulWidget
{
  final Document document;
  final Function onTap;
  final ValueChanged<Document?> onSelect;
  const DocumentCard({Key? key, required this.document, required this.onTap, required this.onSelect}) : super(key: key);

  @override
  State<DocumentCard> createState() => _DocumentCardState();

}

class _DocumentCardState extends State<DocumentCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = const EdgeInsets.all(10.0);

    /* Card that holds the image and text and has bottom buttons*/
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Globals.radius),
      ),
      child: Column(
        // direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CardPreview(
            objectPreviewName: widget.document.documentName,
            imageUrl: widget.document.documentImageUri,
            thumbnailUrl: widget.document.documentThumbnailUri,
            type: CardPreviewType.document,
          ),
          buildContentInfoPart(context),

        ],
      ),
    );
  }

  Widget buildContentInfoPart(BuildContext context) {
    /* Middle part of the card that holds the title and the image  in a grey background  of the same width as the card*/
    return Container(
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Globals.radius),
          bottomRight: Radius.circular(Globals.radius),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
        <Widget>[
          Padding(padding: const EdgeInsets.all(10.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text( widget.document.documentName,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.document.documentCreationDate.toString(),
                          textAlign: TextAlign.start,

                          style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Globals.radius),
                      ),
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: _isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          _isSelected = value!;

                          if (_isSelected) {
                            widget.onSelect(widget.document);
                          }else{
                            widget.onSelect(null);
                          }

                        });
                      },
                    ),
                  ],
                )

            ),
          ),
          Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.date_range , color: Colors.black),
                title: Text(widget.document.documentUploadDate.toString(), style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                ),),
              ),
              ListTile(
                leading: const Icon(Icons.type_specimen, color: Colors.black),
                title: Text(widget.document.documentType, style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                ),),
              ),
              ListTile(
                leading: const Icon(Icons.card_travel, color: Colors.black),
                title: Text(widget.document.documentTravelId, style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.black,
                ),),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          buildRowOfButtons(context),
          const SizedBox(height: 10,),

        ],
      ),
    );
  }

  Widget buildRowOfButtons(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        buildButton(context, Icons.folder_open, "", Colors.blueAccent, widget.onTap),
        buildButton(context, Icons.edit, "", Colors.black, widget.onTap),
        buildButton(context, Icons.delete, "", Colors.red, widget.onTap),
      ],
    );
  }
}