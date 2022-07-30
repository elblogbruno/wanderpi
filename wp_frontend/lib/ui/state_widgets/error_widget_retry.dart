/* builds a widget for error handling */
import 'package:flutter/material.dart';
import 'package:wp_frontend/ui/state_widgets/base_design.dart';

class ErrorWidgetRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final ElevatedButton? secondaryButton;

  ErrorWidgetRetry({required this.error , required this.onRetry, this.secondaryButton});

  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      color: Colors.red,
      textColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            error,
            textAlign: TextAlign.center,
            style:  const TextStyle(
              color:  Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Retry'),
          ),
          if (secondaryButton != null)
            secondaryButton!,
        ],
      ),
    );
  }
}