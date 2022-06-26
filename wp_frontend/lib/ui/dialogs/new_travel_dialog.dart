import 'package:flutter/material.dart';
import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/models/user.dart';
import 'package:wp_frontend/utils/geo_utils.dart';

class NewTravelDialog extends StatefulWidget  {

  final ValueChanged<Travel> onTravelCreated;
  final User currentUser;

  const NewTravelDialog({Key? key, required this.onTravelCreated, required this.currentUser}) :  super(key: key, );

  @override
  State<NewTravelDialog> createState() => _NewTravelDialogState();
}

class _NewTravelDialogState extends State<NewTravelDialog> {

  String _selectedDate = '';
  late DateTimeRange range;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _addressEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();





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
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              TextFormField(
                decoration: getInputDecoration('Travel Name', hintText: 'Enter Travel Name', icon: Icons.drive_file_rename_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Travel Name';
                    }
                    return null;
                  },
                  controller: _nameEditingController
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: getInputDecoration('Travel Destination', hintText: 'Enter Travel Destination', icon: Icons.location_on),
                controller: _addressEditingController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Travel Destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: getInputDecoration('Travel Description', hintText: 'Enter Travel Description', icon: Icons.location_on),
                controller: _descriptionEditingController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Travel Description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: getInputDecoration('Travel Date', hintText: 'Enter Travel Date', icon: Icons.calendar_today),
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
                      range = picked;
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
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {

            // Validate returns true if the form is valid, or false otherwise.
            if (_formKey.currentState!.validate()) {
              processForm();
            }

          },
        ),
      ],
    );

  }


  void processForm()
  {
    // If the form is valid, display a snackbar. In the real world,
    // you'd often call a server or save the information in a database.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing Data')),
    );

    getLatLongFromAddress(
        _addressEditingController.value.text).then((value) =>
        {
            addTravel(value)
        }
    );

  }

  void addTravel(List<double> value)
  {
        Travel travel = Travel(
          travelDescription: _descriptionEditingController.value.text,
          travelDateRangeEnd: range.start,
          travelDateRangeStart: range.end,
          address: _addressEditingController.value.text,
          latitude: value[0],
          longitude: value[1],
          name: _nameEditingController.value.text,
          id: 'demo',
          user_created_by: widget.currentUser,
          creation_date: DateTime.now(),
          last_update_date: DateTime.now(),

        );

        widget.onTravelCreated(travel);

        Navigator.of(context).pop();
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

