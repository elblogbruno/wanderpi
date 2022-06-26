import 'package:flutter/material.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/ui/utils.dart';
import 'package:wp_frontend/utils/geo_utils.dart';

class NewStopDialog extends StatefulWidget  {

  final ValueChanged<Stop> onStopCreated;
  final Travel travel;
  const NewStopDialog({Key? key, required this.onStopCreated, required this.travel}) :  super(key: key, );

  @override
  State<NewStopDialog> createState() => _NewStopDialogState();
}

class _NewStopDialogState extends State<NewStopDialog> {

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
      title: Text('New Stop'),
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
    Stop stop = Stop(
      stopDescription: _descriptionEditingController.value.text,
      stopDateRangeEnd: range.start,
      stopDateRangeStart: range.end,
      stopDestinationName: _addressEditingController.value.text,
      stopLatitude: value[0],
      stopLongitude: value[1],
      stopName: _nameEditingController.value.text,
      stopId: 'demo',
      stopTravelId: widget.travel.id
    );

    widget.onStopCreated(stop);

    Navigator.of(context).pop();
  }


}

