// create a corner profile picture

import 'package:flutter/material.dart';

class CornerProfilePicture extends StatefulWidget {
  final String userAvatarUrl;
  final double radius;

  const CornerProfilePicture({Key? key, required this.userAvatarUrl, required this.radius}) : super(key: key);



  @override
  State<CornerProfilePicture> createState() => _CornerProfilePictureState();
}

class _CornerProfilePictureState extends State<CornerProfilePicture> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: AssetImage(widget.userAvatarUrl),
      radius: widget.radius,
    );
  }
}