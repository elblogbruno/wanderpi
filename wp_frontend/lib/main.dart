import 'package:wp_frontend/const/content_type.dart';
import 'package:wp_frontend/const/design_globals.dart';
import 'package:wp_frontend/models/stop.dart';
import 'package:wp_frontend/models/travel.dart';
import 'package:wp_frontend/models/wanderpi.dart';
import 'package:wp_frontend/ui/bar/filter_bar.dart';
import 'package:wp_frontend/ui/bar/corner_profile_picture.dart';
import 'package:wp_frontend/ui/bar/floating_action_button.dart';
import 'package:wp_frontend/ui/bar/nav_rail.dart';
import 'package:wp_frontend/ui/bloc/brain_memory_management_card.dart';
import 'package:wp_frontend/ui/bloc/wanderpi_card.dart';
import 'package:wp_frontend/ui/dialogs/new_travel_dialog.dart';
import 'package:wp_frontend/ui/grid/main_grid.dart';
import 'package:wp_frontend/ui/grid/stop_grid.dart';
import 'package:wp_frontend/ui/grid/travel_grid.dart';
import 'package:wp_frontend/ui/grid/wanderpi_grid.dart';
import 'package:wp_frontend/views/calendar/calendar_view.dart';
import 'package:wp_frontend/views/document_vault_view.dart';
import 'package:wp_frontend/views/global_map.dart';
import 'package:wp_frontend/views/notification.dart';
import 'package:flutter/material.dart';
import 'package:wp_frontend/views/single_wanderpi.dart';
import 'package:wp_frontend/views/slide_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const MyHomePage(title: 'Navigation Rail Demo'),
    );
  }

  ThemeData _theme(ThemeData base) {
    return ThemeData(
      primarySwatch: Colors.blue,
      appBarTheme: base.appBarTheme.copyWith(elevation: 0.0),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        elevation: 2.0,
        backgroundColor: base.colorScheme.secondary,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int TRAVEL_GRID = 0;
  static const int MAP_VIEW = 1;
  static const int SLIDE_VIEW = 2;
  static const int CALENDAR_VIEW = 3;
  static const int DOCUMENT_VAULT_VIEW = 4;

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

  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return NewTravelDialog();
      },
    );
  }

  void _resetMapView() {
    currentMapWidget = GlobalMapView(onBackPressed: () { _goHome(); } );
  }

  void _resetTravelGrid() {
    print('Reset travel grid');

    currentGrid = TravelGrid(onTravelSelected: _onTravelSelected,);
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
      currentGrid = WanderpiGrid(travel: _lastTravel, stop: stop, onWanderpiSelected: _onWanderpiSelected, onBackPressed: _onBackPressed,);
      _lastWanderpiGrid = currentGrid;
    });
  }

  void _onTravelSelected(Travel travel) {
    print('Selected: ${travel.travelName}');

    setState(() {
      currentGrid = StopGrid(travel: travel, onStopSelected: _onStopSelected, onBackPressed: () { setState(() { _resetTravelGrid(); } ); } ,);

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



  void initState() {
    super.initState();

    _resetTravelGrid();
    _resetCalendarView();
    _resetMapView();
    _resetVaultView();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return NavRail(
      scaffoldKey: _scaffoldKey,
      drawerHeaderBuilder: (context) {
        return Column(
          children: const <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: CornerProfilePicture(radius: 0.5, userAvatarUrl: 'assets/images/profile.jpg',),
              accountName: Text("Steve Jobs"),
              accountEmail: Text("jobs@apple.com"),
            ),
            //BrainMemoryManagementCard(),
          ],
        );
      },
      drawerFooterBuilder: (context) {
        return Column(
          children: const <Widget>[
            ListTile(
              leading: Icon(Icons.storage),
              title: Text("Memory Management"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
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
          ActionButton(
            onPressed: () => _showAction(context, 4),
            icon: const Icon(Icons.add_location, color: Colors.white),
          ),
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
}