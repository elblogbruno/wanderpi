import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

Widget getCustomScrollView(BuildContext context, List<Widget> children) {
  int crossAxisCount = getCrossAxisCount(context);
  print("Column number: $crossAxisCount");

  return
    //Expanded(child:
      CustomScrollView(
        shrinkWrap: true,
        controller: ScrollController(keepScrollOffset: false),
        slivers: [
          // some slivers
          SliverToBoxAdapter(child: getLayout(context, crossAxisCount, children)),
          // other slivers
        ]
      );
    //);
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