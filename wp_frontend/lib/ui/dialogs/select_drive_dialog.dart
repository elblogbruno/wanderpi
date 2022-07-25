import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/api/api.dart';

import 'package:wp_frontend/const/design_globals.dart';
import 'package:wp_frontend/models/drive.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/models/user.dart';
import 'package:wp_frontend/ui/grid/base_grid.dart';
import 'package:wp_frontend/ui/state_widgets/base_future_builder.dart';
import 'package:wp_frontend/utils/geo_utils.dart';

class SelectDriveDialog extends StatefulWidget  {

  final ValueChanged<Drive> onDriveSelected;

  const SelectDriveDialog({Key? key, required this.onDriveSelected}) :  super(key: key, );

  @override
  State<SelectDriveDialog> createState() => _SelectDriveDialogState();
}

class _SelectDriveDialogState extends State<SelectDriveDialog> {

  Widget buildDriveCard(Drive drive) {
    return Card(
      child: ListTile(
        title: Text(drive.memoryAccessUri),
        subtitle: Text(drive.memoryType),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {
          onSelect(drive);
        },
      ),
    );
  }

  List<Widget> buildDriveCardListFromList(List<Drive> drives) {
    return drives.map((drive) => buildDriveCard(drive)).toList();
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog (
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Globals.radius) ,
      ),
      title: const Text('Select drive to upload files'),
      content: SizedBox(
        height: 300.0, // Change as per your requirement
        width: double.maxFinite,
        child: BaseFutureBuilder<List<Drive>>(
              calculation: Api.instance.driveApiEndpoint().getDrives(),
              builder: (context, drives) {
                if (drives!.isEmpty) { // if there are no stops or if there are already stops in the list, show the list
                  return const Text('No drives found');
                }
                // we get them from the server and show them
                return getCustomScrollView(context, buildDriveCardListFromList(drives)); // if there are no stops, show the add more card
              },
            )
        ),
    );

  }


  void onSelect(Drive drive)
  {
    widget.onDriveSelected(drive);

    Navigator.of(context).pop();
  }
}

