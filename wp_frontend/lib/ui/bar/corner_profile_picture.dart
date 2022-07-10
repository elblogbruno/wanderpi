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
    final bool isNetworkImage = widget.userAvatarUrl.contains('http');

    if (isNetworkImage) {
      return Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(widget.userAvatarUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(widget.userAvatarUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    /*return CircleAvatar(
      backgroundImage: widget.isNetworkImage ? NetworkImage(widget.userAvatarUrl) : AssetImage(widget.userAvatarUrl),
      radius: widget.radius,
    );*/
  }
}