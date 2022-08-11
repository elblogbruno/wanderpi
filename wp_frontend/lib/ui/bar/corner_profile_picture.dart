// create a corner profile picture

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wp_frontend/api/api.dart';
import 'package:path/path.dart';

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
    final bool isNetworkImage = widget.userAvatarUrl.contains('file/image');

    print('isNetworkImage: $isNetworkImage');
    print('userAvatarUrl: ${widget.userAvatarUrl}');

    String apiUrl = Api.instance.API_BASE_URL;
    // remove the last / from the apiUrl
    apiUrl = apiUrl.substring(0, apiUrl.length - 1);


    // if (isNetworkImage) {
      String avatarUrl = apiUrl + widget.userAvatarUrl;
      print( 'avatarUrl: $avatarUrl');

      // return Container(
      //   width: widget.radius * 2,
      //   height: widget.radius * 2,
      //   decoration: BoxDecoration(
      //     shape: BoxShape.circle,
      //     image: DecorationImage(
      //       image: NetworkImage(avatarUrl),
      //       fit: BoxFit.cover,
      //     ),
      //   ),
      // );
    // } else {
    //   return Container(
    //     width: widget.radius * 2,
    //     height: widget.radius * 2,
    //     decoration: BoxDecoration(
    //       shape: BoxShape.circle,
    //       image: DecorationImage(
    //         image: AssetImage(widget.userAvatarUrl),
    //         fit: BoxFit.cover,
    //       ),
    //     ),
    //   );
    // }

    return CircleAvatar(
      backgroundImage: NetworkImage(avatarUrl),
      radius: widget.radius,
    );
  }
}