import 'package:Locato/Pages/AddUpdatePages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../MainClasses.dart';
import '../DatabaseHelper.dart';

///Stores state of HomePage class, if changed rebuild widget.
_HomePageEventsState homePageEventsState;

class HomePageEvents extends StatefulWidget {
  @override
  _HomePageEventsState createState() {
    homePageEventsState = _HomePageEventsState();
    return homePageEventsState;
  }
}

class _HomePageEventsState extends State<HomePageEvents> {
  ///Stores the names of weekdays in Polish.
  static final List<String> listOfDays = [
    "Poniedziałek",
    "Wtorek",
    "Środa",
    "Czwartek",
    "Piatek",
    "Sobota",
    "Niedziela"
  ];

  ///Stores a number of week's day, where 0 is current day.
  int day;

  ///Stores a list of objects of Event class.
  List<Event> list;

  ///Stores value of UI layout.
  double heightExtededAppBar = 200.0;
  //ScrollController _scrollController;

  ///Stores value of UI layout.
  double heightImportantEvent = 80.0;

  ///Stores value of UI layout.
  double widthImportantEvent = 100.0;

  ///Stores a DateTime object.
  DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    list = List();
    day = DateTime.now().day;
  }

  ///Return a Polish name of given day.
  String getDay(int day) {
    //print(_date.timeZoneOffset);
    int val = (_date.weekday + day -1 ) % 7;
    return listOfDays[val];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: EventHelper.lists(),
      builder: (ctxt, userData) {
        ///Connects to database and download list of events.
        switch (userData.connectionState) {
          case ConnectionState.none:
          // return Container();
          case ConnectionState.waiting:
          // return Container();
          case ConnectionState.active:
          case ConnectionState.done:
            list = userData.data;
            if (list != null) {
              ///Stores the list of lists of events.
              List<List<Event>> listaList = new List.generate(7, (i) => []);

              for (Event item in list) {
                if ((item.beginTime.day == _date.day) && (item.beginTime.month == _date.month) && (item.beginTime.year == _date.year)) {
                  listaList[0].add(item);
                }
                if ((item.beginTime.day == day + 1) && (item.beginTime.month == _date.month) && (item.beginTime.year == _date.year)) {
                  listaList[1].add(item);
                }
                if ((item.beginTime.day == day + 2) && (item.beginTime.month == _date.month) && (item.beginTime.year == _date.year)) {
                  listaList[2].add(item);
                }
                if ((item.beginTime.day == day + 3) && (item.beginTime.month == _date.month) && (item.beginTime.year == _date.year)) {
                  listaList[3].add(item);
                }
                if ((item.beginTime.day == day + 4) && (item.beginTime.month == _date.month) && (item.beginTime.year == _date.year)) {
                  listaList[4].add(item);
                }
                if ((item.beginTime.day == day + 5) && (item.beginTime.month == _date.month) && (item.beginTime.year == _date.year)) {
                  listaList[5].add(item);
                }
                if ((item.beginTime.day == day + 6) && (item.beginTime.month == _date.month) && (item.beginTime.year == _date.year)) {
                  listaList[6].add(item);
                }
              }

              return CustomScrollView(
                //controller: _scrollController,
                slivers: <Widget>[
                  SliverList(
                    ///Builds a list of all events divided in days of incoming week, where single day is declared as EventCard class.
                    delegate: SliverChildBuilderDelegate(
                        (context, index) => EventCard(
                              getDay(index),
                              listaList[index],
                            ),
                        childCount: 7),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: 80,),
                    ]
                    ),
                  )
                ],
              );
            } else {
              //return Center(child: Text("zero"));
            }
        }

        return Container();

//
      },
    );
  }

  refresh() => setState(() {});
}


class EventCard extends StatelessWidget {
  ///Stores a Polish name of day.
  String day;

  ///Stores a list of events for given day.
  List<Event> events;

  EventCard(this.day, this.events);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Odstep miedzy dniami
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      decoration: new BoxDecoration(
        color: new Color(0xFF333366),
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: new Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Divider(
            color: Colors.black12,
            height: 0.5,
          ),
          _buildContent(),
          Divider(
            color: Colors.black12,
            height: 0.5,
          ),
        ],
      ),
    );
  }

  ///Builds a content of the day's event card.
  ///Starting with the header and then if not empty - list of the events for given day.
  Widget _buildContent() {
    return Container(
      margin: new EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 16.0),
      //constraints: new BoxConstraints.expand(),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          EventCardHeader(day: day),
          SizedBox(height: 10.0),
          Container(
            margin: new EdgeInsets.symmetric(vertical: 8.0),
            height: 2.0,
            width: 20.0,
            color: new Color(0xff00c6ff),
          ),
          if (events.isNotEmpty) EventCardEvents(events),
        ],
      ),
    );
  }
}


class EventCardEvents extends StatefulWidget {
  EventCardEvents(this.events);

  ///Stores the list of the events for given day.
  List<Event> events;

  @override
  _EventCardEventsState createState() => _EventCardEventsState();
}

class _EventCardEventsState extends State<EventCardEvents> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
//        SizedBox(height: 8.0),
//        Text(
//          "Wydarzenia",
//          style: TextStyle(
//              color: Color(0xffb6b2df),
//              fontFamily: 'Poppins',
//              fontSize: 9.0,
//              fontWeight: FontWeight.w400),
//        ),
        SizedBox(height: 8.0),
        Divider(color: Colors.black54, height: 0.5),

        ///Builds a list of day's events, where single event is defined in EventCardItem class.
        for (var event in widget.events)
          EventCardItem(
            event,

            ///Takes user to page to edit selected event.
            onPressedEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateEvent(event: event),
                ),
              );
            },

            ///Deletes selected event from list and database as well.
            onPressedDelete: () {
              //TODO: DELETE FROM LIST OR DB
              EventHelper.delete(event.id);
              widget.events.remove(event);
              //setState(() {});
              homePageEventsState.refresh();
            },
          ),
      ],
    );
  }
}


class EventCardHeader extends StatelessWidget {
  const EventCardHeader({Key key, this.day}) : super(key: key);

  ///Store a Polish name of the day.
  final String day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ///Builds a name of the day sectore, where list of events will be stored.
        Text(
          day,
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 18.0,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class EventCardItem extends StatefulWidget {
  @override
  _EventCardItemState createState() => _EventCardItemState();

  EventCardItem(Event event, {this.onPressedEdit, this.onPressedDelete}) {
    this.name = event.name;
    this.eventStart = DateFormat("HH:mm").format(event.beginTime);
   // print(eventStart);
    this.eventEnd = DateFormat("HH:mm").format(event.endTime);
   // print(eventStart);
    this.description = event.description;
    //this.is_cyclic
    //this.cycle
    //this.color
  }
  //final Event event;

  ///Stores name of a event.
  String name;

  ///Stores a date when the events starts.
  String eventStart;

  ///Stores a date when the event ends.
  String eventEnd;

  ///Stores a cycle of the event.
  String cycle;

  ///Stores a true value if event is cyclic, false if otherwise.
  bool is_cyclic;

  ///Stores a description of the event.
  String description;

  ///Stores colour of a event.
  Color color;

  ///Stores declaration of function, responsible to take user to edit page.
  final Function onPressedEdit;

  ///Stores declaration of function responsible for deletion of event.
  final Function onPressedDelete;
}

class _EventCardItemState extends State<EventCardItem> {
  @override
  Widget build(BuildContext context) {
    ///Builds a ExpansionTile.
    ///Initially it shows only name and date of event.
    ///On expanded shows event description and buttons to edit or delete event.
    return ListTileTheme(
      contentPadding: EdgeInsets.all(0),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Icon(Icons.event),
              ],
            ),
            SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Nazwa wydarzenia
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Czas wydarzenia
                Text(
                  widget.eventStart + " - " + widget.eventEnd,
                  style: TextStyle(
                    color: Color(0xffb6b2df),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: <Widget>[
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Szczegóły:",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                "Opcje:",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.description,
                    size: 18.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      widget.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  ///Builds a edit button.
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: widget.onPressedEdit,
                  ),
                  SizedBox(width: 4.0),

                  ///Builds a delete button.
                  IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: widget.onPressedDelete),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
