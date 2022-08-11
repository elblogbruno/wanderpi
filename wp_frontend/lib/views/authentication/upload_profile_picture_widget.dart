import 'dart:io';

//import 'package:file_selector/file_selector.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/models/user.dart';


class UploadPictureWidget extends StatefulWidget {
  final User currentUser;
  final ValueChanged<User> onUserUpdated;

  const UploadPictureWidget({Key? key, required this.currentUser, required this.onUserUpdated}) :  super(key: key);

  @override
  _UploadPictureWidgetState createState() => _UploadPictureWidgetState();
}

class _UploadPictureWidgetState extends State<UploadPictureWidget> {

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text(
        'UPLOAD PICTURE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      onPressed: () async {
        final XTypeGroup typeGroup = XTypeGroup(
          label: 'images',
          extensions: <String>['jpg', 'png'],
        );

        // check if we are on windows or not
        final bool isWindows = Platform.isWindows;
        String filePath = '';
        String imageType = '';
        // if we are on windows, use the windows file selector
        if (isWindows) {
            print('Using windows file selector');
            // get the file
            final pickerWindows = OpenFilePicker()
              ..filterSpecification = {
                'Images (*.jpg, *.png)': '*.jpg;*.png',
              }
              ..defaultFilterIndex = 0
              ..defaultExtension = 'jpg'
              ..title = 'Select a profile Picture';

            final result = pickerWindows.getFile();

            if (result != null) {
              filePath = result.path;

            }
        }
        else{
          final XFile? file;
          file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
          filePath = file!.path;
        }

        if (filePath.endsWith('.jpg')) {
          imageType = 'jpeg';
        } else if (filePath.endsWith('.png')) {
          imageType = 'png';
        } else {
          print('File type not supported');
          throw Exception('File type not supported');
        }

        try {
          final User? user = await Api.instance.authApiEndpoint()
              .uploadProfilePicture(widget.currentUser.id, filePath, imageType);

          print('User updated');

          if (user != null) {
            widget.onUserUpdated(user);
          }

        } catch (e) {
          print(e);
          showDialog(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Error"),
                  content: Text( e.toString()),
                  actions: <Widget>[
                    FlatButton(
                      child: const Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              }
          );
        }
      },
    );
  }
}