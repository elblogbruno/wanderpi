/* create a grid of buttons */

/* Creates a rounded box that holds a title and image */
import 'dart:io';

import 'package:wp_frontend/const/content_type.dart';
import 'package:wp_frontend/ui/bloc/content_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class MainGrid extends StatefulWidget{
  final ContentType? filter;
  const MainGrid({Key? key, this.filter}) :  super(key: key);

  @override
  State<MainGrid> createState() => _MainGridState();
}

class _MainGridState extends State<MainGrid> {
  @override
  Widget build(BuildContext context) {
    var children = <Widget> [];

    for (int i = 0; i < 10; i++) {
      if (ContentType.values[i % ContentType.values.length] == widget.filter || widget.filter == null) {
        children.add(
            ContentCard(
            title: 'Title $i',
            image: 'assets/images/profile.jpg', contentType: ContentType.values[i %  ContentType.values.length],
        ));
      }
      /*else{
        children.add(
            Container(
          color: Colors.grey,
        ));
      }*/

    }

    int crossAxisCount = getCrossAxisCount(context);
    print("Column number: " + crossAxisCount.toString());
    //Theme.of(context).colorScheme.background.withOpacity(0.7)
    return  Container(
      //color: Theme.of(context).colorScheme.background.withOpacity(0.7),
      child: Padding(
      padding: const EdgeInsets.all(10.0),
      child:  CustomScrollView(
            shrinkWrap: true,
            slivers: [
              // some slivers
              SliverToBoxAdapter(child: getLayout(context, crossAxisCount, children)),
              // other slivers
            ]
        ),
      ),
    );
  }


  LayoutGrid getLayout(BuildContext context, int crossAxisCount, List<Widget> children) {
    return LayoutGrid(
        // set some flexible track sizes based on the crossAxisCount
        columnSizes: crossAxisCount == 2 ? [2.fr] : [1.fr, 1.fr, 1.fr, 1.fr],
        // set all the row sizes to auto (self-sizing height)
        rowSizes: crossAxisCount == 2
            ? const [auto, auto, auto, auto, auto, auto, auto, auto, auto, auto]
            : const [auto, auto, auto, auto],

        rowGap: 20, // equivalent to mainAxisSpacing
        columnGap: 20, // equivalent to crossAxisSpacing
        // note: there's no childAspectRatio
        children: children
    );
  }

  int getCrossAxisCount(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;
    var orientation = MediaQuery.of(context).orientation;
    var crossAxisCount = orientation == Orientation.portrait ? 2 : 4;

    if (width > height) {
      crossAxisCount = orientation == Orientation.portrait ? 2 : 4;
    }

    return crossAxisCount;
    // calculate the cross axis count so the card width is always cardWidth
    //return (MediaQuery.of(context).size.width / cardWidth).floor();
  }
}