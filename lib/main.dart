import 'package:Locato/Pages/GroupPage.dart';
import 'package:Locato/DatabaseHelper.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'Background/NotificationHelperBackground.dart';
import 'MainClasses.dart';
import 'Pages/AddUpdatePages.dart';
import 'Pages/Calendar.dart';
import 'Pages/HomePage.dart';


void main() async {
  // TestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper();
  await NotificationHelperBackground.init();
 await AndroidAlarmManager.initialize();
  runApp(MyApp());
//   await AndroidAlarmManager.cancel(0);
  await AndroidAlarmManager.periodic(const Duration(seconds: 5), 2, checkLocationRadius);
//  await AndroidAlarmManager.cancel(2);
  DateTime today = DateTime.now();
  DateTime start = DateTime(today.year,today.month,today.day,6,0,0);
  await AndroidAlarmManager.periodic(Duration(days: 1), 1, updateDataOnThisDay,startAt: start);
}

class MyApp extends StatelessWidget {

  /// This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locato',
      theme: ThemeData(
          primarySwatch: Colors.grey,
          appBarTheme: AppBarTheme(color: Color(0xFF332F53)),
          accentColor: Colors.amberAccent,
          canvasColor: Color.fromRGBO(51, 47, 83, 1),
          bottomAppBarColor: Color(0xFF333366),
          brightness: Brightness.dark,
          primaryTextTheme:
              TextTheme(title: TextStyle(color: Colors.amberAccent))),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  ///Controller of tab bar menu in AppBar.
  TabController _tabController;

  ///Controller of page view of app.
  PageController _pageController;

  ///Stores a value if current page is eligmate to change. Protects from conflicts between TabController and PageController.
  var pageCanChange = true;

  @override
  void initState() {
    // Definicja kontrolera tabbar
    _tabController = new TabController(initialIndex: 1, length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        print("Index Taba " + _tabController.index.toString());
        onPageChange(_tabController.index, p: _pageController);
      }
    });
    _pageController = PageController(
      initialPage: 1,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Zmienna szerokosci ekranu dla TabBaru
    ///Stores value of UI layout setting for tab bar.
    var screenWidthTabBar = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      ///Builds main top bar of application.
      ///Provides quick navigation menu between pages: callendar, events and tasks.
      appBar: AppBar(
          //title: Text("Locato"),
          leading: GestureDetector(
            onTap: () {},
            //child: Icon(Icons.menu),
          ),
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF534B83), const Color(0xFF332F53)],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
                stops: [0.0, 0.7],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size(screenWidthTabBar, 5.0),
            child: new Container(
              width: screenWidthTabBar,
              child: new TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Color(0xff00c6ff),
                controller: _tabController,
                tabs: <Widget>[
                  new Container(
                    height: 40.0,
                    child: new Tab(
                      text: "Kalendarz".toUpperCase(),
                    ),
                  ),
                  new Container(
                    height: 40.0,
                    child: new Tab(text: "Tydzień".toUpperCase()),
                  ),
                  new Container(
                    height: 40.0,
                    child: new Tab(text: "Grupy".toUpperCase()),
                  ),
                ],
              ),
            ),
          )),

      ///Builds a main menu button, where is menu navigation.
      ///Menu options are to add event/task.
      floatingActionButton: GestureDetector(
        onLongPress: (){
         // print("Long 2 press");
          LocalizationHelper.resetAllStatus();
        },
        child: SpeedDial(
          elevation: 10.0,
          animatedIcon: AnimatedIcons.add_event,
          animatedIconTheme: IconThemeData(size: 22.0),
          closeManually: false,
          overlayColor: Colors.black,
          backgroundColor: Color(0xFF444477),
          overlayOpacity: 0.5,
          onOpen: () => print('Otwieram Dial na Tasks'),
          onClose: () => print('Zamykam Dial na Tasks'),
          heroTag: 'speed-dial-hero-tag',
          children: [
            ///Takes user to add event page.
            SpeedDialChild(
                child: Icon(Icons.event_note),
                backgroundColor: Color(0xFF444477),
                label: 'Wydarzenie',
                labelStyle: TextStyle(color: Colors.grey[900], fontSize: 18.0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEvent(),
                    ),
                  );
                }),

            ///Takes user to add task page.
            SpeedDialChild(
                child: Icon(Icons.check_box),
                backgroundColor: Color(0xFF444477),
                label: 'Zadanie',
                labelStyle: TextStyle(color: Colors.grey[900], fontSize: 18.0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTask(),
                    ),
                  );
                  setState(() {});
                },
                ),
//          SpeedDialChild(
//            child: Icon(Icons.data_usage),
//            label: 'DB',
//            labelStyle: TextStyle(color: Colors.grey[900], fontSize: 18.0),
//            onTap: () {
//              DatabaseHelper.instance.showalltables();
//              print("lol");
//            },
//          ),
          ],
        ),
      ),

      ///Builds main body of application with page view.
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          if (pageCanChange) {
            onPageChange(page);
          }
          //_tabController.animateTo(page);
        },
        children: <Widget>[
          Calendar(),
          HomePageEvents(),
          GroupTaskPage(),
        ],
      ),
    );
  }

  ///Used to prevent conficts of two navigation methods.
  ///If user decides to scroll from right to left or from left to right, it blocks usage of tab bar until animations ends.
  onPageChange(int index, {PageController p, TabController t}) async {
    // Obsluga PageControllera
    if (p != null) {
      pageCanChange = false;
      await _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
      pageCanChange = true;
    } else {
      // Obsluga TabControllera
      _tabController.animateTo(index);
    }
  }
}

///Used to check location radius of 200 meters.
///If user is nearby of defined localization of some task's will be notified.
void checkLocationRadius() async {
  List<Localization> _listloc = List();

  double dist;
  Position pos;
  int distance = 200;
  DatabaseHelper();
  NotificationHelperBackground.init();

  pos = await Geolocator().getCurrentPosition();
  print("Obecna lokalizacja: " + pos.toString());

  // DownloadData
  _listloc.addAll(await LocalizationHelper.lists());
  _listloc.removeWhere((l) => l.id == 0);
  //Notifications_helper_background.now("TEST", pos.toString());
  if(_listloc.isNotEmpty){
    print("Length list loc: ${_listloc.length}");

    for(Localization loc in _listloc){
      loc.isNearBy = false;

        dist = await Geolocator().distanceBetween(loc.latitude, loc.longitude, pos.latitude, pos.longitude);
        print("Dystans pomiedzy punktami " + dist.toString());

      if (dist < distance) {
        List<Task> _listtask = List();
        loc.isNearBy = true;
        _listtask.addAll(await TaskHelper.listsIDLocal(loc.id));

        if (_listtask.isNotEmpty && (loc.wasNotified == false)) {
          String title = "Na :${loc.street}  '${loc.name}'";
          String decription = (_listtask.length == 1) ? "Masz do zrobienia: ${_listtask.length} zadanie":
                              (_listtask.length < 5) ? "Masz do zrobienia: ${_listtask.length} zadania":
                              "Masz do zrobienia: ${_listtask.length} zadań";

          //"Odleglosc od miesca: $dist m\n";
          print("LocID ${loc.id}");
          print("List of Task: ${_listtask.length}");

          _listtask.forEach((t) => print("TaskName: ${t.name}"));

          loc.wasNotified = true;
          await NotificationHelperBackground.now(title, decription);
        }
      }
      LocalizationHelper.updateStatus(loc);
    }
  }
}

updateDataOnThisDay() async {
  DatabaseHelper();
  TaskHelper.deleteDoneTaskToday();
  LocalizationHelper.resetAllStatus();
}
