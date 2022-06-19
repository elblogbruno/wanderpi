/* Creates a rounded box that holds a title and image */
import 'package:wp_frontend/const/content_type.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:flutter/material.dart';

class ContentCard extends StatefulWidget{
  final String title;
  final String image;
  final ContentType contentType;

  const ContentCard({Key? key, required this.title, required this.contentType, required this.image}) :  super(key: key);

  @override
  State<ContentCard> createState() => _ContentCardState();

}

class _ContentCardState extends State<ContentCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
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
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Globals.radius),
                      topRight: Radius.circular(Globals.radius),
                    ),
                    image: DecorationImage(
                      image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1200px-Image_created_with_a_mobile_phone.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withAlpha(0),
                        Colors.black12,
                        Colors.black45
                      ],
                    ),
                  ),
                  child:  Text(
                    widget.title,
                    style: const TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
              ],
            ),
          ),
          buildContentActionsBar(context),
        ],
      ),
    );
  }

  Widget buildContentPreviewPart(BuildContext context){
    return Flexible(
      flex: 1,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Globals.radius),
          topRight: Radius.circular(Globals.radius),
        ),
        child: Image.asset(
          widget.image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildContentInfoPart(BuildContext context) {
    /* Middle part of the card that holds the title and the image  in a grey background  of the same width as the card*/
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).colorScheme.background.withOpacity(0.5),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContentActionsBar(BuildContext context) {
    /* Bottom bar that holds the buttons */
    return Container(
      height: 40,
      decoration:  BoxDecoration(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(Globals.radius),
              bottomRight: Radius.circular(Globals.radius),
          ),
          //color: Theme.of(context).colorScheme.surfaceVariant // green as background color
          color: Theme.of(context).colorScheme.background.withOpacity(0.5),
    ),
      child:
        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Checkbox(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(Globals.radius)),
              ),
              value: _isSelected,
              onChanged: (bool? value) {
                setState(() {
                  _isSelected = value!;
                });
              },
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Colors.white,
            ),
            buildTypeBox(context),
            /* Verticall Line  of button height */
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Colors.white,
            ),
            OutlinedButton(
              style:  ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                    }
                    return Theme.of(context).colorScheme.primary;
                  },
                ),
                shape: MaterialStateProperty.resolveWith<OutlinedBorder>((_) {
                  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(Globals.radius));
                }),
              ),
              child: const Icon(Icons.delete, color: Colors.white,),
              onPressed: () {
                Navigator.pushNamed(context, '/view');
              },
            ),
          ],
        ),
    );
  }

  Widget buildTypeBox(BuildContext context) {
    /* Box that holds the type of content */
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // switch icon based on the 5 ContentType enum
            Icon(
              getIconNameFromContentType(widget.contentType),
              color: Colors.white,
            ),
            // white spaceEvenly
            const SizedBox(width: 10,),
            Text(widget.contentType.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          ],
    );
  }

}