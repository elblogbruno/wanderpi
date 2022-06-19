import 'package:flutter/material.dart';

import '../../const/design_globals.dart';
import '../../utils/utils.dart';

class ContextBar extends StatefulWidget  {
  final bool showBackButton;
  final bool? showBar;
  final bool? showContextButtons;
  final String? title;
  final String? subtitle;
  final Function? onBackPressed;

  final Widget child;

  const ContextBar({Key? key, required this.showBackButton, this.showContextButtons, this.subtitle, this.title, this.onBackPressed, required this.child, this.showBar}) :  super(key: key, );

  @override
  State<ContextBar> createState() => _ContextBarState();
}

class _ContextBarState extends State<ContextBar> {

  double distanceBetweenContextButtons = 3.0;


  bool showBar (){
    if (widget.showBar == null) {
      return true;
    }
    return widget.showBar!;
  }

  @override
  Widget build(BuildContext context) {

    String title = widget.title ?? "";
    String subtitle = widget.subtitle ?? "";

    Widget titleW = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (title.isNotEmpty)
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle.isNotEmpty)
        const VerticalDivider( width: 1, color: Colors.grey, ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
      ],
    );

    AppBar appBar = AppBar(
      elevation: 0.0,
      leading: widget.showBackButton ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: (){
          widget.onBackPressed!();
        },
      ) : null,
      title: titleW,
      actions: widget.showContextButtons ?? false ? _getActionButtons() : null,
    );


    return Scaffold(
      appBar: showBar() ? appBar : null,
      body: widget.child,
    );


    /*return
      Padding(padding: const EdgeInsets.all(5.0), child:
        Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          key: widget.key,
          height: 35,
          decoration: const BoxDecoration(
            color: Colors.white10, // Colors.black12, //Theme.of(context).colorScheme.surface,
            //color: Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(Globals.radius)),
          ),
          child: Padding(padding: const EdgeInsets.all(5.0), child: _buildContextButtons() ),
        ),
      );*/
  }

  bool showContextButtons() {
    if (widget.showContextButtons != null) {
      return widget.showContextButtons!;
    }
    return true;
  }

  List<Widget> _getActionButtons() {
    return [
        const VerticalDivider(),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {  },
        ),
        const VerticalDivider(),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {  },
        ),
    ];
  }


  Widget _buildContextButtons() {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        if (widget.showBackButton)
          ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Globals.radius),
            ),
            primary: Colors.blue,
          ),
          onPressed: ()  => widget.onBackPressed!(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ],
          ),
        ),
        if (widget.showBackButton)
           SizedBox(
            width: distanceBetweenContextButtons,
          ),
        if (widget.showBackButton)
          const VerticalDivider(
            color: Colors.black,
            thickness: 1,
          ),
        if (widget.showBackButton)
           SizedBox(
            width: distanceBetweenContextButtons,
          ),
        if (widget.title != null)
          Text(
            widget.title!,
            style: Theme.of(context).textTheme.headline6?.copyWith(
              color: Colors.black,
            ),
          ),
        if (widget.title != null)
           SizedBox(
            width: distanceBetweenContextButtons,
          ),
        if (widget.title != null)
          const VerticalDivider(
            color: Colors.black,
            thickness: 1,
          ),
        if (widget.title != null)
           SizedBox(
            width: distanceBetweenContextButtons,
          ),
        if (showContextButtons())
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Globals.radius),
            ),
            primary: Colors.blue,
          ),
          onPressed: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Icon(
                Icons.tag,
                color: Colors.white,
              ),
              /*SizedBox(
                width: 8,
              ),
              Text(
                'Tag',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),*/
            ],
          ),
        ),
        if (showContextButtons())
         SizedBox(
          width: distanceBetweenContextButtons,
        ),
        if (showContextButtons())
        const VerticalDivider(
          color: Colors.black,
          thickness: 1,
        ),
        if (showContextButtons())
         SizedBox(
          width: distanceBetweenContextButtons,
        ),
        if (showContextButtons())
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Globals.radius),
            ),
          ),
          onPressed: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
              ),
              /*SizedBox(
                width: 8,
              ),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),*/
            ],
          ),
        ),

      ],
    );
  }

  Widget _getChip(String text) {
    return Chip(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Globals.radius)),
      ),
      label: Text(text),
      backgroundColor: Utils().randomColor(),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      deleteIcon: Icon(
        Icons.close,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      onDeleted: () {},
    );
  }
}

