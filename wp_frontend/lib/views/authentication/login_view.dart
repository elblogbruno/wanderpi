import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/main.dart';
import 'package:wp_frontend/models/user.dart';
import 'package:wp_frontend/ui/utils.dart';

import '../../models/token.dart';

class Login extends StatelessWidget {
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
        child: LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginScreen> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: SizedBox(
                    width: 200,
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
                controller: _usernameController,
                decoration: getInputDecoration('Username',
                    hintText: 'Enter valid Username', icon: Icons.verified_user),
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
            TextButton(
              onPressed: (){
                //TODO FORGOT PASSWORD SCREEN GOES HERE
              },
              child: const Text(
                'Forgot Password',
                style: TextStyle(color: Colors.blue, fontSize: 15),
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
                        Token token = await Api().login(_usernameController.text, _passwordController.text);

                        if (token.access_token != null) {
                          User user = await Api().getUser();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MainScreen(user: user, title: 'Home',),
                            ),
                          );
                        }
                      }
                      catch (e) {
                        print(e);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text( e.toString()),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Close"),
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
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 130,
            ),
            const Text('New User? Create Account')
          ],
        ),
      ),
    );
  }
}