/* Creates a rounded box that holds a title and image */
import 'package:wp_frontend/const/content_type.dart';
import 'package:flutter/material.dart';

import '../const/design_globals.dart';

class NotificationView extends StatefulWidget{
  const NotificationView({Key? key}) :  super(key: key);



  @override
  State<NotificationView> createState() => _NotificationViewState();

}

class _NotificationViewState extends State<NotificationView> {

  @override
  Widget build(BuildContext context) {
    /* Creates a list view of notifications */
    return ListView(
      controller: ScrollController(), //just add this line
      children: <Widget>[
        /* Creates a notification with a title and image */
        notificationCard (
          title: "New Message",
          image: "assets/images/memory_icon.png",
          content: "You have a new message from John Doe",
        ),

        notificationCard (
          title: "New Message",
          image: "assets/images/memory_icon.png",
          content: "You have a new message from John Doe",
        ),
      ],
    );
  }

  Widget notificationCard({required String title, required String image, required String content}){
    /* Creates a rounded box that holds a title and image */
    return Container(
      margin: const EdgeInsets.all(Globals.radius),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(Globals.radius),
      ),
      child: Row(
        children: <Widget>[
          /* Creates an image */
          Image.asset(
            image,
            width: 100,
            height: 100,
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Colors.white,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /* Creates a title */
              Text(
                title,
                style: Theme.of(context).textTheme.headline6,
              ),
              /* Creates a content */
              Text(
                content,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Colors.white,
          ),
          /* Creates a delete button */
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: (){},
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

}