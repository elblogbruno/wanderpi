import 'package:flutter/material.dart';
import 'package:wp_frontend/const/design_globals.dart';

class NewTravelDialog extends StatefulWidget  {

  const NewTravelDialog({Key? key}) :  super(key: key, );

  @override
  State<NewTravelDialog> createState() => _NewTravelDialogState();
}

class _NewTravelDialogState extends State<NewTravelDialog> {

  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';




  @override
  Widget build(BuildContext context) {

    return AlertDialog (
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Globals.radius) ,
      ),
      title: Text('New Travel'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              TextFormField(
                decoration: getInputDecoration('Travel Name', hintText: 'Enter Travel Name', icon: Icons.drive_file_rename_outline),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: getInputDecoration('Travel Destination', hintText: 'Enter Travel Destination', icon: Icons.location_on),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: getInputDecoration('Travel Destination', hintText: 'Enter Travel Destination', icon: Icons.calendar_today),
                controller:  TextEditingController(text: _selectedDate),
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    lastDate: DateTime(2100),
                    firstDate : DateTime(DateTime.now().year),
                  );
                  if (picked != null && picked != null) {
                    print(picked);
                    setState(() {
                      _selectedDate = picked.toString();

                    });
                  }
                },
              ),

            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Save'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

  }

  InputDecoration getInputDecoration(String labelText, {String hintText = '', IconData? icon = Icons.location_on}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Globals.radius),
      ),
      icon: Icon(icon),
    );
  }
}

