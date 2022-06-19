import 'package:wp_frontend/const/design_globals.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String hint;
  final Function(String?)? onChanged;
  final Function(String?)? onSubmitted;
  final Function? onClear;
  final Function? onCancel;
  final Size preferredSize;

  const SearchBar({
    Key? key,
    required this.hint,
    required this.preferredSize,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onCancel,
  }) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();

}

class _SearchBarState extends State<SearchBar> {

  @override
  Widget build(BuildContext context) {
    return Center(
        child:Container(
      width: widget.preferredSize.width,
      height: widget.preferredSize.height,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: TextField(
          decoration: createDecorator(widget.hint),
          autocorrect: true,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
      ),
        )
    );
  }

  InputDecoration createDecorator(String? hint) {
    return InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(Globals.radius),
          ),
          /*borderSide: BorderSide(
            color: Colors.red,
            width: 25.0,
          ),*/

        ),
        filled : true,
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: const Icon(Icons.camera_alt, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}