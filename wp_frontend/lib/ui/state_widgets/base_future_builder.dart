import 'package:flutter/material.dart';
import 'package:i18n_extension/default.i18n.dart';
import 'package:wp_frontend/resources/strings.dart';
import 'package:wp_frontend/ui/state_widgets/error_widget_retry.dart';
import 'package:wp_frontend/ui/state_widgets/loading_widget.dart';
import 'package:wp_frontend/views/authentication/login_view.dart';

class BaseFutureBuilder<T> extends StatefulWidget
{
  // calculation to get the data
  final Future<T> calculation;

  // widget to show when the data has been loaded
  final Widget Function(BuildContext context, T? data) builder;

  const BaseFutureBuilder({Key? key, required this.calculation, required this.builder}) :  super(key: key);

  @override
  State<BaseFutureBuilder<T>> createState() => _BaseFutureBuilderState<T>();
}

class _BaseFutureBuilderState<T> extends State<BaseFutureBuilder<T>> {

  late Future<T> _calculation;

  @override
  void initState() {
    super.initState();
    _calculation = widget.calculation;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _calculation, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return widget.builder(context, snapshot.data);
          } else if (snapshot.hasError) {
            print('ERROR : ${snapshot.error}');

            if (snapshot.error == Strings.noAuthException.i18n) {
              // log out
              print('No auth exception');
              // wait some time before redirecting to login page
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              });
            }

            return ErrorWidgetRetry(
                  error: snapshot.error.toString(),
                  onRetry: () =>
                      setState(() {
                        print('Retrying');
                        _calculation = widget.calculation;
                      }
                      ),
            );
          }
        }

        return LoadingWidget();
      },
    );
  }
  }