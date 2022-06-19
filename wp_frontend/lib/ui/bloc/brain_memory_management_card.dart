/* Creates a rounded box that holds a title and image */
import 'package:wp_frontend/const/content_type.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:flutter/material.dart';

class BrainMemoryManagementCard extends StatefulWidget{
  const BrainMemoryManagementCard({Key? key}) :  super(key: key);



  @override
  State<BrainMemoryManagementCard> createState() => _BrainMemoryManagementCardState();

}

class _BrainMemoryManagementCardState extends State<BrainMemoryManagementCard> {

  @override
  Widget build(BuildContext context) {
    /* Card that holds the image and text and has bottom buttons*/
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Globals.radius),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: const <Widget>[
                        Text(
                          'Memory Management',
                          style: TextStyle(
                            fontSize: Globals.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Learn how to manage your memory',
                          style: TextStyle(
                            fontSize: Globals.fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/memory_icon.png',
                    height: Globals.imageHeight,
                    width: Globals.imageWidth,
                  ),
                ],
              ),
              /*child: Row(
                children: <Widget>[
                  const Text(
                    'Memory Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Memory Management'),
                            content: const Text('This section will help you to manage your memory.\n\n'
                                'You can use the following buttons to manage your memory:\n\n'
                                '- Add a new memory\n'
                                '- Delete a memory\n'
                                '- Edit a memory\n'
                                '- View all memories\n\n'
                                'You can also use the search bar to find memories.'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),*/
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Add a new memory',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    //Navigator.pushNamed(context, '/add_memory', arguments: ContentType.memory);
                  },
                ),
              ],
            ),
    ),
    ],
    )
    );
  }

}