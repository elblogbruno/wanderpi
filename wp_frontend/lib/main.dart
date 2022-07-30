
import 'package:wp_frontend/api/api.dart';
import 'package:wp_frontend/api/shared_preferences.dart';
import 'package:wp_frontend/locales/main.i18n.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/models/user.dart';
import 'package:wp_frontend/models/wanderpi.dart';
import 'package:wp_frontend/resources/strings.dart';
import 'package:wp_frontend/ui/bar/filter_bar.dart';
import 'package:wp_frontend/ui/bar/corner_profile_picture.dart';
import 'package:wp_frontend/ui/bar/floating_action_button.dart';
import 'package:wp_frontend/ui/bar/nav_rail.dart';


import 'package:wp_frontend/ui/grid/stop_grid.dart';
import 'package:wp_frontend/ui/grid/travel_grid.dart';
import 'package:wp_frontend/ui/grid/wanderpi_grid.dart';
import 'package:wp_frontend/ui/state_widgets/base_future_builder.dart';

import 'package:wp_frontend/ui/state_widgets/loading_widget.dart';
import 'package:wp_frontend/ui/state_widgets/error_widget_retry.dart';

import 'package:wp_frontend/views/authentication/login_view.dart';
import 'package:wp_frontend/views/calendar/calendar_view.dart';
import 'package:wp_frontend/views/document_vault_view.dart';
import 'package:wp_frontend/views/global_map.dart';

import 'package:flutter/material.dart';
import 'package:wp_frontend/views/settings/settings.dart';
import 'package:wp_frontend/views/single_wanderpi.dart';
import 'package:wp_frontend/views/slide_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';

// function to validate a url string
bool isValidUrl(String? url) {
  if (url == null)
  {
    print("url is null");
    return false;
  }

  // RegExp regex = RegExp(
  //     r"^(http(s)?:\/\/)?((w{3}\.)?)?([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\.)+[a-zA-Z]{2,}(\/[^\s]*)?$");
  //
  // return regex.hasMatch(url);

  return  Uri.tryParse(url)?.hasAbsolutePath ?? false;
}

void init(String serverUri, String? token){
  Api api = Api(serverUri);

  if (token != null) {
    print('Token: $token');

    MyApp app = MyApp(
      child: MainScreen(title: 'Navigation Rail Demo', token: token, serverUri: serverUri),
    );

    runApp(app);
  } else {
    print('No token found');

    MyApp app = MyApp(
      child: LoginScreen(),
    );

    runApp(app);
  }
}

void openSettings(String? token) {
  void _onSettingsSaved(String apiUrl)
  {
    init(apiUrl, token);
  }

  MyApp app = MyApp(
    child: SettingsScreen(
        onSettingsSaved: _onSettingsSaved
    ),
  );

  runApp(app);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TranslationData translations = TranslationData();
  await translations.initTranslations();

  String? token = await  SharedApi.getToken();

  String? serverUri = await SharedApi.getServerUri();

  print("Token: $token");
  print("ServerUri: $serverUri");
  //await SharedApi.deleteUser();
  //await SharedApi.deleteToken();

  if (isValidUrl(serverUri) == false) {
    print("Server URI is null or invalid");

    openSettings(token);

    return;
  }

  init(serverUri!, token);

}

class MyApp extends StatelessWidget {
  final Widget child;

  const MyApp({Key? key, required this.child}) : super(key: key);


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
          child:  child
      ),
    );
  }


}

class MainScreen extends StatefulWidget {
  final String title;
  final String? token;
  final String? serverUri;

  const MainScreen({Key? key, required this.title,  this.token, this.serverUri}) : super(key: key);

  @override
  State<MainScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainScreen> {
  static const int TRAVEL_GRID = 0;
  static const int MAP_VIEW = 1;
  static const int SLIDE_VIEW = 2;
  static const int CALENDAR_VIEW = 3;
  static const int DOCUMENT_VAULT_VIEW = 4;

  late String token;

  int _currentIndex = 0;

  bool _gridView = false;

  bool _travelOpened = false;

  late Widget currentGrid;
  late Widget currentCalendarWidget;
  late Widget currentMapWidget;
  late Widget currentVaultWidget;

  late Widget _lastStopGrid;
  late Widget _lastWanderpiGrid;

  late Travel _lastTravel;

  late User? _user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showContextBar = false;

  void _toggleContextBar() {
    setState(() {
      _showContextBar = !_showContextBar;
    });
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState!.openEndDrawer();

    setState(() {
      _showContextBar = true;
    });
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();

    setState(() {
      _showContextBar = false;
    });
  }

  static const _actionTitles = [ 'Download ', 'Map', 'Slide', 'Calendar' ];

  Future _showAction(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_actionTitles[index]),
          content:  Text('This is a $_actionTitles[index].'),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetMapView() {
    currentMapWidget = GlobalMapView(onBackPressed: () { _goHome(); } );
  }

  void _resetTravelGrid() {
    print('Reset travel grid');

    currentGrid = TravelGrid(onTravelSelected: _onTravelSelected, currentUser: _user!,);
    _travelOpened = false;

  }

  void _goHome(){
    setState(() {
      _currentIndex = 0;
    });
  }

  void _resetCalendarView() {
    print('reset calendar view');
    currentCalendarWidget =  CalendarView(travel: null, onBackPressed: () { _goHome(); } ,);
  }

  void _resetVaultView() {
    print('reset calendar view');
    currentVaultWidget = DocumentVaultView(travel:null, onBackPressed: ()  { _goHome(); },);
  }

  void _onWanderpiSelected(Wanderpi wanderpi) {
    print('wanderpi selected');

    void _onBackPressed() {
      setState(() {
        currentGrid = _lastWanderpiGrid;
      });
    }

    setState (() {
      currentGrid = SingleWanderpiView(wanderpi: wanderpi, onBackPressed: _onBackPressed);
    });

  }

  void _onStopSelected(Stop stop) {
    print('Stop selected: $stop');

    void _onBackPressed() {
      print('back pressed');
      setState(() {
        currentGrid = _lastStopGrid;
      });
    }

    setState(() {
      _lastStopGrid = currentGrid;
      currentGrid = WanderpiGrid(user: _user!, travel: _lastTravel, stop: stop, onWanderpiSelected: _onWanderpiSelected, onBackPressed: _onBackPressed,);
      _lastWanderpiGrid = currentGrid;
    });
  }

  void _onTravelSelected(Travel travel) {
    print('Selected travel: ${travel.name}');

    setState(() {
      currentGrid = StopGrid(currentUser: _user!, travel: travel, onStopSelected: _onStopSelected, onBackPressed: () { setState(() { _resetTravelGrid(); } ); } ,);

      print('current grid: ${currentGrid.runtimeType}');


      currentCalendarWidget = CalendarView(travel: travel,
        onBackPressed: () {
          _goHome();
        },);

      print('current calendar widget: ${currentCalendarWidget.runtimeType}');

      currentMapWidget = GlobalMapView(travel: travel, onBackPressed: () { _goHome(); } ,);
      currentVaultWidget = DocumentVaultView(travel: travel, onBackPressed: ()  { _goHome(); },);

      _lastStopGrid = currentGrid;
      _lastTravel = travel;


      _travelOpened = true;
    });

  }


  @override
  void initState() {
    super.initState();
    _user = null;
    token = widget.token!;

    //_resetTravelGrid();
    _resetCalendarView();
    _resetMapView();
    _resetVaultView();
  }

  Widget _buildNavRail(User user) {
    return NavRail(
      scaffoldKey: _scaffoldKey,
      drawerHeaderBuilder: (context) {
        return Column(
          children:  <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture:  CornerProfilePicture(radius: 0.5, userAvatarUrl: user.avatar_url,),
              accountName: Text(user.full_name),
              accountEmail: Text(user.email),
            ),
            //BrainMemoryManagementCard(),
          ],
        );
      },
      drawerFooterBuilder: (context) {
        return Column(
          children:  <Widget>[
            ListTile(
              leading: Icon(Icons.storage),
              title: Text("Memory Management"),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                try{
                  await  Api.instance.authApiEndpoint().logout();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                } catch(e){
                  print(e);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("About"),
            ),
          ],
        );
      },
      currentIndex: _currentIndex,
      onTap: (val) {
        if (mounted) {
          setState(() {
            _currentIndex = val;

            // we reset the grid to the default when we switch to the default tab
            if (val == TRAVEL_GRID) {
              _resetTravelGrid();
            }

            // we reset the calendar view when we switch to the calendar tab
            if (val == CALENDAR_VIEW && _travelOpened == false) {
              _resetCalendarView();
            }

            if(val == MAP_VIEW && _travelOpened == false) {
              _resetMapView();
            }

            if(val == DOCUMENT_VAULT_VIEW && _travelOpened == false) {
              _resetVaultView();
            }

          });
        }
      },
      title: Text(widget.title),
      actions:  <Widget>[
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            /* Open a right drawer */
            _toggleContextBar();
          },
        ),
        IconButton(
          icon: const Icon(Icons.grid_view),
          onPressed: () {
            _gridView = !_gridView;
          },
        ),
      ],
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          //const ContextBar(),
          Stack(
            children:  <Widget>[
              currentGrid,
              if (_showContextBar)
                FilterBar(),
            ],
          ),
          // filter main grid by context
          Stack(
            children:   <Widget>[
              currentMapWidget,
              if (_showContextBar)
                FilterBar(),
            ],
          ),
          Stack(
            children:   <Widget>[
              SlideView(),
              if (_showContextBar)
                FilterBar(),
            ],
          ),
          Stack(
            children:   <Widget>[
              currentCalendarWidget,
              if (_showContextBar)
                FilterBar(),
            ],
          ),
          Stack(
            children:   <Widget>[
              currentVaultWidget,
              if (_showContextBar)
                FilterBar(),
            ],
          ),
        ],
      ),
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => _showAction(context, 0),
            icon: const Icon(Icons.file_download, color: Colors.white),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 1),
            icon: const Icon(Icons.file_upload, color: Colors.white),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 2),
            icon: const Icon(Icons.insert_photo, color: Colors.white),
          ),
          /*ActionButton(
            onPressed: () => _showAction(context, 4),
            icon: const Icon(Icons.add_location, color: Colors.white),
          ),*/
        ],
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add new',
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Globals.radius),
        ),
      ),*/
      tabs: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          label: 'Home',
          icon: Icon(Icons.home_filled),
        ),
        BottomNavigationBarItem(
          label: 'Map View',
          icon: Icon(Icons.map_outlined),
        ),
        BottomNavigationBarItem(
          label: 'Slide View',
          icon: Icon(Icons.slideshow),
        ),
        BottomNavigationBarItem(
          label: 'Costs View',
          icon: Icon(Icons.account_balance_wallet),
        ),
        BottomNavigationBarItem(
          label: 'Document Vault',
          icon: Icon(Icons.card_travel),
        ),
      ],
      endDrawerBuilder: (BuildContext context) {
        return Drawer(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('This is the Drawer'),
                ElevatedButton(
                  onPressed: _closeEndDrawer,
                  child: const Text('Close Drawer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  late Future<User?> _calculation = Api.instance.authApiEndpoint().validateToken(token);

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<User?>(
      future: _calculation, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            _user = snapshot.data!;

            if (_user == null) {
              SharedApi.deleteToken();

              print('Invalid token found');

              MyApp app = MyApp(
                child: LoginScreen(),
              );

              runApp(app);
            }

            if (_travelOpened == false) {
              _resetTravelGrid();
            }

            print('User: ${_user?.full_name}');

            return _buildNavRail(_user!);
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
              secondaryButton: ElevatedButton(
                onPressed: () {
                  openSettings(token);
                },
                child: const Text('Change Server Url'),
              ),
              onRetry: () =>
                  setState(() {
                    print('Retrying');
                    _calculation =  Api.instance.authApiEndpoint().validateToken(token);
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
