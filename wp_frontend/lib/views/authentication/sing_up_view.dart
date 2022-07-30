import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/main.dart';
import 'package:wp_frontend/models/user.dart';
import 'package:wp_frontend/ui/utils.dart';
import 'package:wp_frontend/views/authentication/upload_profile_picture_widget.dart';

import '../../models/token.dart';
import 'login_view.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', "US"),
        Locale('es', "ES"),
      ],
      debugShowCheckedModeBanner: false,
      title: 'NavigationRail Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: const ColorScheme.highContrastDark().copyWith(
          primary: Colors.red,
        ),
      ),
      home: I18n(
        child: SignUpScreen(),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<SignUpScreen> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  bool _showUploadWidget = false;
  late User currentUser;

  @override
  Widget build(BuildContext context) {

    List<Widget> children;
    

    
    children = <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Center(
          child: SizedBox(
              width: 100,
              height: 150,
              /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
              child: Image.asset('assets/images/memory_icon.png')),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          controller: _fullNameController,
          decoration: getInputDecoration('Full Name',
              hintText: 'Enter valid Name', icon: Icons.badge),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          controller: _usernameController,
          decoration: getInputDecoration('Username',
              hintText: 'Enter valid Username', icon: Icons.verified_user),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          controller: _emailController,
          decoration: getInputDecoration('Email',
              hintText: 'Enter valid Email', icon: Icons.email),
        ),
      ),
      Padding(
        padding:  const EdgeInsets.all(15.0),
        child: TextField(
          controller : _passwordController,
          obscureText: true,
          decoration: getInputDecoration('Password',
              hintText: 'Enter secure password', icon: Icons.lock),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextButton(
          onPressed: (){
            //TODO SIGN UP SCREEN GOES HERE
          },
          child: Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(20)),
            child: FlatButton(
              onPressed: () async {
                try {
                  User user = await Api.instance.authApiEndpoint().register(_usernameController.text,
                      _passwordController.text,
                      _emailController.text,
                      _fullNameController.text);

                  if (user != null) {
                    print("user is not null");
                    setState(() { _showUploadWidget = true; currentUser = user; });
                  }
                }
                catch (e) {
                  print(e);
                  showDialog(
                    context: context,
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
                    },
                  );
                }
              },

              child: const Text(
                'Register',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
        ),
      ),
    ];

    if (_showUploadWidget) {
      children = <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Center(
            child:
            UploadPictureWidget(
              onUserUpdated: (User value) {
                // show snack_bar with success message
                Scaffold.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Registered succesfully. You can login now!"),
                    duration: Duration(seconds: 2),
                  ),
                );


                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen(),
                  ),
                );
              }, currentUser: currentUser,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextButton(
            onPressed: (){
              //TODO SIGN UP SCREEN GOES HERE
            },
            child: Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: FlatButton(
                onPressed: () async {
                  try {
                    User user = await Api.instance.authApiEndpoint().register(_usernameController.text,
                        _passwordController.text,
                        _emailController.text,
                        _fullNameController.text);

                    if (user != null) {
                      setState(() { _showUploadWidget = false; });
                    }
                  }
                  catch (e) {
                    print(e);
                    showDialog(
                      context: context,
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
                      },
                    );
                  }
                },

                child: const Text(
                  'Upload Picture',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ),
        ),
      ];

    }

  
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: const Text("Signup Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}