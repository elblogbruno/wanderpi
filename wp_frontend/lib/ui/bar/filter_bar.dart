import 'package:flutter/material.dart';

import '../../const/design_globals.dart';
import '../../utils/utils.dart';

class FilterBar extends StatefulWidget  {
  const FilterBar({Key? key}) :  super(key: key);

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.key,
      height: 120,
      color: Theme.of(context).colorScheme.surface, // Colors.black12, //Theme.of(context).colorScheme.surface,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: ListView.separated(
                controller: ScrollController(), //just add this line
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    width: 8,
                  );
                },
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (_, i) => _getChip('Filter $i'),
              ),
            ),
          ),
          /* Verticall Line  of button height */
          const Divider(
            thickness: 0.1,
            color: Colors.white,
          ),
          /* Button */
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _getButtons(),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }

  Widget _getButtons() {
    return Row(
      children: <Widget>[
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
              SizedBox(
                width: 8,
              ),
              Text(
                'Tag',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 8,
        ),
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
              SizedBox(
                width: 8,
              ),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

