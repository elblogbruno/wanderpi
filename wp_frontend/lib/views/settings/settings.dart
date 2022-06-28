/* settings screen with an input field and a button */
import 'package:flutter/material.dart';

import '../../api/shared_preferences.dart';

/* settings screen with an input field and a button */
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

/* settings screen with an input field and a button */

  class _SettingsScreenState extends State<SettingsScreen> {
    final TextEditingController _serverUriText = TextEditingController();

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
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
              RaisedButton(
                child: const Text("Save"),
                onPressed: () {
                  SharedApi.saveServerUri(_serverUriText.text);
                },
              ),
            ],
          ),
        ),
      );
    }
  }