import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:throttling/throttling.dart';
import 'package:http/http.dart' as http;

import '../MainClasses.dart';
import '../DatabaseHelper.dart';

class AddEvent extends StatefulWidget {

  @override
  AddEventState createState() {
    addEventState = AddEventState();
    return addEventState;
  }

  State addEventState;
  AddEvent();
}

class AddEventState extends State<AddEvent> {

  ///Stores user's input in a TextFormField.
  TextEditingController _controllerName;

  ///Stores user's input in a TextFormField.
  TextEditingController _controllerDesc;

  ///Individual key for a Form widget, used to validate user's input.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ///Stores current date;
  DateTime _today;

  ///Stores event's date.
  DateTime _date;

  ///Stores event's starting time.
  DateTime _time1;

  ///Stores event's end time.
  DateTime _time2;

  ///Stores color of a button displaying event's date.
  Color _dateColor;

  ///Stores color of a button displaying event's starting time.
  Color _time1Color;

  ///Stores color of a button displaying event's end time.
  Color _time2Color;

  ///Object of an Event class.
  Event _event;

  ///Default value is false, changes after user picks a date.
  bool isDateSelected;

  ///Default value is false, changes after user picks an event's starting time.
  bool isTime1Selected;

  ///Default value is false, changes after user picks an event's end time.
  bool isTime2Selected;

  @override
  void initState() {
    _event = Event();
    _today = DateTime.now();
    _controllerName = TextEditingController();
    _controllerDesc = TextEditingController();
    _dateColor = Colors.white;
    _time1Color = Colors.white;
    _time2Color = Colors.white;

     _time1 = DateTime.now();
     _date =  DateTime.now();
     _time2 = DateTime.now().add(Duration(hours: 1));
    
    isDateSelected = false;
    isTime1Selected = false;
    isTime2Selected = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dodaj wydarzenie',
          style: TextStyle(color: Colors.white),
        ),

        ///Builds a go Back button.
        leading:
        new IconButton(icon: Icon(Icons.arrow_back), onPressed: goBack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              buildSpace(),
              buildCustomTextFieldwithValidation("Nazwa",
                  "Wprowadź nazwę swojego wydarzenia", _controllerName),
              buildSpace(),
              buildCustomButtonWithValidation(
                  _dateColor,
                  (isDateSelected)
                      ? DateFormat("dd/MM/yyyy").format(_date)
                      : "Nie wybrano daty",
                  Icons.date_range,
                  datePick,
                  buildClearButton(clearDate)),
              buildSpace(),
              buildCustomButtonWithValidation(
                  _time1Color,
                  (isTime1Selected)
                      ? DateFormat("HH:mm").format(_time1)
                      : "Nie wybrano godziny rozpoczęcia",
                  Icons.access_time,
                  startTimePick,
                  buildClearButton(clearTime1)),
              buildSpace(),
              buildCustomButtonWithValidation(
                  _time2Color,
                  (isTime2Selected)
                      ? DateFormat("HH:mm").format(_time2)
                      : "Nie wybrano godziny zakończenia",
                  Icons.access_time,
                  endTimePick,
                  buildClearButton(clearTime2)),
              buildSpace(),
              buildCustomButton(
                  ((_event.listNotifi).isEmpty)
                      ? "Nie wybrano powiadomień"
                      : ((_event.listNotifi).length == 1)
                      ? "Wybrano ${(_event.listNotifi).length} powiadomienie"
                      : ((_event.listNotifi).length < 5)
                      ? "Wybrano ${(_event.listNotifi).length} powiadomienia"
                      : ((_event.listNotifi).length < 21)
                      ? "Wybrano ${(_event.listNotifi).length} powiadomień"
                      : ((_event.listNotifi).length % 10 == 2 ||
                      (_event.listNotifi).length % 10 == 3 ||
                      (_event.listNotifi).length % 10 == 4 )
                      ? "Wybrano ${(_event.listNotifi).length} powiadomienia"
                      : "Wybrano ${(_event.listNotifi).length} powiadomień",
                  Icons.notifications,
                  goToNotificationPickPage,
                  buildClearButton(clearNotifiList)),
              buildSpace(),
              buildCustomTextField("Opis", "Wpisz opis swojego wydarzenia",
                  "Pole jest opcjonalne", _controllerDesc),
              buildSpace(),
              buildButtonBar(),
            ],
          ),
        ),
      ),
    );
  }

  ///Builds a TextFormField with a validation.
  ///Checks if user did fill the field.
  ///On empty field returns a message.
  Widget buildCustomTextFieldwithValidation(

      ///Stores text shown on the label of a TextFormField.
      String label,

      ///Stores text shown inside the TextFormField as a hint.
      String hint,

      ///Used to control user's input.
      TextEditingController control) {
    return TextFormField(
        controller: control,
        decoration: new InputDecoration(
            filled: true,
            fillColor: new Color(0xFF333366),
            enabledBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white)),
            border: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
            hintText: hint,
            suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  control.clear();
                })),
        keyboardType: TextInputType.text,
        validator: (val) {
          if (val.isEmpty) {
            return 'Pole nie może być puste!';
          }
          return null;
        });
  }

  ///Builds a TextFormField without validation.
  Widget buildCustomTextField(

      ///Stores text shown on the label of a TextFormField.
      String label,

      ///Stores text shown inside TextFormField as a hint.
      String hint,

      ///Stores text shown under TextFormField as an extra information.
      String helper,

      ///Used to control user's input.
      TextEditingController control) {
    return TextFormField(
      controller: control,
      decoration: new InputDecoration(
          filled: true,
          fillColor: new Color(0xFF333366),
          enabledBorder: new OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white)),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          hintText: hint,
          helperText: helper,
          helperStyle: TextStyle(color: Colors.white),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                control.clear();
              })),
      keyboardType: TextInputType.text,
    );
  }

  ///Builds a space between widgets in a column.
  Widget buildSpace() {
    return SizedBox(
      height: 10.0,
    );
  }
  ///Builds a button with validation.
  Widget buildCustomButtonWithValidation(

      ///Stores a color of text inside the button.
      ///Depends on validation result.
      Color textcolor,

      ///Stores text shown inside the button.
      String text,

      ///Stores icon shown before text inside the button.
      IconData icon,

      ///Accpets void function which is going to get used after button pressed.
      GestureTapCallback onPressed,

      ///Widget of a button responsible for clearing user's input.
      Widget clearButton) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20.0,
                  color: textcolor,
                ),
                Text(
                  " $text",
                  style: TextStyle(
                    color: textcolor,
                  ),
                ),
              ],
            ),
            clearButton,
          ],
        ),
      ),
      color: Color(0xFF333366),
    );
  }

  ///Builds a button without validation.
  Widget buildCustomButton(

      ///Stores text shown inside the button.
      String text,

      ///Stores icon shown before text inside the button.
      IconData icon,

      ///Receives void function which is going to get used after button pressed.
      GestureTapCallback onPressed,

      ///Widget of a button responsible for clearing user's input.
      Widget clearButton) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20.0,
                ),
                Text(
                  " $text",
                  style: TextStyle(),
                ),
              ],
            ),
            clearButton,
          ],
        ),
      ),
      color: Color(0xFF333366),
    );
  }

  ///Builds a row with two buttons inside of it.
  Widget buildButtonBar() {
    return ButtonBar(
        children: [
          buildButtonBarTile("Anuluj", Colors.red, goBack),
          SizedBox(
            width: 30,
          ),
          buildButtonBarTile(
              "Dodaj", Colors.lightGreenAccent, acceptAndValidate),
        ],
        alignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        buttonMinWidth: 150);
  }

  ///Builds a button for a button bar.
  Widget buildButtonBarTile(
      ///Stores text shown inside a button.
      String text,

      ///Stores color of a button.
      ///Changing on button press.
      Color color,

      ///Receives a void function which is getting used after button pressed.
      GestureTapCallback onPressed) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      color: Color(0xFF333366),
      splashColor: color,
      child: Text("$text"),
      onPressed: onPressed,
    );
  }

  ///Builds a button responsible for clearing data.
  Widget buildClearButton(

      ///Receives a void function which is getting used after button pressed.
      GestureTapCallback onPressed) {
    return SizedBox(
      width: 30,
      child: IconButton(
        color: Colors.white,
        icon: Icon(Icons.clear),
        onPressed: onPressed,
      ),
    );
  }

  ///Erases date of an event which user already picked.
  void clearDate() {
    isDateSelected = false;
    setState(() {});
  }

  ///Clears starting time of an event which user already picked.
  void clearTime1() {
    isTime1Selected = false;
    setState(() {});
  }

  ///Clears end time of an event which user already picked.
  void clearTime2() {
    isTime2Selected = false;
    setState(() {});
  }

  ///Clears list of notifications which user already picked.
  void clearNotifiList() {
    (_event.listNotifi).clear();
    setState(() {});
  }

  ///Builds interface responsible for picking a date.
  void datePick() {
    DatePicker.showDatePicker(context,
        theme: DatePickerTheme(
          backgroundColor: Colors.black38,
          itemStyle: TextStyle(color: Colors.white),
          cancelStyle: TextStyle(color: Colors.red),
          doneStyle: TextStyle(color: Colors.green[400]),
          containerHeight: 210.0,
        ),
        showTitleActions: true,
        minTime: DateTime(2020, 1, 1),
        maxTime: DateTime(2025, 12, 31), onConfirm: (date) {
          isDateSelected = true;
          _date = date;
          setState(() {});
        }, currentTime: _date,
        locale: LocaleType.pl
    );
  }

  ///Builds interface responsible for picking a starting time.
  void startTimePick() {
    DatePicker.showTimePicker(context,
        theme: DatePickerTheme(
          backgroundColor: Colors.black38,
          itemStyle: TextStyle(color: Colors.white),
          cancelStyle: TextStyle(color: Colors.red),
          doneStyle: TextStyle(color: Colors.green),
          containerHeight: 210.0,
        ),
        showSecondsColumn: false,
        showTitleActions: true, onConfirm: (time) {
          isTime1Selected = true;
          _time1 = time;
          setState(() {});
        }, currentTime: _time1,
    );
    setState(() {});
  }

  ///Builds interface responsible for picking an end time.
  void endTimePick() {
    DatePicker.showTimePicker(context,
        theme: DatePickerTheme(
          backgroundColor: Colors.black38,
          itemStyle: TextStyle(color: Colors.white),
          cancelStyle: TextStyle(color: Colors.amber[400]),
          doneStyle: TextStyle(color: Colors.green[400]),
          containerHeight: 210.0,
        ),
        showTitleActions: true,
        showSecondsColumn: false, onConfirm: (time) {
          print('confirm $time');
          isTime2Selected = true;
          _time2 = time;
          setState(() {});
        },
        currentTime: _time2,
        locale: LocaleType.pl);
    setState(() {});
  }

  ///Takes user to previous page.
  void goBack() {
    Navigator.pop(context);
  }

  ///Takes user to notification pick page.
  void goToNotificationPickPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddNotificationEvent(_event,widget.addEventState)));
  }

  ///Validates user's input.
  ///If accepted adds new Event.
  void acceptAndValidate() {
    if (isTime1Selected && isTime2Selected && _time2.isBefore(_time1)) {
      print("ERROR");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Błąd danych"),
              content:
              Text("Godzina zakończenia nie może być przed rozpoczęciem."),
            );
          });
    } else {
      if (_formKey.currentState.validate()) {
        if (isDateSelected && isTime1Selected && isTime2Selected) {
          _dateColor = Colors.white;
          _time1Color = Colors.white;
          _time2Color = Colors.white;

          _event.name = _controllerName.value.text;
          _event.description = _controllerDesc.text;
          _event.beginTime = DateTime(_date.year, _date.month, _date.day, _time1.hour, _time1.minute);
          _event.endTime = DateTime(_date.year, _date.month, _date.day, _time2.hour, _time2.minute);

          List<Notifi> listN  = List();
          listN.addAll( _event.listNotifi);

          for(Notifi element in listN){
            if(_event.beginTime.subtract(element.duration).isBefore(_today)){
              print("delete: ${_event.beginTime.subtract(element.duration)}");
              _event.listNotifi.remove(element);
            }
          }

          EventHelper.add(_event).then((value) => Navigator.of(context).pop());

        } else {
          if (isDateSelected == false)
            _dateColor = Colors.red;
          else
            _dateColor = Colors.white;
          if (isTime1Selected == false)
            _time1Color = Colors.red;
          else
            _time1Color = Colors.white;
          if (isTime2Selected == false)
            _time2Color = Colors.red;
          else
            _time2Color = Colors.white;
          setState(() {});
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Brak danych"),
                  content: Text("Wprowadź niezbędne dane"),
                );
              });
        }
      }
    }
  }
}

class AddGroup extends StatefulWidget {
  @override
  _AddGroupState createState() => _AddGroupState();

  ///An object of a Task class.
  Task task;

  ///List of a groups created by user.
  List<Group> listOfGroup;

  State stateOfParent;

  AddGroup(this.task, this.listOfGroup,this.stateOfParent);
}

class _AddGroupState extends State<AddGroup> {
  ///Individual key for a Form widget, used to validate user's input.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ///Stores user's input in a TextFormField.
  final _text = TextEditingController();

  ///Stores list of groups from data base.
  List<Group> downloadlist;

  ///Stores list of groups created by user on a group pick page.
  List<Group> list;

  @override
  void initState() {
    downloadlist = List();
    list = List();
    _downloadData();

    super.initState();
  }

  ///Downloads list of groups from data base.
  void _downloadData() {
    GroupHelper.lists().then((onList) {
      if (onList != null) {
        downloadlist = onList;

        if (0 != widget.task.group.id) {
          list.add(widget.task.group);
        }
        downloadlist.removeAt(0);
        downloadlist.forEach((g) {
          if (g.id != widget.task.group.id) {
            list.add(g);
          }
        });

        if (widget.listOfGroup.isNotEmpty) {
          list.addAll(widget.listOfGroup);
        }

        setState(() {});
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dodaj grupę", style: TextStyle(color: Colors.white)),
        leading:
        new IconButton(icon: Icon(Icons.arrow_back), onPressed: goBack),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(children: <Widget>[
            buildSpace(),
            Form(
                key: _formKey,
                child: buildCustomTextFieldwithValidation(
                    "Nowa Grupa", "Wprowadź nazwę nowej grupy", _text)),
            buildSpace(),
            buildCustomButton("Dodaj", add),
            buildSpace(),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.5,
              child: ListView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                buildListTileWithText(list[index].name),
                                buildRemoveButton(index),
                              ],
                            ),
                            color: list[index].isSelected
                                ? Color(0xFF333366)
                                : Colors.transparent,
                            onPressed: () => select(index),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            buildSpace(),
            buildCustomButton("Potwierdź", goBack),
          ])),
    );
  }

  ///Builds a field with a text inside of it.
  Widget buildListTileWithText(String _text) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(" $_text"),
        ],
      ),
    );
  }

  ///Builds a TextFormField with a validation.
  ///Checks if user did fill the field.
  ///On empty field returns a message.
  Widget buildCustomTextFieldwithValidation(

      ///Stores text shown on the label of a TextFormField.
      String label,

      ///Stores text shown inside the TextFormField as a hint.
      String hint,

      ///Used to control user's input.
      TextEditingController control) {
    return TextFormField(
        controller: control,
        decoration: new InputDecoration(
            filled: true,
            fillColor: Color(0xFF333366),
            enabledBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white)),
            border: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white),
            suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  control.clear();
                })),
        keyboardType: TextInputType.text,
        validator: (val) {
          if (val.isEmpty) {
            return 'Pole nie może być puste!';
          }
          return null;
        });
  }

  ///Builds a button to remove a group from list.
  Widget buildRemoveButton(

      ///Stores id of a list element.
      int _index) {
    return SizedBox(
      width: 30,
      child: IconButton(
        color: Colors.white,
        icon: Icon(Icons.clear),
        onPressed: () {
          if (list[_index].id != null) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Uwaga"),
                    content: Text(
                        "Usuniecie tego rekordu doprowadzi do przeniesienia innych zadan do 'Brak Grupy'"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          GroupHelper.deleteAndReplaceIdTask(list[_index].id);
                          removeFromList(_index);
                        },
                      ),
                      FlatButton(
                        child: Text("Anuluj"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          } else {
            removeFromList(_index);
          }
        },
      ),
    );
  }

  ///Builds a button used to display every group created by user.
  Widget buildCustomButton(

      ///Stores a text displayed inside the button.
      String text,

      ///Receives a void function which is getting used after button pressed.
      GestureTapCallback onPressed) {
    return RaisedButton(
      color: new Color(0xFF333366),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        '$text',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  ///Builds a space between widgets in a column.
  Widget buildSpace() {
    return SizedBox(
      height: 10.0,
    );
  }

  ///Takes user to previous page.
  void goBack() {
    widget.listOfGroup.clear();
    list.forEach((g) {
      print("id: ${g.id.toString()} added: ${g.name} bool: ${g.isSelected}");
      if (g.id == null && g.isSelected == false) {
        widget.listOfGroup.add(g);
        print(g.name);

      }
    });

    widget.stateOfParent.setState((){});
    Navigator.pop(context);
  }

  ///Adds a new group with a name typed by user.
  void add() {
    if (_formKey.currentState.validate()) {
//      GroupHelper.add(new Group(name: _text.text));
//      _text.clear();
//      setState(() {});
      list.add(Group(name: _text.text, isSelected: false));
      setState(() {});
    }
  }

  ///Removes an element from a list.
  void removeFromList(

      ///Stores id of a list element.
      int _index) {
    list.removeAt(_index);
    setState(() {});
  }

  ///Marks elemnt from a list choosen by user.
  void select(

      ///Stores id of a list element.
      int _index) {
    if (list[_index].isSelected == true) {
      list[_index].isSelected = false;
      widget.task.group = Group(id: 0);
    } else {
      list.forEach((g) => g.isSelected = false);
      list[_index].isSelected = true;
      widget.task.group = list[_index];
    }

    setState(() {});
  }
}


class AddLocalization extends StatefulWidget {
  @override
  _AddLocalizationState createState() {
    addLocalizationState = _AddLocalizationState();
    return addLocalizationState;
  }

  ///Element of a Task class.
  Task task;
  State stateOfParent;
  State addLocalizationState;

  ///List of localizations which will be added to a task.
  List<Localization> listOfLocal;

  ///Adds localization.
  AddLocalization(this.task, this.listOfLocal,this.stateOfParent);

}

class _AddLocalizationState extends State<AddLocalization> {
  ///List of localizations created by user.
  List<Localization> localizationlist;

  ///List of localizations from data base.
  List<Localization> downloadlist;

  @override
  void initState() {
    localizationlist = List();
    downloadlist = List();
    _downloadData();

    super.initState();
  }

  ///Downloads list of a localistions from data base.
  void _downloadData() {
    LocalizationHelper.lists().then((onList) {
      if (onList != null) {
        downloadlist = onList;

        if (0 != widget.task.localization.id) {
          localizationlist.add(widget.task.localization);
        }
        downloadlist.removeAt(0);
        downloadlist.forEach((l) {
          if (l.id != widget.task.localization.id) {
            localizationlist.add(l);
          }
        });

        if (widget.listOfLocal.isNotEmpty) {
          localizationlist.addAll(widget.listOfLocal);
        }

        setState(() {});
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dodaj Lokalizację",
          style: TextStyle(color: Colors.white),
        ),
        leading:
        new IconButton(icon: Icon(Icons.arrow_back), onPressed: goBack),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(children: <Widget>[
            buildCustomButton("Nowa lokalizacja", goToLocationPickPage),
            buildSpace(),
            SizedBox(height: MediaQuery.of(context).size.height*0.6, child: buildList()),
            buildSpace(),
            buildCustomButton("Potwierdź", goBack),
          ])),
    );
  }

  ///Builds a Listview with a tiles containing every localization created by user.
  Widget buildList() {
    return new ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: localizationlist.length,
        itemBuilder: (context, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text(
                              " " + localizationlist[index].name.toString()),
                        ),
                        buildRemoveButton(index),
                      ]),
                  color: localizationlist[index].isSelected
                      ? Color(0xFF333366)
                      : Colors.transparent,
                  onPressed: () => setState(() => checkifselected(index)),
                ),
              ),
            ],
          );
        });
  }

  ///Builds a button to remove a localization from list.
  ///Contains a warning about consequences of removing an element.
  Widget buildRemoveButton(

      ///Stores id of a list element.
      int _index) {
    return SizedBox(
      width: 30,
      child: IconButton(
        color: Colors.white,
        icon: Icon(Icons.clear),
        onPressed: () {
          if (localizationlist[_index].id != null) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Uwaga"),
                    content: Text(
                        "Usunięcie tego rekordu doprowadzi do usunięcia lokalizacji w każdym innym zadaniu."),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          LocalizationHelper.deleteAndReplaceIdTask(
                              localizationlist[_index].id);
                          removeFromList(_index);
                        },
                      ),
                      FlatButton(
                        child: Text("Anuluj"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          } else {
            removeFromList(_index);
          }

        },
      ),
    );
  }

  ///Builds a button used to display every localization created by user.
  Widget buildCustomButton(

      ///Stores a text displayed inside the button.
      String text,

      ///Receives a void function which is getting used after button pressed.
      GestureTapCallback onPressed) {
    return RaisedButton(
      color: Color(0xFF333366),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        '$text',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  ///Builds a space between widgets in a column.
  Widget buildSpace() {
    return SizedBox(
      height: 10.0,
    );
  }

  ///Takes user to previous page.
  void goBack() {
    widget.listOfLocal.clear();
    localizationlist.forEach((g) {
      if (g.id == null && g.isSelected == false) {
        widget.listOfLocal.add(g);
      }
    });

    widget.stateOfParent.setState((){});
    Navigator.pop(context);
  }

  ///Takes user to localization pick page.
  void goToLocationPickPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddLocation(localizationlist,widget.addLocalizationState)));
  }

  ///Removes an element from a list.
  void removeFromList(

      ///Stores id of a list element.
      int _index) {
    localizationlist.removeAt(_index);
    setState(() {});
  }

  ///Checks if localization is selected by user.
  void checkifselected(_index) {
    if (localizationlist[_index].isSelected == true) {
      localizationlist[_index].isSelected = false;
      widget.task.localization = Localization(id: 0);
    } else {
      localizationlist.forEach((g) => g.isSelected = false);
      localizationlist[_index].isSelected = true;
      widget.task.localization = localizationlist[_index];
    }
  }
}

///Suggests adresses.
Future<List> fetchAddress(String query, LatLng position) async {
  String fullQuery = 'https://autosuggest.search.hereapi.com/v1/autosuggest?at=' +
      position.latitude.toString() +
      "," +
      position.longitude.toString() +
      "&limit=5&lang=pl&q=" +
      query +
      "&apiKey=wCXJuE5nXL-3L6I79NXtYR3kt-V0bqeqHNfTEFWoyk0&result_types=address";
  //HttpRequest http;
  final response = await http.get(fullQuery);

  if (response.statusCode == 200) {
    // Serwer zwrocil OK, wiec przekaz obrobionego JSONa
    var responseJson = json.decode(utf8.decode(response.bodyBytes))['items'];

    return (responseJson as List).map((f) => Adres.fromJson(f)).toList();
  } else {
    throw Exception('Błąd w ładowaniu adresów');
  }
}

class Adres {
  String ulica;
  String numerDomu;
  String miasto;
  int odleglosc;

  Adres({this.ulica, this.numerDomu, this.miasto, this.odleglosc});

  factory Adres.fromJson(Map<String, dynamic> json) {
    return new Adres(
      ulica: json['address']['street'].toString(),
      numerDomu: json['address']['houseNumber'].toString(),
      miasto: json['address']['city'].toString(),
      odleglosc: json['distance'],
    );
  }

  @override
  String toString() {
    String adres = '';

    if (!this.ulica.contains('null')) {
      adres += this.ulica;
    }
    if (!this.numerDomu.contains('null')) {
      adres += (" " + this.numerDomu);
    }
    if (adres == '') {
      adres += this.miasto;
    } else {
      adres += (", " + this.miasto);
    }
    return adres;
  }
}

final _addLocationKey = GlobalKey<FormState>();

class AddLocation extends StatefulWidget {
  @override
  _AddLocationState createState() => _AddLocationState();

  ///List of localizations.
  List<Localization> listofLocal;
  State stateOfParent;
  AddLocation(this.listofLocal,this.stateOfParent);
}

class _AddLocationState extends State<AddLocation> {
  Completer<GoogleMapController> mapController = Completer();
  Future<List<Adres>> futureAdresy;

  ///Initiates map.
  _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController.complete(controller);
    });
  }

  ///Function called on position change.
  _onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    //futureAdresy = fetchAddress('', _initialPosition);
  }

  //Zmienne: kontroler TextField, pozycji na mapie
  ///Stores user's input in a TextFormField.
  var adresController = TextEditingController();

  ///Stores user's input in a TextFormField.
  var nazwaController = TextEditingController();

  ///Frequency of map refreshing.
  final Throttling thrTxt =
  new Throttling(duration: Duration(milliseconds: 500));

  ///Stores initial position on a map.
  static LatLng _initialPosition;

  ///Stores last position on a map.
  static LatLng _lastPosition = _initialPosition;

  ///Element of a class Localization.
  Localization dbLokalizacja = new Localization();

  ///Individual key for a Form widget, used to validate user's input.
  final _formKey = new GlobalKey<FormState>();

  ///Custom decoration template.
  InputDecoration _buildInputDecoration(String hint, String iconPath) {
    return InputDecoration(
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 1))),
      hintText: hint,
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(151, 151, 151, 1))),
      hintStyle: TextStyle(color: Color.fromRGBO(252, 252, 252, 1)),
      icon: iconPath != '' ? Image.asset(iconPath) : null,
      errorStyle: TextStyle(color: Color.fromRGBO(248, 218, 87, 1)),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(248, 218, 87, 1))),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(248, 218, 87, 1))),
      suffixIcon: hint == 'Adres'
          ? IconButton(
          icon: Icon(Icons.clear), onPressed: () => adresController.clear())
          : null,
    );
  }

  ///Currently used decoration template.
  InputDecoration _buildInputDecoration2(
      String label, String hint, String iconPath) {
    return InputDecoration(
      filled: true,
      fillColor: new Color(0xFF333366),
      enabledBorder: new OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: new OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.white),
      ),
      border: new OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.red)),
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      hintText: hint,
      suffixIcon: label == 'Adres'
          ? IconButton(
          icon: Icon(Icons.clear), onPressed: () => adresController.clear())
          : null,
    );
  }

  ///Saving current position to _initialPosition variable.
  void _getLocation() async {
    Position currentLocation;
    try {
      currentLocation = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    } on PlatformException {
      print('blad w pobraniu lokalizacji');
    }

    setState(() {
      _initialPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);
    });

    print("Lokalizacja " +
        _initialPosition.latitude.toString() +
        " " +
        _initialPosition.longitude.toString());

    // Przy pierwszym pobraniu lokalizacji zamienia od razu na adres
    locationToAddress();
  }

  ///Getting street and house number from localization format.
  void locationToAddress() async {
    final coordinates =
    new Coordinates(_lastPosition.latitude, _lastPosition.longitude);
    var adres = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var adresKrotki = adres.first.addressLine.toString().split(",");

    adresController.text = adresKrotki[0];

    // Zapis do zmiennej bazy danych kodu pocztwoego i najczesciej tez nazwe miasta
    dbLokalizacja.city = adresKrotki[1];
  }

  ///Changing user's input to localization format.
  Future<void> addressToLocation(String query) async {
    //final query = adresController.text;
    var adres = await Geocoder.local.findAddressesFromQuery(query);
    var lokalizacja = adres.first.coordinates;
    print("Otrzymana lokalizacja: " + query);
    print(lokalizacja);

    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(lokalizacja.latitude, lokalizacja.longitude),
            zoom: 15.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            color: Color.fromRGBO(51, 47, 83, 1),
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Form(
                key: _formKey,
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildNazwaLokalizacji(),
                      SizedBox(height: 8.0),
                      _buildAdres(),
                      _buildMapa(),
                      _buildDodaj(context)
                    ],
                  ),
                ))),
      ),
    );
  }

  ///Builds TextFormField with validation for name of a localization picked by user.
  Widget _buildNazwaLokalizacji() {
    return TextFormField(
      controller: nazwaController,
      validator: (value) =>
      value.isEmpty ? 'Nazwa lokalizacji nie może być pusta' : null,
      style: TextStyle(
          color: Color.fromRGBO(252, 252, 252, 1), fontFamily: 'RadikalLight'),
      decoration: _buildInputDecoration2(
          "Nazwa lokalizacji", "Podaj nazwę nowej lokalizacji", null),
    );
  }

  ///Creates a field for adress with validation.
  Widget _buildAdres() {
    return Form(
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: adresController,
          decoration: _buildInputDecoration2("Adres", '', null),
          style: TextStyle(color: Color.fromRGBO(252, 252, 252, 1)),
        ),
        suggestionsCallback: (pattern) {
          if (pattern.isNotEmpty) return fetchAddress(pattern, _lastPosition);
          return null;
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            leading: Icon(Icons.location_on),
            title: Text(suggestion.toString()),
            trailing: Text(suggestion.odleglosc < 1000
                ? (suggestion.odleglosc.toString() + "m")
                : ((suggestion.odleglosc / 1000).toStringAsFixed(1) + "km")),
          );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (suggestion) {
          print("Wybrano adres: " + suggestion.toString());
          adresController.text = suggestion.toString();
          addressToLocation(suggestion.toString());
        },
      ),
    );
  }

  ///Builds a map.
  Widget _buildMapa() {
    return Container(
        margin: const EdgeInsets.only(top: 25.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        // Nie wyswietli mapy dopóki nie ma lokalizacji użytkownika - zajebiste
        child: _initialPosition == null
            ? Center(
            child: Text('Ładowanie mapy...',
                style: TextStyle(
                    fontFamily: 'RadikaLight',
                    color: Color.fromRGBO(252, 252, 252, 1))))
            : Stack(children: <Widget>[
          GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition:
              CameraPosition(target: _initialPosition, zoom: 15.0),
              onCameraMove: _onCameraMove,
              // Mapa nie ruszana = wyswietl adres
              onCameraIdle: () {
                locationToAddress();
              }),
          Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.flag,
              color: Color.fromRGBO(0, 0, 0, 1),
            ),
          ),
        ]));
  }

  ///Adds localization to data base.
  Widget _buildDodaj(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 35.0),
      width: MediaQuery.of(context).size.width * 0.62,
      child: RaisedButton(
        child: const Text(
          "Dodaj",
          style: TextStyle(
              color: Color.fromRGBO(40, 48, 52, 1),
              fontFamily: 'RadikaMedium',
              fontSize: 14),
        ),
        color: Colors.white,
        elevation: 4.0,
        onPressed: () {
          if (_formKey.currentState.validate()) {
            dbLokalizacja.latitude = _lastPosition.latitude;
            dbLokalizacja.longitude = _lastPosition.longitude;
            dbLokalizacja.name = nazwaController.text;
            dbLokalizacja.street = adresController.text;
            // Miasto zapisane jest w funkcji LocationToAdress()
            // Dodaj do bazy
            //LocalizationHelper.add(dbLokalizacja);
            // Powrot

            widget.listofLocal.add(dbLokalizacja);
            widget.stateOfParent.setState(() { });
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class AddNotificationTask extends StatefulWidget {
  @override
  _AddNotificationTaskState createState() => _AddNotificationTaskState();

  ///An object of a Task class.
  Task task;
  State stateOfParent;
  AddNotificationTask(this.task,this.stateOfParent);
}

class _AddNotificationTaskState extends State<AddNotificationTask> {
  ///Stores user's input in a TextFormField.
  final TextEditingController _text = new TextEditingController();

  ///Individual key for a Form widget, used to validate user's input.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ///List of notifications created by user.
  List<Notifi> _notifilist = [];

  ///Stores duration.
  var duration;

  ///Stores minutes.
  int minuty;

  ///Stores hours.
  int godziny;

  ///Stores days.
  int dni;

  ///Stores String used to display a notification on a button.
  String name;

  @override
  void initState() {
    _notifilist = widget.task.listNotifi;
    dni = 0;
    godziny = 0;
    minuty = 1;

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text("Dodaj powiadomienie", style: TextStyle(color: Colors.white)),
        leading:
        new IconButton(icon: Icon(Icons.arrow_back), onPressed: goBack),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                buildPickerNameTile("Dni"),
                SizedBox(width: 10),
                buildPickerNameTile("Godziny"),
                SizedBox(width: 10),
                buildPickerNameTile("Minuty"),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.transparent),
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(child: buildNumberPicker1(0, 30)),
                  SizedBox(width: 10),
                  Flexible(child: buildNumberPicker2(0, 23)),
                  SizedBox(width: 10),
                  Flexible(child: buildNumberPicker3(0, 59)),
                ],
              ),
            ),
            buildSpace(),
            buildCustomButton("Dodaj", validateAndAdd),
            buildSpace(),
            ListNotifi(_notifilist),
            buildSpace(),
            buildCustomButton("Potwierdź", confirm),
          ])),
    );
  }

  ///Builds names above the pickers to show if user sets a day, hour or minute.
  Widget buildPickerNameTile(

      ///Stores text displayed on a tile above the picker.
      String _value) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color(0xFF333366)),
          color: Color(0xFF333366),
        ),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("$_value"),
          ],
        ),
      ),
    );
  }

  ///Builds interface responsible for picking amount of days.
  Widget buildNumberPicker1(

      ///Stores minimum value of a picker.
      int _min,

      ///Stores maximum value of a picker.
      int _max) {
    return NumberPicker.integer(
        listViewWidth: double.infinity,
        itemExtent: 40,
        initialValue: dni,
        minValue: _min,
        maxValue: _max,
        zeroPad: true,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.indigo),
        ),
        highlightSelectedValue: true,
        onChanged: (value) => setState(() => dni = value));
  }

  ///Builds interface responsible for picking amount of hours.
  Widget buildNumberPicker2(

      ///Stores minimum value of a picker.
      int _min,

      ///Stores maximum value of a picker.
      int _max) {
    return NumberPicker.integer(
        listViewWidth: double.infinity,
        itemExtent: 40,
        initialValue: godziny,
        minValue: _min,
        maxValue: _max,
        zeroPad: true,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.indigo),
        ),
        highlightSelectedValue: true,
        onChanged: (value) => setState(() => godziny = value));
  }

  ///Builds interface responsible for picking amount of minutes.
  Widget buildNumberPicker3(

      ///Stores minimum value of a picker.
      int _min,

      ///Stores maximum value of a picker.
      int _max) {
    return NumberPicker.integer(
        listViewWidth: double.infinity,
        itemExtent: 40,
        initialValue: minuty,
        minValue: _min,
        maxValue: _max,
        zeroPad: true,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.indigo),
        ),
        highlightSelectedValue: true,
        onChanged: (value) => setState(() => minuty = value));
  }

  ///Builds a button without validation.
  Widget buildCustomButton(

      ///Stores text shown inside the button.
      String text,

      ///Receives void function which is going to get used after button pressed.
      GestureTapCallback onPressed) {
    return RaisedButton(
      color: Color(0xFF333366),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.transparent,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        '$text',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  ///Builds a space between widgets in a column.
  Widget buildSpace() {
    return SizedBox(
      height: 10.0,
    );
  }

  ///Builds a TextFormField with a validation.
  ///Checks if user did fill the field.
  ///On empty field returns a message.
  Widget buildCustomTextFieldwithValidation(

      ///Stores text shown on the label of a TextFormField.
      String label,

      ///Stores text shown inside the TextFormField as a hint.
      String hint,

      ///Used to control user's input.
      TextEditingController control) {
    return TextFormField(
        controller: control,
        decoration: new InputDecoration(
            filled: true,
            fillColor: Color(0xFF333366),
            enabledBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white)),
            border: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white),
            suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  control.clear();
                })),
        keyboardType: TextInputType.number,
        validator: (val) {
          if (val.isEmpty) {
            return 'Pole nie może być puste!';
          }
          return null;
        });
  }

  ///Validates user's input.
  ///If accepted adds new notification to a list.
  void validateAndAdd() {
    bool notthesame = true;

    duration = new Duration(days: dni, hours: godziny, minutes: minuty);
    name = "Powiadomienie ";
    if (dni != 0) {
      name += "$dni" + "d,";
    }
    if (godziny != 0) {
      name += "$godziny" + "h ,";
    }
    name += "$minuty" + "m przed";
    if(!(dni == 0 && godziny == 0 && minuty == 0)) {
      _notifilist.forEach((n) {
        if (n.duration.compareTo(duration) == 0) {
          notthesame = false;
        }
      });
      if (notthesame) {
        _notifilist.add(Notifi(duration: duration));
      }
      setState(() {});
    }
  }

  ///Takes user to previous page.
  void goBack() {
    widget.stateOfParent.setState((){});
    Navigator.pop(context);
  }

  ///Adds created list to a task.
  void confirm() {
    widget.task.listNotifi = _notifilist;
    widget.stateOfParent.setState((){});
    Navigator.pop(context);
  }
}

class AddNotificationEvent extends StatefulWidget {
  @override
  _AddNotificationEventState createState() => _AddNotificationEventState();

  Event event;
  State stateOfParent;
  AddNotificationEvent(this.event,this.stateOfParent);
}

class _AddNotificationEventState extends State<AddNotificationEvent> {
  ///Stores user's input in a TextFormField.
  final TextEditingController _text = new TextEditingController();

  ///Individual key for a Form widget, used to validate user's input.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ///List of notifications created by user.
  List<Notifi> _notifilist = [];

  ///Stores duration.
  var duration;

  ///Stores minutes.
  int minuty;

  ///Stores hours.
  int godziny;

  ///Stores days.
  int dni;

  ///Stores String used to display a notification on a button.
  String name;

  @override
  void initState() {
    _notifilist = widget.event.listNotifi;
    dni = 0;
    godziny = 0;
    minuty = 1;

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text("Dodaj powiadomienie", style: TextStyle(color: Colors.white)),
        leading:
        new IconButton(icon: Icon(Icons.arrow_back), onPressed: goBack),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                buildPickerNameTile("Dni"),
                SizedBox(width: 10),
                buildPickerNameTile("Godziny"),
                SizedBox(width: 10),
                buildPickerNameTile("Minuty"),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.transparent),
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(child: buildNumberPicker1(0, 30)),
                  SizedBox(width: 10),
                  Flexible(child: buildNumberPicker2(0, 23)),
                  SizedBox(width: 10),
                  Flexible(child: buildNumberPicker3(0, 59)),
                ],
              ),
            ),
            buildSpace(),
            buildCustomButton("Dodaj", validateAndAdd),
            buildSpace(),
            ListNotifi(_notifilist),
            buildSpace(),
            buildCustomButton("Potwierdź", confirm)
          ])),
    );
  }

  ///Builds names above the pickers to show if user sets a day, hour or minute.
  Widget buildPickerNameTile(

      ///Stores text displayed on a tile above the picker.
      String _value) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color(0xFF333366)),
          color: Color(0xFF333366),
        ),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("$_value"),
          ],
        ),
      ),
    );
  }

  ///Builds interface responsible for picking amount of days.
  Widget buildNumberPicker1(

      ///Stores minimum value of a picker.
      int _min,

      ///Stores maximum value of a picker.
      int _max) {
    return NumberPicker.integer(
        listViewWidth: double.infinity,
        itemExtent: 40,
        initialValue: dni,
        minValue: _min,
        maxValue: _max,
        zeroPad: true,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.indigo),
        ),
        highlightSelectedValue: true,
        onChanged: (value) => setState(() => dni = value));
  }

  ///Builds interface responsible for picking amount of days.
  Widget buildNumberPicker2(

      ///Stores minimum value of a picker.
      int _min,

      ///Stores maximum value of a picker.
      int _max) {
    return NumberPicker.integer(
        listViewWidth: double.infinity,
        itemExtent: 40,
        initialValue: godziny,
        minValue: _min,
        maxValue: _max,
        zeroPad: true,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.indigo),
        ),
        highlightSelectedValue: true,
        onChanged: (value) => setState(() => godziny = value));
  }

  ///Builds interface responsible for picking amount of days.
  Widget buildNumberPicker3(

      ///Stores minimum value of a picker.
      int _min,

      ///Stores maximum value of a picker.
      int _max) {
    return NumberPicker.integer(
        listViewWidth: double.infinity,
        itemExtent: 40,
        initialValue: minuty,
        minValue: _min,
        maxValue: _max,
        zeroPad: true,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.indigo),
        ),
        highlightSelectedValue: true,
        onChanged: (value) => setState(() => minuty = value));
  }

  ///Builds a button without validation.
  Widget buildCustomButton(

      ///Stores text shown inside the button.
      String text,

      ///Receives void function which is going to get used after button pressed.
      GestureTapCallback onPressed) {
    return RaisedButton(
      color: Color(0xFF333366),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.transparent,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        '$text',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  ///Builds a space between widgets in a column.
  Widget buildSpace() {
    return SizedBox(
      height: 10.0,
    );
  }

  ///Builds a TextFormField with a validation.
  ///Checks if user did fill the field.
  ///On empty field returns a message.
  Widget buildCustomTextFieldwithValidation(

      ///Stores text shown on the label of a TextFormField.
      String label,

      ///Stores text shown inside the TextFormField as a hint.
      String hint,

      ///Used to control user's input.
      TextEditingController control) {
    return TextFormField(
        controller: control,
        decoration: new InputDecoration(
            filled: true,
            fillColor: Color(0xFF333366),
            enabledBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white)),
            border: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white),
            suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  control.clear();
                })),
        keyboardType: TextInputType.number,
        validator: (val) {
          if (val.isEmpty) {
            return 'Pole nie może być puste!';
          }
          return null;
        });
  }

  ///Validates user's input.
  ///If accepted adds new notification to a list.
  void validateAndAdd() {
    bool notthesame = true;

    duration = new Duration(days: dni, hours: godziny, minutes: minuty);
    name = "Powiadomienie ";
    if (dni != 0) {
      name += "$dni" + "d,";
    }
    if (godziny != 0) {
      name += "$godziny" + "h ,";
    }
    name += "$minuty" + "m przed";

    if(!(dni == 0 && godziny == 0 && minuty == 0)) {
      _notifilist.forEach((n) {
        if (n.duration.compareTo(duration) == 0) {
          notthesame = false;
        }
      });
      if (notthesame) {
        _notifilist.add(Notifi(duration: duration));
      }
      setState(() {});
    }
  }

  ///Takes user to previous page.
  void goBack() {
    Navigator.pop(context);
    widget.stateOfParent.setState((){});
  }

  ///Adds created list to an event.
  void confirm() {
    widget.event.listNotifi = _notifilist;
    widget.stateOfParent.setState((){});
    Navigator.pop(context);
  }
}

_AddTaskState addTaskState;

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() {
    addTaskState = _AddTaskState();
    return addTaskState;
  }

  AddTask();
}

class _AddTaskState extends State<AddTask> {
  ///Individual key for a Form widget, used to validate user's input.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ///Stores user's input in a TextFormField.
  TextEditingController _controllerName = TextEditingController();

  ///Stores user's input in a TextFormField.
  TextEditingController controllerDesc = TextEditingController();

  ///Stores color of a button displaying task's date.
  Color dateColor;

  ///Stores color of a button displaying task's time.
  Color timeColor;

  ///Default value is false, changes after user picks time and date.
  bool isNotificationEnabled;

  ///Default value is false, changes after user picks time.
  bool isTimeSelected;

  ///Default value is false, changes after user picks a date.
  bool isDateSelected;

  ///Default value is false, changes after  sets a localization.
  bool isLocalizationSelected;

  ///Stores task's date.
  DateTime _terminData;

  ///Stores task's time.
  DateTime _terminCzas;

  ///Stores current date;
  DateTime _today;

  ///An object of a class Task.
  Task _task;

  ///List of localizations created by user.
  List<Localization> listOfLocalization;

  ///List of groups created by user.
  List<Group> listOfGroup;

  @override
  void initState() {
    print("start");
    listOfLocalization = List();
    listOfGroup = List();
    _today = DateTime.now();

    _terminData = DateTime.now();


    _terminCzas = DateTime.now();

    isNotificationEnabled = false;
    isDateSelected = false;
    isTimeSelected = false;
    isLocalizationSelected = false;

    _task = Task(
      group: Group(id: 0),
      localization: Localization(id: 0),
      done: false,
    );

    dateColor = Colors.white;
    timeColor = Colors.white;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dodaj zadanie',
          style: TextStyle(color: Colors.white),
        ),
        leading:
        new IconButton(icon: Icon(Icons.arrow_back), onPressed: goBack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              buildSpace(),
              buildCustomTextFieldwithValidation(
                  "Nazwa", "Podaj nazwę nowego zadania", _controllerName),
              buildSpace(),
              buildCustomButtonWithValidation(
                  dateColor,
                  (isDateSelected)
                      ? DateFormat("dd/MM/yyyy").format(_terminData)
                      : "Nie wybrano daty",
                  Icons.date_range,
                  datePick,
                  buildClearButton(clearDate)),
              buildSpace(),
              buildCustomButtonWithValidation(
                  timeColor,
                  (isTimeSelected)
                      ? DateFormat("HH:mm").format(_terminCzas)
                      : "Nie wybrano godziny",
                  Icons.access_time,
                  timePick,
                  buildClearButton(clearTime)),
              buildSpace(),
              buildCustomButton(
                  (_task.group.id == 0)
                      ? "Nie wybrano grupy"
                      : "${_task.group.name}",
                  Icons.account_circle,
                  goToGroupPickPage,
                  buildClearButton(clearGroup)),
              buildSpace(),
              buildCustomNotificationButton(
                ((_task.listNotifi).isEmpty)
                    ? "Nie wybrano powiadomień"
                    : ((_task.listNotifi).length == 1)
                    ? "Wybrano ${(_task.listNotifi).length} powiadomienie"
                    : ((_task.listNotifi).length < 5)
                    ? "Wybrano ${(_task.listNotifi).length} powiadomienia"
                    : ((_task.listNotifi).length < 21)
                    ? "Wybrano ${(_task.listNotifi).length} powiadomień"
                    : ((_task.listNotifi).length % 10 == 2 ||
                    (_task.listNotifi).length % 10 == 3 ||
                    (_task.listNotifi).length % 10 == 4)
                    ? "Wybrano ${(_task.listNotifi).length} powiadomienia"
                    : "Wybrano ${(_task.listNotifi).length} powiadomień",
                Icons.notifications,
                goToNotificationPickPage,
              ),
              buildSpace(),
              buildCustomButton(
                  (_task.localization.id == 0)
                      ? "Nie wybrano lokalizacji"
                      : "${_task.localization.name}",
                  Icons.edit_location,
                  goToLocalizationPickPage,
                  buildClearButton(clearLocalization)),
              buildSpace(),
              buildCustomTextField("Opis", "Wprowadź opis swojego zadania",
                  "Pole jest opcjonalne", controllerDesc),
              buildSpace(),
              buildButtonBar(),
            ],
          ),
        ),
      ),
    );
  }

  ///Builds a row with two buttons inside of it.
  Widget buildButtonBar() {
    return ButtonBar(
        children: [
          buildButtonBarTile("Anuluj", Colors.red, goBack),
          SizedBox(
            width: 30,
          ),
          buildButtonBarTile(
              "Dodaj", Colors.lightGreenAccent, acceptAndValidate)
        ],
        alignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        buttonMinWidth: 150);
  }

  ///Builds a TextFormField with validation.
  Widget buildCustomTextFieldwithValidation(

      ///Stores text shown on the label of a TextFormField.
      String label,

      ///Stores text shown inside TextFormField as a hint.
      String hint,

      ///Used to control user's input.
      TextEditingController control) {
    return TextFormField(
        controller: control,
        decoration: new InputDecoration(
            filled: true,
            fillColor: new Color(0xFF333366),
            enabledBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white)),
            border: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
            hintText: hint,
            suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  control.clear();
                })),
        keyboardType: TextInputType.text,
        validator: (val) {
          if (val.isEmpty) {
            return 'Pole nie może być puste!';
          }
          return null;
        });
  }

  ///Builds a button responsible for clearing data.
  Widget buildClearButton(

      ///Receives a void function which is getting used after button pressed.
      GestureTapCallback onPressed) {
    return SizedBox(
      width: 30,
      child: IconButton(
        color: Colors.white,
        icon: Icon(Icons.clear),
        onPressed: onPressed,
      ),
    );
  }

  ///Builds a button responsible for clearing notification list created by user.
  Widget buildNotifiListClearButton(

      ///Receives a void function which is getting used after button pressed.
      GestureTapCallback onPressed) {
    return SizedBox(
      width: 30,
      child: IconButton(
        color: Colors.white,
        icon: Icon(Icons.clear),
        onPressed: (isNotificationEnabled) ? onPressed : null,
      ),
    );
  }

  ///Builds a TextFormField without validation.
  Widget buildCustomTextField(

      ///Stores text shown on the label of a TextFormField.
      String label,

      ///Stores text shown inside TextFormField as a hint.
      String hint,

      ///Stores text shown under TextFormField as an extra information.
      String helper,

      ///Used to control user's input.
      TextEditingController control) {
    return TextFormField(
      controller: control,
      decoration: new InputDecoration(
          filled: true,
          fillColor: new Color(0xFF333366),
          enabledBorder: new OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white)),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          hintText: hint,
          helperText: helper,
          helperStyle: TextStyle(color: Colors.white),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                control.clear();
              })),
      keyboardType: TextInputType.text,
    );
  }

  ///Builds a space between widgets in a column.
  Widget buildSpace() {
    return SizedBox(
      height: 10.0,
    );
  }

  ///Builds a button with validation.
  Widget buildCustomButtonWithValidation(

      ///Stores a color of text inside the button.
      ///Depends on validation result.
      Color textcolor,

      ///Stores text shown inside the button.
      String text,

      ///Stores icon shown before text inside the button.
      IconData icon,

      ///Accpets void function which is going to get used after button pressed.
      GestureTapCallback onPressed,

      ///Widget of a button responsible for clearing user's input.
      Widget clearButton) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20.0,
                  color: textcolor,
                ),
                Text(
                  " $text",
                  style: TextStyle(
                    color: textcolor,
                  ),
                ),
              ],
            ),
            clearButton,
          ],
        ),
      ),
      color: new Color(0xFF333366),
    );
  }

  ///Builds a button without validation.
  Widget buildCustomButton(

      ///Stores text shown inside the button.
      String text,

      ///Stores icon shown before text inside the button.
      IconData icon,

      ///Receives void function which is going to get used after button pressed.
      GestureTapCallback onPressed,

      ///Widget of a button responsible for clearing user's input.
      Widget clearButton) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20.0,
                ),
                Text(
                  " $text",
                  style: TextStyle(),
                ),
              ],
            ),
            clearButton,
          ],
        ),
      ),
      color: new Color(0xFF333366),
    );
  }

  ///Builds a button responsible for pick and clear notifications.
  Widget buildCustomNotificationButton(

      ///Stores text shown inside the button.
      String text,

      ///Receives void function which is going to get used after button pressed.
      IconData icon,

      ///Widget of a button responsible for clearing user's input.
      GestureTapCallback onPressed) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      onPressed: (isNotificationEnabled) ? onPressed : null,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20.0,
                ),
                Text(
                  isNotificationEnabled
                      ? " $text"
                      : "Ustal temin by wybrać powiadomienia",
                  style: TextStyle(),
                ),
              ],
            ),
            buildNotifiListClearButton(clearNotifiList),
          ],
        ),
      ),
      color: new Color(0xFF333366),
    );
  }

  ///Builds a button for a button bar.
  Widget buildButtonBarTile(

      ///Stores text shown inside a button.
      String text,

      ///Stores color of a button.
      ///Changing on button press.
      Color color,

      ///Receives a void function which is getting used after button pressed.
      GestureTapCallback onPressed) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      color: new Color(0xFF333366),
      splashColor: color,
      child: Text("$text"),
      onPressed: onPressed,
    );
  }

  ///Erases date of a task which user already picked.
  void clearDate() {
    isDateSelected = false;
    isNotificationEnabled = false;
    setState(() {});
  }

  ///Erases time of a task which user already picked.
  void clearTime() {
    isTimeSelected = false;
    isNotificationEnabled = false;
    setState(() {});
  }

  ///Erases localization of a task which user already picked.
  void clearLocalization() {
    _task.localization = Localization(id: 0);
    setState(() {});
  }

  ///Erases group of a task which user already picked.
  void clearGroup() {
    _task.group = Group(id: 0);
    setState(() {});
  }

  ///Clears notification list of a task which user already picked.
  void clearNotifiList() {
    (_task.listNotifi).clear();
    setState(() {});
  }

  ///Builds interface responsible for picking a date.
  void datePick() {
    DatePicker.showDatePicker(context,
        theme: DatePickerTheme(
          backgroundColor: Colors.black38,
          itemStyle: TextStyle(color: Colors.white),
          cancelStyle: TextStyle(color: Colors.red),
          doneStyle: TextStyle(color: Colors.green[400]),
          containerHeight: 210.0,
        ),
        showTitleActions: true,
        minTime: DateTime(2020, 1, 1),
        maxTime: DateTime(2025, 12, 31), onConfirm: (date) {
          isDateSelected = true;
          if (isDateSelected && isTimeSelected) isNotificationEnabled = true;
          _terminData = date;
          setState(() {});
        }, currentTime: _terminData, locale: LocaleType.pl);
  }

  ///Builds interface responsible for picking a time.
  void timePick() {
    DatePicker.showTimePicker(context,
        theme: DatePickerTheme(
          backgroundColor: Colors.black38,
          itemStyle: TextStyle(color: Colors.white),
          cancelStyle: TextStyle(color: Colors.red),
          doneStyle: TextStyle(color: Colors.green[400]),
          containerHeight: 210.0,
        ),
        showSecondsColumn: false,
        showTitleActions: true, onConfirm: (time) {
          isTimeSelected = true;
          if (isDateSelected && isTimeSelected) isNotificationEnabled = true;
          _terminCzas = time;
          setState(() {});
        }, currentTime:  _terminCzas, locale: LocaleType.pl);
  }

  ///Takes user to previous page.
  void goBack() {
    Navigator.pop(context);
  }

  ///Takes user to notification pick page.
  void goToNotificationPickPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddNotificationTask(_task,addTaskState)));
  }

  ///Takes user to localization pick page.
  void goToLocalizationPickPage() {
    isLocalizationSelected = true;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddLocalization(_task, listOfLocalization,addTaskState)));
  }

  ///Takes user to group pick page.
  void goToGroupPickPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddGroup(_task, listOfGroup,addTaskState)));
  }

  ///Validates user's input.
  ///If accepted adds new Task.
  void acceptAndValidate() {
    if (_formKey.currentState.validate()) {
      _task.name = _controllerName.text;
      _task.description = controllerDesc.text;
      if (isTimeSelected && isDateSelected) {
        print("isTimeSelected: $isTimeSelected");
        print("isDateSelected: $isDateSelected");
        _task.endTime = DateTime(_terminData.year, _terminData.month,
            _terminData.day, _terminCzas.hour, _terminCzas.minute);
      } else {
        _task.listNotifi.clear();
      }

      List<Notifi> listN = List();
      listN.addAll(_task.listNotifi);

      for (Notifi element in listN) {
        if (_task.endTime.subtract(element.duration).isBefore(_today)) {
          //print("delete: ${_task.endTime.subtract(element.duration)}");
          _task.listNotifi.remove(element);
        }
      }

      TaskHelper.add(_task).then((onvalue) {
        GroupHelper.addlist(listOfGroup);
        LocalizationHelper.addlist(listOfLocalization);
        Navigator.of(context).pop();
      });
    }
  }
}

class ListNotifi extends StatefulWidget {
  List<Notifi> lista;

  ListNotifi(this.lista);

  @override
  _ListNotifiState createState() => _ListNotifiState();
}

class _ListNotifiState extends State<ListNotifi> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height*0.37,
      child: new ListView.builder(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.lista.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF333366),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.white),
                  ),
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(10),
                          child: buildListTextTile(index)),
                      buildRemoveButton(index),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  ///Builds a space between widgets in a column.
  Widget buildSpace() {
    return SizedBox(
      height: 10.0,
    );
  }

  ///Builds a space between widgets in a row.
  Widget buildSpaceBetween(

      ///Specifies width of a space.
      double _width) {
    return SizedBox(
      width: _width,
    );
  }

  ///Builds a field with a text displayed inside of it.
  Widget buildListTextTile(

      ///Stores id of a list element.
      int _index) {
    return SizedBox(
      width: 150,
      child: Text(
          printDuration(widget.lista[_index].duration, abbreviated: true) +
              " przed"),
    );
  }

  ///Builds a button to remove an element from list.
  Widget buildRemoveButton(

      ///Stores id of a list element.
      int _index) {
    return SizedBox(
      child: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          removeFromList(_index);
        },
      ),
    );
  }

  ///Builds a field with an icon displayed inside of it.
  Widget buildListIconTile() {
    return Container(
      width: 20,
      child: Icon(
        Icons.notifications,
        size: 18.0,
      ),
    );
  }

  ///Removes an element from a list.
  void removeFromList(int _index) {
    if (widget.lista[_index].id != null) {
      NotifiHelper.delete(widget.lista[_index].id);
    }
    widget.lista.removeAt(_index);
    setState(() {});
  }
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class UpdateEvent extends StatefulWidget {
  @override
  _UpdateEventState createState(){
    updateEventState = _UpdateEventState();
    return updateEventState;
  }

  Event event;
  State updateEventState;
  UpdateEvent({this.event});
}

class _UpdateEventState extends State<UpdateEvent> {

  ///Stores user's input in a TextFormField.
  TextEditingController _controllerName;

  ///Stores user's input in a TextFormField.
  TextEditingController _controllerDesc;

  ///Individual key for a Form widget, used to validate user's input.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ///Stores current date;
  DateTime _today;

  ///Stores event's date.
  DateTime _date;

  ///Stores event's starting time.
  DateTime _time1;

  ///Stores event's end time.
  DateTime _time2;

  ///Stores color of a button displaying event's date.
  Color _dateColor;

  ///Stores color of a button displaying event's starting time.
  Color _time1Color;

  ///Stores color of a button displaying event's end time.
  Color _time2Color;

  ///Object of an Event class.
  //Event _event;

  ///Default value is false, changes after user picks a date.
  bool isDateSelected;

  ///Default value is false, changes after user picks an event's starting time.
  bool isTime1Selected;

  ///Default value is false, changes after user picks an event's end time.
  bool isTime2Selected;


  @override
  void initState() {
    _downloadData();
    _today = DateTime.now();
    _date = widget.event.beginTime;
    _time1 = widget.event.beginTime;
    _time2 = widget.event.endTime;

    _dateColor = Colors.white;
    _time1Color = Colors.white;
    _time2Color = Colors.white;

    _controllerName = TextEditingController(text: widget.event.name);
    _controllerDesc = TextEditingController(text: widget.event.description);

    isDateSelected = true;
    isTime1Selected = true;
    isTime2Selected = true;

    super.initState();
  }

  void _downloadData() {
    NotifiHelper.listsEventID(widget.event.id).then((onList) {
      if (onList != null) {
        widget.event.listNotifi.addAll(onList);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dodaj wydarzenie',
          style: TextStyle(color: Colors.white),
        ),

        ///Builds a go Back button.
        leading:
        new IconButton(icon: Icon(Icons.arrow_back), onPressed: goBack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              buildSpace(),
              buildCustomTextFieldwithValidation("Nazwa",
                  "Wprowadź nazwę swojego wydarzenia", _controllerName),
              buildSpace(),
              buildCustomButtonWithValidation(
                  _dateColor,
                  (isDateSelected)
                      ? DateFormat("dd/MM/yyyy").format(_date)
                      : "Nie wybrano daty",
                  Icons.date_range,
                  datePick,
                  buildClearButton(clearDate)),
              buildSpace(),
              buildCustomButtonWithValidation(
                  _time1Color,
                  (isTime1Selected)
                      ? DateFormat("HH:mm").format(_time1)
                      : "Nie wybrano godziny rozpoczęcia",
                  Icons.access_time,
                  startTimePick,
                  buildClearButton(clearTime1)),
              buildSpace(),
              buildCustomButtonWithValidation(
                  _time2Color,
                  (isTime2Selected)
                      ? DateFormat("HH:mm").format(_time2)
                      : "Nie wybrano godziny zakończenia",
                  Icons.access_time,
                  endTimePick,
                  buildClearButton(clearTime2)),
              buildSpace(),
              buildCustomButton(
                  ((widget.event.listNotifi).isEmpty)
                      ? "Nie wybrano powiadomień"
                      : ((widget.event.listNotifi).length == 1)
                      ? "Wybrano ${(widget.event.listNotifi).length} powiadomienie"
                      : ((widget.event.listNotifi).length < 5)
                      ? "Wybrano ${(widget.event.listNotifi).length} powiadomienia"
                      : ((widget.event.listNotifi).length < 21)
                      ? "Wybrano ${(widget.event.listNotifi).length} powiadomień"
                      : ((widget.event.listNotifi).length % 10 == 2 ||
                      (widget.event.listNotifi).length % 10 == 3 ||
                      (widget.event.listNotifi).length % 10 == 4 )
                      ? "Wybrano ${(widget.event.listNotifi).length} powiadomienia"
                      : "Wybrano ${(widget.event.listNotifi).length} powiadomień",
                  Icons.notifications,
                  goToNotificationPickPage,
                  buildClearButton(clearNotifiList)),
              buildSpace(),
              buildCustomTextField("Opis", "Wpisz opis swojego wydarzenia",
                  "Pole jest opcjonalne", _controllerDesc),
              buildSpace(),
              buildButtonBar(),
            ],
          ),
        ),
      ),
    );
  }

  ///Builds a TextFormField with a validation.
  ///Checks if user did fill the field.
  ///On empty field returns a message.
  Widget buildCustomTextFieldwithValidation(

      ///Stores text shown on the label of a TextFormField.
      String label,

      ///Stores text shown inside the TextFormField as a hint.
      String hint,

      ///Used to control user's input.
      TextEditingController control) {
    return TextFormField(
        controller: control,
        decoration: new InputDecoration(
            filled: true,
            fillColor: new Color(0xFF333366),
            enabledBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white)),
            border: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
            hintText: hint,
            suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  control.clear();
                })),
        keyboardType: TextInputType.text,
        validator: (val) {
          if (val.isEmpty) {
            return 'Pole nie może być puste!';
          }
          return null;
        });
  }

  ///Builds a TextFormField without validation.
  Widget buildCustomTextField(

      ///Stores text shown on the label of a TextFormField.
      String label,

      ///Stores text shown inside TextFormField as a hint.
      String hint,

      ///Stores text shown under TextFormField as an extra information.
      String helper,

      ///Used to control user's input.
      TextEditingController control) {
    return TextFormField(
      controller: control,
      decoration: new InputDecoration(
          filled: true,
          fillColor: new Color(0xFF333366),
          enabledBorder: new OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white)),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          hintText: hint,
          helperText: helper,
          helperStyle: TextStyle(color: Colors.white),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                control.clear();
              })),
      keyboardType: TextInputType.text,
    );
  }

  ///Builds a space between widgets in a column.
  Widget buildSpace() {
    return SizedBox(
      height: 10.0,
    );
  }
  ///Builds a button with validation.
  Widget buildCustomButtonWithValidation(

      ///Stores a color of text inside the button.
      ///Depends on validation result.
      Color textcolor,

      ///Stores text shown inside the button.
      String text,

      ///Stores icon shown before text inside the button.
      IconData icon,

      ///Accpets void function which is going to get used after button pressed.
      GestureTapCallback onPressed,

      ///Widget of a button responsible for clearing user's input.
      Widget clearButton) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20.0,
                  color: textcolor,
                ),
                Text(
                  " $text",
                  style: TextStyle(
                    color: textcolor,
                  ),
                ),
              ],
            ),
            clearButton,
          ],
        ),
      ),
      color: Color(0xFF333366),
    );
  }

  ///Builds a button without validation.
  Widget buildCustomButton(

      ///Stores text shown inside the button.
      String text,

      ///Stores icon shown before text inside the button.
      IconData icon,

      ///Receives void function which is going to get used after button pressed.
      GestureTapCallback onPressed,

      ///Widget of a button responsible for clearing user's input.
      Widget clearButton) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20.0,
                ),
                Text(
                  " $text",
                  style: TextStyle(),
                ),
              ],
            ),
            clearButton,
          ],
        ),
      ),
      color: Color(0xFF333366),
    );
  }

  ///Builds a row with two buttons inside of it.
  Widget buildButtonBar() {
    return ButtonBar(
        children: [
          buildButtonBarTile("Anuluj", Colors.red, goBack),
          SizedBox(
            width: 30,
          ),
          buildButtonBarTile(
              "Dodaj", Colors.lightGreenAccent, acceptAndValidate),
        ],
        alignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        buttonMinWidth: 150);
  }

  ///Builds a button for a button bar.
  Widget buildButtonBarTile(
      ///Stores text shown inside a button.
      String text,

      ///Stores color of a button.
      ///Changing on button press.
      Color color,

      ///Receives a void function which is getting used after button pressed.
      GestureTapCallback onPressed) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      color: Color(0xFF333366),
      splashColor: color,
      child: Text("$text"),
      onPressed: onPressed,
    );
  }

  ///Builds a button responsible for clearing data.
  Widget buildClearButton(

      ///Receives a void function which is getting used after button pressed.
      GestureTapCallback onPressed) {
    return SizedBox(
      width: 30,
      child: IconButton(
        color: Colors.white,
        icon: Icon(Icons.clear),
        onPressed: onPressed,
      ),
    );
  }

  ///Erases date of an event which user already picked.
  void clearDate() {
    isDateSelected = false;
    setState(() {});
  }

  ///Clears starting time of an event which user already picked.
  void clearTime1() {
    isTime1Selected = false;
    setState(() {});
  }

  ///Clears end time of an event which user already picked.
  void clearTime2() {
    isTime2Selected = false;
    setState(() {});
  }

  ///Clears list of notifications which user already picked.
  void clearNotifiList() {
    (widget.event.listNotifi).clear();
    setState(() {});
  }

  ///Builds interface responsible for picking a date.
  void datePick() {
    DatePicker.showDatePicker(context,
        theme: DatePickerTheme(
          backgroundColor: Colors.black38,
          itemStyle: TextStyle(color: Colors.white),
          cancelStyle: TextStyle(color: Colors.red),
          doneStyle: TextStyle(color: Colors.green[400]),
          containerHeight: 210.0,
        ),
        showTitleActions: true,
        minTime: DateTime(2020, 1, 1),
        maxTime: DateTime(2025, 12, 31), onConfirm: (date) {
          isDateSelected = true;
          _date = date;
          setState(() {});
        }, currentTime: _date,
        locale: LocaleType.pl
    );
  }

  ///Builds interface responsible for picking a starting time.
  void startTimePick() {
    DatePicker.showTimePicker(context,
      theme: DatePickerTheme(
        backgroundColor: Colors.black38,
        itemStyle: TextStyle(color: Colors.white),
        cancelStyle: TextStyle(color: Colors.red),
        doneStyle: TextStyle(color: Colors.green),
        containerHeight: 210.0,
      ),
      showSecondsColumn: false,
      showTitleActions: true, onConfirm: (time) {
        isTime1Selected = true;
        _time1 = time;
        setState(() {});
      }, currentTime: _time1,
    );
    setState(() {});
  }

  ///Builds interface responsible for picking an end time.
  void endTimePick() {
    DatePicker.showTimePicker(context,
        theme: DatePickerTheme(
          backgroundColor: Colors.black38,
          itemStyle: TextStyle(color: Colors.white),
          cancelStyle: TextStyle(color: Colors.amber[400]),
          doneStyle: TextStyle(color: Colors.green[400]),
          containerHeight: 210.0,
        ),
        showTitleActions: true,
        showSecondsColumn: false, onConfirm: (time) {
          print('confirm $time');
          isTime2Selected = true;
          _time2 = time;
          setState(() {});
        },
        currentTime: _time2,
        locale: LocaleType.pl);
    setState(() {});
  }

  ///Takes user to previous page.
  void goBack() {
    Navigator.pop(context);
  }

  ///Takes user to notification pick page.
  void goToNotificationPickPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddNotificationEvent(widget.event,widget.updateEventState)));
  }

  ///Validates user's input.
  ///If accepted adds new Event.
  void acceptAndValidate() {
    if (isTime1Selected && isTime2Selected && _time2.isBefore(_time1)) {
      print("ERROR");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Błąd danych"),
              content:
              Text("Godzina zakończenia nie może być przed rozpoczęciem."),
            );
          });
    } else {
      if (_formKey.currentState.validate()) {
        if (isDateSelected && isTime1Selected && isTime2Selected) {
          _dateColor = Colors.white;
          _time1Color = Colors.white;
          _time2Color = Colors.white;

          widget.event.name = _controllerName.value.text;
          widget.event.description = _controllerDesc.text;
          widget.event.beginTime = DateTime(_date.year, _date.month, _date.day, _time1.hour, _time1.minute);
          widget.event.endTime = DateTime(_date.year, _date.month, _date.day, _time2.hour, _time2.minute);

          List<Notifi> listN  = List();
          listN.addAll(widget.event.listNotifi);

          for(Notifi element in listN){
            if(widget.event.beginTime.subtract(element.duration).isBefore(_today)){
              print("delete: ${widget.event.beginTime.subtract(element.duration)}");
              widget.event.listNotifi.remove(element);
            }
          }

          EventHelper.update(widget.event).then((value) => Navigator.of(context).pop());

        } else {
          if (isDateSelected == false)
            _dateColor = Colors.red;
          else
            _dateColor = Colors.white;
          if (isTime1Selected == false)
            _time1Color = Colors.red;
          else
            _time1Color = Colors.white;
          if (isTime2Selected == false)
            _time2Color = Colors.red;
          else
            _time2Color = Colors.white;
          setState(() {});
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Brak danych"),
                  content: Text("Wprowadź niezbędne dane"),
                );
              });
        }
      }
    }
  }
}


class UpdateTask extends StatefulWidget {
  @override
  _UpdateTaskState createState(){
    updateTaskState = _UpdateTaskState();
    return updateTaskState ;
  }

  State updateTaskState;
  Task task;
  UpdateTask(this.task);
}

class _UpdateTaskState extends State<UpdateTask> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controllerName ;
  TextEditingController controllerDesc ;

  int id;
  Color dateColor;
  Color timeColor;
  bool isNotificationEnabled;
  bool isTimeSelected;
  bool isDateSelected;
  bool isLocalizationSelected;
  DateTime _terminData;
  DateTime _terminCzas;

  List<Localization> listOfLocalization;
  List<Group> listOfGroup;

  @override
  void initState() {
    print("start");
    listOfLocalization = List();
    listOfGroup = List();

    _controllerName = TextEditingController(text: widget.task.name);
    controllerDesc = TextEditingController(text: widget.task.description);

    if(widget.task.endTime == null ) {
      isNotificationEnabled = false ;
      isDateSelected = false ;
      isTimeSelected = false ;

    }else{
      isNotificationEnabled = true ;
      isDateSelected = true ;
      isTimeSelected = true ;
      _terminData = DateTime(widget.task.endTime.year,widget.task.endTime.month,widget.task.endTime.day);
      _terminCzas =  DateTime(0,0,0,widget.task.endTime.hour,widget.task.endTime.minute);
      _downloadData();
    }

    isLocalizationSelected = widget.task.localization.id == 0 ? false : true;

//     _terminData = DateTime();
//     _terminCzas = DateTime();

    dateColor = Colors.white;
    timeColor = Colors.white;

    super.initState();
  }

  void _downloadData() {
    NotifiHelper.listsTaskID(widget.task.id).then((onList) {
      if (onList != null) {
        widget.task.listNotifi.addAll(onList);
        setState(() {});
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dodaj zadanie',
          style: TextStyle(color: Colors.white),
        ),
        // tu kontrolujesz przycisk wstecz
        leading: new IconButton(
            icon: Icon(Icons.arrow_back), onPressed: onBackPressed),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              buildSpace(),
              //textfield z nazwa
              buildCustomTextFieldwithValidation(
                  "Nazwa", "Podaj nazwę nowego zadania", _controllerName),
              buildSpace(),
              //button z data
              buildCustomButtonWithValidation(
                  dateColor,
                  (isDateSelected)
                      ? DateFormat("dd/MM/yyyy").format(_terminData)
                      : "Nie wybrano daty",
                  Icons.date_range,
                  datePick,
                  buildClearButton(clearDate)),
              buildSpace(),
              //button z godzina
              buildCustomButtonWithValidation(
                  timeColor,
                  (isTimeSelected)
                      ? DateFormat("HH:mm").format(_terminCzas)
                      : "Nie wybrano godziny",
                  Icons.access_time,
                  timePick,
                  buildClearButton(clearTime)),
              buildSpace(),
              //button grupa
              buildCustomButton(
                  (widget.task.group.id == 0)
                      ? "Nie wybrano grupy"
                      : "${widget.task.group.name}",
                  Icons.account_circle,
                  goToGroupPickPage,
                  buildClearButton(clearGroup)),
              buildSpace(),
              //button powiadomienia
              buildCustomNotificationButton(
                ((widget.task.listNotifi).isEmpty)
                    ? "Nie wybrano powiadomień"
                    : ((widget.task.listNotifi).length == 1)
                    ? "Wybrano ${(widget.task.listNotifi).length} powiadomienie"
                    : ((widget.task.listNotifi).length < 5)
                    ? "Wybrano ${(widget.task.listNotifi).length} powiadomienia"
                    : ((widget.task.listNotifi).length < 21)
                    ? "Wybrano ${(widget.task.listNotifi).length} powiadomień"
                    : ((widget.task.listNotifi).length % 10 == 2 ||
                    (widget.task.listNotifi).length % 10 == 3 ||
                    (widget.task.listNotifi).length % 10 == 4)
                    ? "Wybrano ${(widget.task.listNotifi).length} powiadomienia"
                    : "Wybrano ${(widget.task.listNotifi).length} powiadomień",
                Icons.notifications,
                goToNotificationPickPage,
              ),
              buildSpace(),
              buildCustomButton(
                  (widget.task.localization.id == 0)
                      ? "Nie wybrano lokalizacji"
                      : "${widget.task.localization.name}",
                  Icons.edit_location,
                  goToLocalizationPickPage,
                  buildClearButton(clearLocalization)),
              buildSpace(),
              buildCustomTextField("Opis", "Wprowadź opis swojego zadania",
                  "Pole jest opcjonalne", controllerDesc),
              buildSpace(),
              ButtonBar(
                  children: [
                    buildButtonBarTile("Anuluj", Colors.red, goBack),
                    SizedBox(
                      width: 30,
                    ),
                    buildButtonBarTile(
                        "Dodaj", Colors.lightGreenAccent, acceptAndValidate)
                  ],
                  alignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  buttonMinWidth: 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCustomTextFieldwithValidation(
      String label, String hint, TextEditingController control) {
    return TextFormField(
        controller: control,
        decoration: new InputDecoration(
            filled: true,
            fillColor: new Color(0xFF333366),
            enabledBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white)),
            border: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
            hintText: hint,
            suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  control.clear();
                })),
        keyboardType: TextInputType.text,
        validator: (val) {
          if (val.isEmpty) {
            return 'Pole nie może być puste!';
          }
          return null;
        });
  }

  Widget buildClearButton(GestureTapCallback onPressed) {
    return SizedBox(
      width: 30,
      child: IconButton(
        color: Colors.white,
        icon: Icon(Icons.clear),
        onPressed: onPressed,
      ),
    );
  }

  Widget buildNotifiListClearButton(GestureTapCallback onPressed) {
    return SizedBox(
      width: 30,
      child: IconButton(
        color: Colors.white,
        icon: Icon(Icons.clear),
        onPressed: (isNotificationEnabled)? onPressed : null,
      ),
    );
  }

  Widget buildCustomTextField(
      String label, String hint, String helper, TextEditingController control) {
    return TextFormField(
      controller: control,
      decoration: new InputDecoration(
          filled: true,
          fillColor: new Color(0xFF333366),
          enabledBorder: new OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: new OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white)),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          hintText: hint,
          helperText: helper,
          helperStyle: TextStyle(color: Colors.white),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                control.clear();
              })),
      keyboardType: TextInputType.text,
    );
  }

  Widget buildSpace() {
    return SizedBox(
      height: 10.0,
    );
  }

  Widget buildCustomButtonWithValidation(Color textcolor, String text,
      IconData icon, GestureTapCallback onPressed, Widget clearButton) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20.0,
                  color: textcolor,
                ),
                Text(
                  " $text",
                  style: TextStyle(
                    color: textcolor,
                  ),
                ),
              ],
            ),
            clearButton,
          ],
        ),
      ),
      color: new Color(0xFF333366),
    );
  }

  Widget buildCustomButton(String text, IconData icon,
      GestureTapCallback onPressed, Widget clearButton) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20.0,
                ),
                Text(
                  " $text",
                  style: TextStyle(),
                ),
              ],
            ),
            clearButton,
          ],
        ),
      ),
      color: new Color(0xFF333366),
    );
  }

  Widget buildCustomNotificationButton(
      String text, IconData icon, GestureTapCallback onPressed) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      onPressed: (isNotificationEnabled) ? onPressed : null,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20.0,
                ),
                Text(
                  isNotificationEnabled
                      ? " $text"
                      : "Ustal temin by wybrać powiadomienia",
                  style: TextStyle(),
                ),
              ],
            ),
            buildNotifiListClearButton(clearNotifiList),
          ],
        ),
      ),
      color: new Color(0xFF333366),
    );
  }

  Widget buildButtonBarTile(
      String text, Color color, GestureTapCallback onPressed) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      color: new Color(0xFF333366),
      splashColor: color,
      child: Text("$text"),
      onPressed: onPressed,
    );
  }

  void clearDate() {
    isDateSelected = false;
    isNotificationEnabled = false;
    setState(() {});
  }

  void clearTime() {
    isTimeSelected = false;
    isNotificationEnabled = false;
    setState(() {});
  }

  void clearLocalization() {
    widget.task.localization = Localization(id: 0);
    setState(() {});
  }

  void clearGroup() {
    widget.task.group = Group(id: 0);
    setState(() {});
  }

  void clearNotifiList() {
    (widget.task.listNotifi).clear();
    setState(() {});
  }

  void datePick() {
    DatePicker.showDatePicker(context,
        theme: DatePickerTheme(
          backgroundColor: Colors.black38,
          itemStyle: TextStyle(color: Colors.white),
          cancelStyle: TextStyle(color: Colors.red),
          doneStyle: TextStyle(color: Colors.green[400]),
          containerHeight: 210.0,
        ),
        showTitleActions: true,
        minTime: DateTime(2020, 1, 1),
        maxTime: DateTime(2025, 12, 31), onConfirm: (date) {
          isDateSelected = true;
          if (isDateSelected && isTimeSelected) isNotificationEnabled = true;
          _terminData = date;
          setState(() {});
        }, currentTime: DateTime.now(), locale: LocaleType.pl);
  }

  void timePick() {
    DatePicker.showTimePicker(context,
        theme: DatePickerTheme(
          backgroundColor: Colors.black38,
          itemStyle: TextStyle(color: Colors.white),
          cancelStyle: TextStyle(color: Colors.red),
          doneStyle: TextStyle(color: Colors.green[400]),
          containerHeight: 210.0,
        ),
        showSecondsColumn: false,
        showTitleActions: true, onConfirm: (time) {
          isTimeSelected = true;
          if (isDateSelected && isTimeSelected) isNotificationEnabled = true;
          _terminCzas = time;
          setState(() {});
        }, currentTime: DateTime.now(), locale: LocaleType.pl);
  }

  void goBack() {
    Navigator.pop(context);
  }

  void goToNotificationPickPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddNotificationTask(widget.task,widget.updateTaskState)));
  }

  void goToLocalizationPickPage() {
    isLocalizationSelected = true;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddLocalization(widget.task, listOfLocalization,widget.updateTaskState)));
  }

  void goToGroupPickPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddGroup(widget.task, listOfGroup,widget.updateTaskState)));
  }

  void acceptAndValidate() {
    if (_formKey.currentState.validate()) {
      widget.task.name = _controllerName.text;
      widget.task.description = controllerDesc.text;
      if(isTimeSelected && isDateSelected) {
        print("isTimeSelected: $isTimeSelected");
        print("isDateSelected: $isDateSelected");

        widget.task.endTime = DateTime(_terminData.year, _terminData.month, _terminData.day, _terminCzas.hour, _terminCzas.minute);

      }else{
        widget.task.endTime = null;
      }

//        if (isNotificationEnabled)
//          clearNotifiList(); // clear listy powiadomien jesli ktos usunie terminy i bedzie dodawal task

      //print(widget.task.name + " " + "Opis: " + widget.task.description+ "Group: "+ widget.task.idGroup.toString());
      print("");
      print("Name: "+widget.task.name);
      print("EndTask: "+widget.task.endTime.toString());
      print("Desc: ${widget.task.description}");
      print("idGroup: ${widget.task.group.id}");
      print("Grupa: ${widget.task.group.name}");
      print("idLokalizacja: ${widget.task.localization.id}");
      print("Localization: ${widget.task.localization.name}");
      print("City: ${widget.task.localization.city}");
      print("Latitude: ${widget.task.localization.latitude}");
      print("Longitude: ${widget.task.localization.longitude}");
//
//        widget.task.listNotifi.forEach((t) => print(t.duration));
//
      TaskHelper.update(widget.task).then((onValue){
        GroupHelper.addlist(listOfGroup);
        LocalizationHelper.addlist(listOfLocalization);
        Navigator.of(context).pop();
      });



    }
  }

  void onBackPressed() {
    goBack();
  }

  void selectedGroup(String selectedGroup) {
    setState(() {});
  }

}
