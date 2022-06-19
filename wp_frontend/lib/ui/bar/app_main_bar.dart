import 'package:wp_frontend/const/design_globals.dart';
import 'package:wp_frontend/ui/search/bar/search_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppMainBar extends StatefulWidget with PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  final Size preferredSize;

  const AppMainBar({Key? key, required this.title, this.actions, required this.automaticallyImplyLeading}) : preferredSize = const Size.fromHeight(50.0),  super(key: key);



  @override
  State<AppMainBar> createState() => _AppMainBarState();

}

class _AppMainBarState extends State<AppMainBar> {
  @override
  Widget build(BuildContext context) {
    // return AppBar(
    //   title: widget.title,
    //   actions: widget.actions,
    //   automaticallyImplyLeading: widget.automaticallyImplyLeading,
    //   shape: const RoundedRectangleBorder(
    //       borderRadius: BorderRadius.only(
    //           topRight: Radius.circular(15),
    //       ),
    //   ),
    // );

    return AppBar(
      title: SearchBar(hint: 'Search on your brain', preferredSize: widget.preferredSize, onChanged: onChanged,),
      actions: widget.actions,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(Globals.radius),
        ),
      ),
    );
  }

  Function onChanged(String? value) {
    if (value == null) {
      throw Exception('value is null');
    }

    return () {
      print('value: $value');
      // show toast message

    };
  }
}