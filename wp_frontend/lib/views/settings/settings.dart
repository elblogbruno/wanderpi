/* settings screen with an input field and a button */
import 'package:flutter/material.dart';

import '../../api/shared_preferences.dart';

/* settings screen with an input field and a button */
class SettingsScreen extends StatefulWidget {
  final ValueChanged<String>? onSettingsSaved;

  const SettingsScreen({Key? key, this.onSettingsSaved}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

/* settings screen with an input field and a button */

  class _SettingsScreenState extends State<SettingsScreen> {
    final TextEditingController _serverUriText = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
        key: _formKey,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              const Text(
                'Server URI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a server URI";
                  }

                  if (!value.startsWith("http") && !value.startsWith("https")) {
                    return "Please enter a valid server URI";
                  }

                  if (!value.endsWith("/")) {
                    return "Please enter a valid server URI";
                  }

                  return null;
                },
                controller: _serverUriText,
                decoration: const InputDecoration(
                  labelText: "Server URI",
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: const Text("Save"),
                onPressed: () {

                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    SharedApi.saveServerUri(_serverUriText.text);

                    if (widget.onSettingsSaved != null) {
                      widget.onSettingsSaved!(_serverUriText.text);
                    }
                    else{
                      Navigator.pop(context);
                    }
                    // Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                  }

                },
              ),
            ],
          ),
        ),
        ),
        ),
      );
    }
  }