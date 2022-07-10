/* builds a widget for loading data */
import 'package:flutter/material.dart';
import 'package:wp_frontend/ui/state_widgets/base_design.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseDesign(
        color: Colors.green,
        textColor: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
    );
  }
}

// Padding(
// padding: const EdgeInsets.only(top: 16),
// child: Text(Strings.waitText.i18n),
// ),