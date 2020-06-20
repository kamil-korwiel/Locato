import 'package:Locato/Pages/AddUpdatePages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../MainClasses.dart';
import '../DatabaseHelper.dart';

class GroupCard extends StatefulWidget {
  @override
  _GroupCardState createState() => _GroupCardState();
  Group group;

  GroupCard(this.group);
}

class _GroupCardState extends State<GroupCard> {
  ///Stores a list of the group's tasks.
  List<Task> _list;

  ///Stores quantity of completed tasks, initialized as 0.
  int doneTasks = 0;

  @override
  void initState() {
    _list = List();
//    _downloadData();

    super.initState();
  }

//  void _downloadData() {
//    TaskHelper.listsID(widget.group.id).then((onList) {
//      if (onList != null) {
//        _list.addAll(onList);
//        setState(() {});
//      }
//    });
//  }

  @override
  Widget build(BuildContext context) {
    doneTasks = 0;
    return FutureBuilder(
      future: TaskHelper.listsID(widget.group.id),
      builder: (context, snapshot) {
        ///Connects to database.
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          // return Container();
          case ConnectionState.waiting:
          // return Container();
          case ConnectionState.active:
          case ConnectionState.done:
            _list = snapshot.data;
            if (_list != null) {
              doneTasks = 0;
              if (_list.isNotEmpty) {
                _list.forEach((task) {
                  if (task.done) doneTasks++;
                });
              }
              return Container(
                // Odstep miedzy grupami
                margin:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
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
        }
        return Container();
      },
    );
  }

  ///Builds a content of the group card.
  ///Starting with the header and then if not empty - tasks list.
  Widget _buildContent() {
    return Container(
        margin: new EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GroupCardHeader(widget.group, doneTasks, _list.length),
            SizedBox(height: 3.0),
            Container(
              margin: new EdgeInsets.symmetric(vertical: 8.0),
              height: 2.0,
              width: 20.0,
              color: new Color(0xFF00C6FF),
            ),
            if (_list.isNotEmpty) GroupCardTasks(_list),
          ],
        ));
  }
}

class GroupCardHeader extends StatelessWidget {
  ///Stores the percentage of group' progress for linear indicator view.
  var procent = 0.0;

  ///Obejct of a Group class.
  Group group;

  ///Stores length of task list.
  int length;

  ///Stores quantity of completed tasks.
  int howMuchDone;

  GroupCardHeader(this.group, this.howMuchDone, this.length);

  @override
  Widget build(BuildContext context) {
    if (howMuchDone == 0) {
      procent = 0;
    } else {
      procent = howMuchDone / length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ///Builds a name of the group with its numerical indication of tasks.
            Text(
              group.name,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              howMuchDone.toString() + " / " + length.toString(),
              style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
        SizedBox(height: 2.0),

        ///Builds a linear indicator with percentage.
        Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: 20.0,
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            Material(
              borderRadius: BorderRadius.circular(10.0),
              child: AnimatedContainer(
                constraints: BoxConstraints(
                  minWidth: 0.0,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                height: 20.0,
                width: MediaQuery.of(context).size.width * procent,
                //width: 10,
                duration: Duration(milliseconds: 1250),
                decoration: BoxDecoration(
                  color: Color(0xFF00C6FF),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            Center(
              child: Text(
                (procent * 100).toStringAsFixed(1) + "%",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GroupCardItem extends StatelessWidget {
  ///Stores declaration of function responsible for mark task as completed.
  final Function onPressedDone;

  ///Stores declaration of function responsible to take user to edit page.
  final Function onPressedEdit;

  ///Stores declaration of function responsible for deletion of task.
  final Function onPressedDelete;

  ///Stores a name of task.
  String name;

  ///Stores value of true if task is completed, false if otherwise.
  bool done;

  ///Stores object of a Localization class, shows chosen task's localization.
  Localization localization;

  ///Stores date of task.
  String date;

  ///Stores description of task.
  String description;

  GroupCardItem(Task task,
      {this.onPressedDone, this.onPressedEdit, this.onPressedDelete}) {
    this.name = task.name;
    this.done = task.done;
    if (task.endTime != null) {
      this.date = DateFormat("yyyy-MM-dd HH:mm").format(task.endTime);
    } else {
      this.date = "";
    }
    this.localization = task.localization;
    this.description = task.description;
  }

  @override
  Widget build(BuildContext context) {
    var txt = "";
    if (localization.street != null) {
      txt = localization.name+ "\n" + localization.street;
      if (localization.city != null) {
        txt += ", " + localization.city.substring(7);
      }
    } else {
      if (localization.city != null) {
        txt = localization.name+ "\n" +localization.city.substring(7);
      } else {
        txt = "Brak";
      }
    }

    ///Builds a ExpansionTile.
    ///Initially shows only name and if not empty localization and date.
    ///Avalible button to mark task as completed.
    ///On expanded shows task description and buttons to edit or delete task.
    return ListTileTheme(
      contentPadding: EdgeInsets.all(0),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Nazwa zadanai
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                // Lokalizacja zadania
                localization.city != null
                    ? Row(
                  children: <Widget>[
                    Icon(Icons.location_on, size: 12.0),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        txt,
                        style: TextStyle(
                          color: Color(0xFFB6B2DF),
                          fontFamily: 'Poppins',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                )
                    : Container(),
                // Data zadania
                date.isNotEmpty
                    ? Text(
                  date,
                  style: TextStyle(
                    color: Color(0xFFB6B2DF),
                    fontFamily: 'Poppins',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300,
                  ),
                )
                    : Container(),
              ],
            ),

            ///Builds a done task button.
            Container(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(Icons.done_outline),
                color: done ? Colors.lightGreen[600] : Colors.grey[400],
                onPressed: onPressedDone,
              ),
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
                      description,
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
                  ///Build an edit button.
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: onPressedEdit,
                  ),
                  SizedBox(width: 4.0),

                  ///Builds a delete button.
                  IconButton(
                      icon: Icon(Icons.delete), onPressed: onPressedDelete),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GroupCardTasks extends StatefulWidget {
  @override
  _GroupCardTasksState createState() => _GroupCardTasksState();

  ///Stores a list of the group's tasks.
  List<Task> tasks;

  GroupCardTasks(this.tasks);
}

class _GroupCardTasksState extends State<GroupCardTasks> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 2.0),
        Text(
          "Zadania",
          style: TextStyle(
              color: Color(0xFFB6B2DF),
              fontFamily: 'Poppins',
              fontSize: 9.0,
              fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 8.0),
        Divider(color: Colors.black54, height: 0.5),

        ///Builds a list of group's tasks, where single task is defined as GroupCardItem class.
        for (var task in widget.tasks)
          GroupCardItem(
            task,

            ///Mark the task as completed.
            onPressedDone: () {
              TaskHelper.dbHelper.query("SELECT JestesBlisko FROM Lokalizacja WHERE ID_Lokalizacji=${task.localization.id}").then((value) {
                task.localization.isNearBy = value==1?true:false;
                if (task.localization.id != 0) {
                  if (task.localization.isNearBy == true) {
                    task.done = !task.done;
                    TaskHelper.updateDone(task);
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Nie jesteś na miejscu."),
                            content: Text(
                                "Jeśli nie jesteś blisko miejsca zadania nie możesz go zakończyć."),
                          );
                        });
                  }
                } else {
                  task.done = !task.done;
                  TaskHelper.updateDone(task);
                }
                setState(() {});
                groupCardState.setState(() {});
              });
            },

            ///Takes user to page to edit selected task.
            onPressedEdit: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UpdateTask(task)));
            },

            ///Deletes selected task from list and database as well.
            onPressedDelete: () {
              TaskHelper.delete(task.id);
              groupCardState.setState(() {});
            },
          ),
      ],
    );
  }
}


///Stores state of GroupPage class, if changed rebuild widget.
_GroupTaskPageState groupCardState;

class GroupTaskPage extends StatefulWidget {
  @override
  _GroupTaskPageState createState() {
    groupCardState = _GroupTaskPageState();
    return groupCardState;
  }
}

class _GroupTaskPageState extends State<GroupTaskPage> {
  ///Stores a list of all groups.
  List<Group> listOfGroup;
  @override
  void initState() {
    listOfGroup = List();
    //_downloadData();

    super.initState();
  }

  void _downloadData() {
    GroupHelper.lists().then((onList) {
      if (onList != null) {
        listOfGroup = onList;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: GroupHelper.lists(),
        builder: (context, snapshot) {
          ///Download data from database.
          listOfGroup = snapshot.connectionState == ConnectionState.done
              ? snapshot.data
              : listOfGroup;

          return CustomScrollView(
            slivers: <Widget>[
              SliverList(
                ///Builds a list of all groups, where single group is declared as GroupCard class.
                delegate: SliverChildBuilderDelegate(
                      (context, index) => GroupCard(
                    listOfGroup[index],
                  ),
                  childCount: listOfGroup.length,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 80,),
                ]
                ),
              )
            ],
          );
        });
  }


}
