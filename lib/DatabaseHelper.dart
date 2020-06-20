import 'dart:io';
import 'package:Locato/Background/NotificationHelperBackground.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'MainClasses.dart';

class DatabaseHelper {
  ///Stores database name.
  static final _databaseName = "/Baza_danych";
  ///Stores database version.
  static final _databaseVersion = 1;
  ///
  static int index;
  ///Constructor to create instance of DatabaseHelper.
  DatabaseHelper._privateConstructor();
  ///Stores instance of database.
  static DatabaseHelper instance;

  factory DatabaseHelper() {
    if (instance == null) {
      index = 0;
      instance = DatabaseHelper._privateConstructor();
    }
    return instance;
  }

  static Database _database;
  ///Create database object and provide it with a getter where we will instantiate the database if it's not.
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }
  ///Opens database and create it if it doesn't exist.
  _initDatabase() async {
    ///Stores documents directory name where application may place data.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    ///Stores path to database.
    String path = documentsDirectory.path + _databaseName;
    print("${index} path: " + path);
    ++index;
  //  deleteDatabase(path);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }
  ///Used to create tables.
  Future _onCreate(
    ///Stores database.
    Database db, 
    ///Stores database version.
    int version) async {
    await db.execute('''
           CREATE TABLE Grupa (
     ID_Grupa     INTEGER   PRIMARY KEY,
     Nazwa_grupa  TEXT      NOT NULL,
     Ile_wykonane INTEGER   DEFAULT NULL
 )

           ''');
    await db.execute('''
            INSERT INTO Grupa (ID_Grupa,Nazwa_grupa,Ile_wykonane)
    VALUES (0,'Brak Grupy',0)
    ''');

    await db.execute('''
           CREATE TABLE Powiadomienia(
     ID_Powiadomienia     INTEGER   PRIMARY KEY,
     ID_Task              INTEGER NOT NULL,
     ID_Event             INTEGER NOT NULL,
     Czas                 TEXT    DEFAULT NULL
 )
           ''');

    await db.execute('''
           CREATE TABLE Lokalizacja (
     ID_Lokalizacji INTEGER   PRIMARY KEY,
     Latitude       DOUBLE    DEFAULT NULL,
     Longitude      DOUBLE    DEFAULT NULL,
     Nazwa          TEXT      DEFAULT NULL,
     Miasto         TEXT      DEFAULT NULL,
     Ulica          TEXT      DEFAULT NULL,
     JestesBlisko   BOOLEAN   DEFAULT NULL,
     WyslanoPowiadomienie BOOLEAN DEFAULT NULL
 )
           ''');

    await db.execute('''
            INSERT INTO Lokalizacja (ID_Lokalizacji,Latitude,Longitude,Nazwa,Miasto,Ulica,JestesBlisko,WyslanoPowiadomienie)
    VALUES (0,0,0,NULL,NULL,NULL,0,0)
    ''');


    await db.execute('''
           CREATE TABLE Task (
     ID_Task        INTEGER     PRIMARY KEY,
     Nazwa          TEXT        NOT NULL,
     Zrobione       BOOLEAN     NOT NULL,
     Do_Kiedy       TEXT        DEFAULT NULL,
     Opis           TEXT        DEFAULT NULL,
     Lokalizacja    INTEGER     DEFAULT NULL,
     Grupa          INTEGER     DEFAULT NULL,
     FOREIGN KEY(Grupa) REFERENCES Grupa(ID_Grupa),
     FOREIGN KEY(Lokalizacja) REFERENCES Lokalizacja(ID_Lokalizacji)
 )
           ''');


    await db.execute('''
           CREATE TABLE Wydarzenie (
     ID_Wydarzenie INTEGER    PRIMARY KEY,
     Nazwa         TEXT       NOT NULL,
     Termin_od     TEXT       DEFAULT NULL,
     Termin_do     TEXT       DEFAULT NULL,
     Opis          TEXT       DEFAULT NULL,
     Cykl          VARCHAR(2) DEFAULT NULL,
     Kolor         TEXT       DEFAULT NULL
 )
           ''');

  }
  ///Used to insert row into table.
  Future<int> insert(
    ///Stores table name.
    String table, 
    ///Stores contents of row to insert.
    Map<String, dynamic> row) async {
    ///Stores instance of database.
    Database db = await instance.database;
    return await db.insert(table, row);
  }
  ///Used to query all rows from table.
  Future<List<Map<String, dynamic>>> queryAllRows(
    ///Stores table name.
    String table) async {
    ///Stores instance of database.
    Database db = await instance.database;
    return await db.query(table);
  }

  ///Used to query list of tasks from specific group.
  Future<List<Map<String, dynamic>>> queryIdRowsTask(int id) async {
    ///Stores instance of database.
    Database db = await instance.database;
    return await db.rawQuery('SELECT * FROM Task WHERE Grupa=$id');
  }
  ///Used to query events from 7 days.
  Future<List<Map<String, dynamic>>> queryEventWeekend() async {
    ///Stores instance of database.
    Database db = await instance.database;
    return await db.rawQuery(
        "SELECT * FROM Wydarzenie WHERE date(Termin_od) >= date('now') AND date(Termin_od) <= date('now','+7 day')");
  }
  ///Used to query events from specific day.
  Future<List<Map<String, dynamic>>> queryEventDay(
    ///Stores day which we want to query events list.
    int day) async {
    ///Stores instance of database.
    Database db = await instance.database;
    return await db.rawQuery(
        "SELECT * FROM Wydarzenie WHERE date(Termin_od) = date('now','+$day day')");
  }
  ///Used to query notification by ID_Task
  Future<List<Map<String, int>>> queryTaskNotifiId(int id) async {
    ///Stores instance of database.
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM Powiadomienia WHERE ID_Task= $id");
  }
  ///Used to query all tables from database and showing on console
  Future<void> showalltables() async {
    ///Stores instance of database.
    Database db = await instance.database;
    List<Map<String, dynamic>> mapGroup =
        await db.rawQuery("SELECT * FROM Grupa");
    List<Map<String, dynamic>> mapNotifi =
        await db.rawQuery("SELECT * FROM Powiadomienia");
    List<Map<String, dynamic>> mapLocal =
        await db.rawQuery("SELECT * FROM Lokalizacja");
    List<Map<String, dynamic>> mapTask =
        await db.rawQuery("SELECT * FROM Task");
    List<Map<String, dynamic>> mapEvent =
        await db.rawQuery("SELECT * FROM Wydarzenie");

    print("\nID_Task\t"
        "Nazwa\t"
        "Zrobione\t"
        "Do_Kiedy\t"
        "Opis\t"
        "Lokalizacja\t"
        "Grupa\t");
    mapTask.forEach((m) {
      print("${m['ID_Task'].toString()}\t\t"
          "${m['Nazwa'].toString()}\t"
          "${m['Zrobione'].toString()}\t"
          "${m['Do_Kiedy'].toString()}\t"
          "${m['Opis'].toString()}\t"
          "${m['Lokalizacja'].toString()}\t"
          "${m['Grupa'].toString()}\t");
    });

    print("\nID_Wydarzenie\t" "Nazwa\t" "Termin_od\t" "Termin_do\t" "Opis\t");
    mapEvent.forEach((m) {
      print("${m['ID_Wydarzenie'].toString()}\t\t\t"
          "${m['Nazwa'].toString()}\t"
          "${m['Termin_od'].toString()}\t"
          "${m['Termin_do'].toString()}\t"
          "${m['Opis'].toString()}\t");
    });

    print("\nID_Grupa\t" "Nazwa_grupa\t");
    mapGroup.forEach((m) {
      print(
          "${m['ID_Grupa'].toString()}\t\t" "${m['Nazwa_grupa'].toString()}\t");
    });

    print("\nID_Lokalizacji\t"
        "Latitude\t"
        "Longitude\t"
        "Nazwa\t"
        "Miasto\t"
        "Ulica\t");
    mapLocal.forEach((m) {
      print("${m['ID_Lokalizacji'].toString()}\t\t\t\t"
          "${m['Latitude'].toString()}\t"
          "${m['Longitude'].toString()}\t"
          "${m['Nazwa'].toString()}\t"
          "${m['Miasto'].toString()}\t"
          "${m['Ulica'].toString()}\t"
          "${m['JestesBlisko'].toString()}\t"
          "${m['WyslanoPowiadomienie'].toString()}");
    });
    print("\nID_Powiadomienia\t" "ID_Task\t" "ID_Event\t" "Czas\t");
    mapNotifi.forEach((m) {
      print("${m['ID_Powiadomienia'].toString()}\t\t\t\t"
          "${m['ID_Task'].toString()}\t\t"
          "${m['ID_Event'].toString()}\t\t"
          "${m['Czas'].toString()}\t");
    });
  }
  ///Return row count in specific table.
  Future<int> query(
    ///Stores table name.
    String q) async {
    ///Stores instance of database.
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery(q));
  }
  ///Used to upated row in database.
  Future<int> update(
      ///Stores table name.
      String table, 
      ///Stores column id name in specific table.
      String columnId, 
      ///Stores row id to update.
      int id, 
      ///Stores contents of row to update.
      Map<String, dynamic> row) async {
    ///Stores instance of database.
    Database db = await instance.database;
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }
  ///Used to delete row from database.
  Future<int> delete(
    ///Stores table name.
    String table, 
    ///Stores column id name in specific table.
    String columnId, 
    ///Stores row id to delete.
    int id) async {
    ///Stores instance of database.
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}

class EventHelper {
  ///Stores instance of database.
  static final dbHelper = DatabaseHelper.instance;

  ///Adding Event and all Notifi to DataBase and schedule Notifications
  static Future<void> add(Event newEvent) async {
    int IdEvent = await dbHelper.query("SELECT MAX(ID_Wydarzenie) FROM Wydarzenie");
    //pickedIdEvent = pickedIdEvent == null ? 0 : pickedIdEvent;
    //print("LOLLLLLLLL: $pickedIdEvent");
    IdEvent = IdEvent == null ? 0 : IdEvent;
    print(DateFormat("yyyy-MM-dd HH:mm").format(newEvent.beginTime));
    dbHelper.insert('Wydarzenie', {
      'ID_Wydarzenie': ++IdEvent ,
      'Nazwa': newEvent.name,
      'Termin_od': DateFormat("yyyy-MM-dd HH:mm").format(newEvent.beginTime),
      'Termin_do': DateFormat("yyyy-MM-dd HH:mm").format(newEvent.endTime),
      'Cykl': newEvent.cycle,
      'Kolor': newEvent.color,
      'Opis': newEvent.description,
    });


    newEvent.listNotifi.forEach((n) => n.idEvent = IdEvent);
    NotifiHelper.addListNotifiEvent(newEvent);

  }
  ///Update Event and all Notifi in DataBase and schedule Notifications
  static Future<void> update(Event updatedEvent) async {
    dbHelper.update('Wydarzenie', 'ID_Wydarzenie', updatedEvent.id, {
      'Nazwa': updatedEvent.name,
      'Termin_od': DateFormat("yyyy-MM-dd HH:mm").format(updatedEvent.beginTime),
      'Termin_do': DateFormat("yyyy-MM-dd HH:mm").format(updatedEvent.endTime),
      'Cykl': updatedEvent.cycle,
      'Kolor': updatedEvent.color,
      'Opis': updatedEvent.description,
    });

    updatedEvent.listNotifi.forEach((n) => n.idEvent = updatedEvent.id);
    NotifiHelper.addListNotifiEvent(updatedEvent);

  }
  ///Delete Event and all Notifi in  DataBase and canceled Notifications
  static Future<void> delete(int pickedIdEvent) async {
    dbHelper.delete('Wydarzenie', 'ID_Wydarzenie', pickedIdEvent);
    NotificationHelperBackground.deleteEvent(pickedIdEvent);
  }
  ///Used to query all events
  static Future<List<Event>> lists() async {
    final List<Map<String, dynamic>> maps =
    await dbHelper.queryAllRows('Wydarzenie');
    return List.generate(maps.length, (i) {
      return Event(
        id: maps[i]['ID_Wydarzenie'],
        name: maps[i]['Nazwa'],
        beginTime: new DateFormat("yyyy-MM-dd HH:mm").parse(maps[i]['Termin_od']),
        endTime: new DateFormat("yyyy-MM-dd HH:mm").parse(maps[i]['Termin_do']),
        cycle: maps[i]['Cykl'],
        color: maps[i]['Kolor'],
        description: maps[i]['Opis'],
      );
    });
  }
  ///Used to query all events from specific day
  static Future<List<Event>> listsDay(int day) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryEventDay(day);
    return List.generate(maps.length, (i) {
      return Event(
        id: maps[i]['ID_Wydarzenie'],
        name: maps[i]['Nazwa'],
        beginTime: maps[i]['Termin_od'],
        endTime: maps[i]['Termin_do'],
        cycle: maps[i]['Cykl'],
        color: maps[i]['Kolor'],
        description: maps[i]['Opis'],
      );
    });
  }

}


class GroupHelper {
  ///Stores instance of database
  static final dbHelper = DatabaseHelper.instance;

  ///Adding Group to Database
  static Future<int> add(Group newGroup) async {
    int IdGroup = await dbHelper.query("SELECT max(ID_Grupa) FROM Grupa");
    IdGroup = IdGroup == null ? 0: IdGroup;
    dbHelper.insert('Grupa', {
      'ID_Grupa': IdGroup + 1,
      'Nazwa_grupa': newGroup.name,
      'Ile_wykonane': newGroup.howMuchDone,
    });
    return IdGroup + 1;
  }
  ///Adding list of Groups to Database
  static Future<void> addlist(List<Group> list) async {
    //await Future.delayed(Duration(seconds: 1));
    int IdGroup = await dbHelper.query("SELECT max(ID_Grupa) FROM Grupa");
    IdGroup = IdGroup == null ? 0: IdGroup;
    list.forEach((g) {
      dbHelper.insert('Grupa', {
        'ID_Grupa': IdGroup + 1,
        'Nazwa_grupa': g.name,
        'Ile_wykonane': g.howMuchDone,
      });
      IdGroup++;
    });
  }

  ///Updating Group in Database
  static Future<void> update(Group updatedGroup) async {

    dbHelper.update('Grupa', 'ID_Grupa', updatedGroup.id, {
      'Nazwa_grupa': updatedGroup.name,
      'Ile_wykonane': updatedGroup.howMuchDone,
    });
  }
  ///Deleting Group in Database bi id Group
  static Future<void> delete(int pickedIdGroup,) async {


    dbHelper.delete('Grupa', 'ID_Grupa', pickedIdGroup);

  }


  ///Deleting Group and Replace id Grupa in Task to BrakZadan id=0
  static Future<void> deleteAndReplaceIdTask(int id) async {
    Database db = await dbHelper.database;
    db.rawUpdate("UPDATE Task SET Grupa = 0 WHERE Grupa = $id");
    dbHelper.delete('Grupa', 'ID_Grupa', id);
  }

  ///Calculating  done percent Tasks in Group using id Group
  static Future<int> getPercent(int id) async {
    int countdone = await dbHelper.query("SELECT COUNT(*) FROM Task WHERE Grupa=$id AND Zrobione=1");
    int countALL = await dbHelper.query("SELECT COUNT(*) FROM Task WHERE Grupa=$id");

    return (100 * (countdone/countALL)).round();
  }


  ///Used to query all Groups
  static Future<List<Group>> lists() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryAllRows('Grupa');
    return List.generate(maps.length, (i) {
      return Group(
        id: maps[i]['ID_Grupa'],
        name: maps[i]['Nazwa_grupa']
      );
    });
  }



}


class LocalizationHelper {
  ///Stores instance of database.
  static final dbHelper = DatabaseHelper.instance;

  ///Used to add new localization to database.
  static Future<int> add(Localization newLocalization) async {
    int IdLocalization =
    await dbHelper.query("SELECT MAX(ID_Lokalizacji) FROM Lokalizacja");

    dbHelper.insert('Lokalizacja', {
      'ID_Lokalizacji': IdLocalization + 1,
      'Latitude': newLocalization.latitude,
      'Longitude': newLocalization.longitude,
      'Nazwa': newLocalization.name,
      'Miasto': newLocalization.city,
      'Ulica': newLocalization.street,
      'JestesBlisko': newLocalization.isNearBy == true ? 1:0,
      'WyslanoPowiadomienie': 0,
    });

    return IdLocalization + 1;
  }

  ///Used to add list of localizations to database.
  static Future<void> addlist(List<Localization> list) async {
    //await Future.delayed(Duration(seconds: 1));
    int IdLocalization =
    await dbHelper.query("SELECT MAX(ID_Lokalizacji) FROM Lokalizacja");
    list.forEach((l) {
      dbHelper.insert('Lokalizacja', {
        'ID_Lokalizacji': IdLocalization + 1,
        'Latitude': l.latitude,
        'Longitude': l.longitude,
        'Nazwa': l.name,
        'Miasto': l.city,
        'Ulica': l.street,
        'JestesBlisko': 0,
        'WyslanoPowiadomienie': 0,
      });
      IdLocalization++;
    });
  }

  ///Used to display notification if user is nearby of some task' localization
  static Future<void> updateStatus(Localization updatedLocalization) async {
    dbHelper.update('Lokalizacja', 'ID_Lokalizacji', updatedLocalization.id, {
      'JestesBlisko': updatedLocalization.isNearBy ? 1 : 0,
      'WyslanoPowiadomienie': updatedLocalization.wasNotified ? 1 : 0,
    });
  }

  ///Used to update existing localization in database.
  static Future<void> update(Localization updatedLocalization) async {
    dbHelper.update('Lokalizacja', 'ID_Lokalizacji', updatedLocalization.id, {
      'Latitude': updatedLocalization.latitude,
      'Longitude': updatedLocalization.longitude,
      'Nazwa': updatedLocalization.name,
      'Miasto': updatedLocalization.city,
      'Ulica': updatedLocalization.street,
      'JestesBlisko': 0,
      'WyslanoPowiadomienie': 0,
    });
  }

  ///Used to delete localization from database.
  static Future<void> delete(int pickedIdLocalization) async {
    dbHelper.delete('Lokalizacja', 'ID_Lokalizacji', pickedIdLocalization);
  }

  static Future<void> deleteAndReplaceIdTask(int id) async {
    Database db = await dbHelper.database;
    db.rawUpdate("UPDATE Task SET Lokalizacja = 0 WHERE Lokalizacja = $id");
    dbHelper.delete('Lokalizacja', 'ID_Lokalizacji', id);
  }

  ///Used to list all of localizations from database.
  static Future<List<Localization>> lists() async {
    Database db = await dbHelper.database;

    final List<Map<String, dynamic>> maps =
    await db.rawQuery("SELECT * FROM Lokalizacja");
    return List.generate(maps.length, (i) {
      return Localization(
        id: maps[i]['ID_Lokalizacji'],
        latitude: maps[i]['Latitude'],
        longitude: maps[i]['Longitude'],
        name: maps[i]['Nazwa'],
        city: maps[i]['Miasto'],
        street: maps[i]['Ulica'],
        isNearBy: maps[i]['JestesBlisko'] == 1 ? true : false,
        wasNotified: maps[i]['WyslanoPowiadomienie'] == 1 ? true : false,
      );
    });
  }

  ///Used to reset all notifications status
  static Future<List<Localization>> resetAllStatus() async {
    Database db = await dbHelper.database;
    db.rawUpdate(
        "UPDATE Lokalizacja SET JestesBlisko = 0, WyslanoPowiadomienie = 0");
  }
}

class NotifiHelper {
  ///Stores instance of database
  static final dbHelper = DatabaseHelper.instance;

  ///Adding Notifi to Database
  static Future<void> add(Notifi notifi) async {
    int IdNotifi = await dbHelper.query("SELECT MAX(ID_Powiadomienia) FROM Powiadomienia");

    print("ID Notifi:  $IdNotifi");

    IdNotifi = IdNotifi == null ? 0 : IdNotifi;
    dbHelper.insert('Powiadomienia', {
      'ID_Powiadomienia': ++IdNotifi,
      'ID_Task': notifi.idTask,
      'ID_Event': notifi.idEvent,
      'Czas': notifi.duration.toString(),
    });
  }
  ///Adding list of Notifi to Database using Task
  static Future<void> addListNotifiTask(Task task) async {
    if(task.listNotifi.isNotEmpty) {
      int IdNotifi = await dbHelper.query(
          "SELECT MAX(ID_Powiadomienia) FROM Powiadomienia");

      // print("ID Notifi:  $IdNotifi");

      IdNotifi = IdNotifi == null ? 0 : IdNotifi;
      for (Notifi n in task.listNotifi) {
        if(n.id == null) {
          n.id = ++IdNotifi;
          dbHelper.insert('Powiadomienia', {
            'ID_Powiadomienia': n.id,
            'ID_Task': n.idTask,
            'ID_Event': -1,
            'Czas': n.duration.toString(),
          });
        }
      }
      NotificationHelperBackground.ListOfTaskNotifi(task);
    }
  }
  ///Adding list of Notifi to Database using Event
  static Future<void> addListNotifiEvent(Event event) async {
    if(event.listNotifi.isNotEmpty) {
      int IdNotifi = await dbHelper.query(
          "SELECT MAX(ID_Powiadomienia) FROM Powiadomienia");

      // print("ID Notifi:  $IdNotifi");

      IdNotifi = IdNotifi == null ? 0 : IdNotifi;
      for (Notifi n in event.listNotifi) {
        if(n.id == null) {
          n.id = ++IdNotifi;
          dbHelper.insert('Powiadomienia', {
            'ID_Powiadomienia': n.id,
            'ID_Task': -1,
            'ID_Event': n.idEvent,
            'Czas': n.duration.toString(),
          });
        }
      }
      NotificationHelperBackground.ListOfEventNotifi(event);
    }
  }

  ///Updating Notifi in Database
  static Future<void> update(Notifi notifi) async {
    dbHelper.update('Wydarzenie', 'ID_Wydarzenie', notifi.id, {
      'ID_Task': notifi.idTask,
      'ID_Event': notifi.idEvent,
      'Czas': notifi.duration.toString(),
    });
  }

  ///Delete Notifi in Database
  static Future<void> delete(int id) async {
    dbHelper.delete('Powiadomienia', 'ID_Powiadomienia', id);
    NotificationHelperBackground.deleteNotifi(id);
  }

  static Future<void> deleteTask(Notifi notifi) async {
    Database db = await dbHelper.database;
    db.rawDelete(
        'DELETE FROM Powiadomienia WHERE ID_Task = ? AND ID_Powiadomienia = ?',
        [notifi.idTask, notifi.id]);
  }
  ///Delete all Notifi with id Task in Database
  static Future<void> deleteTaskID(int id) async {
    Database db = await dbHelper.database;
    db.rawDelete('DELETE FROM Powiadomienia WHERE ID_Task = ?', [
      id,
    ]);
  }

  ///Delete all Notifi with id Event in Database
  static Future<void> deleteEventID(int id) async {
    Database db = await dbHelper.database;
    db.rawDelete('DELETE FROM Powiadomienia WHERE ID_Event = ?', [
      id,
    ]);
  }

  ///Used to query all Notifi
  static Future<List<Notifi>> lists() async {
    final List<Map<String, dynamic>> maps =
    await dbHelper.queryAllRows('Powiadomienia');
    return List.generate(maps.length, (i) {
      return Notifi(
        id: maps[i]['ID_Powiadomienia'],
        idTask: maps[i]['ID_Task'],
        idEvent: maps[i]['ID_Event'],
        duration: _parseDuration(maps[i]['Czas']),
      );
    });
  }

  ///Used to query all Notifi using Task id
  static Future<List<Notifi>> listsTaskID(int id) async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps =
    await db.rawQuery('SELECT * FROM Powiadomienia WHERE ID_Task=$id');
    return List.generate(maps.length, (i) {
      return Notifi(
        id: maps[i]['ID_Powiadomienia'],
        idTask: maps[i]['ID_Task'],
        idEvent: maps[i]['ID_Event'],
        duration: _parseDuration(maps[i]['Czas']),
      );
    });
  }

  ///Used to query all Notifi using Event id
  static Future<List<Notifi>> listsEventID(int id) async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps =
    await db.rawQuery('SELECT * FROM Powiadomienia WHERE ID_Event=$id');
    print("MapNotifiEvent: ${maps.length.toString()}");
    return List.generate(maps.length, (i) {
      return Notifi(
        id: maps[i]['ID_Powiadomienia'],
        idTask: maps[i]['ID_Task'],
        idEvent: maps[i]['ID_Event'],
        duration: _parseDuration(maps[i]['Czas']),
      );
    });
  }

  /// method to convert String to Duration
  static Duration _parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }
}

class TaskHelper {
  ///Stores instance of database.
  static final dbHelper = DatabaseHelper.instance;


  ///Adding 'Task' and all 'Notifi' list to DataBase and schedule Notifications
  static Future<void> add( Task newTask ) async {
    int IdTask = await dbHelper.query("SELECT max(ID_Task) FROM Task");
    IdTask = IdTask == null ? 0 : IdTask;

    int IdGroup = newTask.group.id == null ? await GroupHelper.add(newTask.group) : newTask.group.id;
    //print("IDGROUP : $IdGroup");

    //
    if(newTask.localization.id == null){
      Position pos = await Geolocator().getCurrentPosition();
      double dist = await Geolocator().distanceBetween(newTask.localization.latitude, newTask.localization.longitude, pos.latitude, pos.longitude);

      newTask.localization.isNearBy = dist < 200.0 ? true : false;
    }


    int IdLocal =  newTask.localization.id == null ? await LocalizationHelper.add(newTask.localization) : newTask.localization.id;


    dbHelper.insert('Task', {
      'ID_Task': ++IdTask ,
      'Nazwa': newTask.name,
      'Zrobione': newTask.done ? 1 : 0,
      'Do_Kiedy': newTask.endTime!=null?DateFormat("yyyy-MM-dd HH:mm").format(newTask.endTime):null,
      'Opis': newTask.description,
      'Lokalizacja': IdLocal,
      'Grupa': IdGroup,
    });

    newTask.listNotifi.forEach((n) => n.idTask = IdTask);
    NotifiHelper.addListNotifiTask(newTask);
  }


  ///Updating only 'Zrobione' in DataBase
  static Future<void> updateDone( updatedTask ) async {
    dbHelper.update('Task', 'ID_Task', updatedTask.id, {
      'Zrobione': updatedTask.done ? 1 : 0,
    });
  }



  ///Updating 'Task' and all 'Notifi' list to DataBase and schedule Notifications
  static Future<void> update( updatedTask ) async {

    int IdGroup = updatedTask.group.id == null ? await GroupHelper.add(updatedTask.group) : updatedTask.group.id;

    if(updatedTask.localization.id == null){
      Position pos = await Geolocator().getCurrentPosition();
      double dist = await Geolocator().distanceBetween(updatedTask.localization.latitude, updatedTask.localization.longitude, pos.latitude, pos.longitude);

      updatedTask.localization.isNearBy = dist < 200.0 ? true : false;
    }

    int IdLocal =  updatedTask.localization.id == null ? await LocalizationHelper.add(updatedTask.localization) : updatedTask.localization.id;



    dbHelper.update('Task', 'ID_Task', updatedTask.id, {
      'Nazwa': updatedTask.name,
      'Zrobione': updatedTask.done ? 1 : 0,
      'Do_Kiedy': updatedTask.endTime!=null?DateFormat("yyyy-MM-dd HH:mm").format(updatedTask.endTime):null,
      'Opis': updatedTask.description,
      'Lokalizacja': IdLocal,
      'Grupa': IdGroup,
    });

    updatedTask.listNotifi.forEach((n) => n.idTask = updatedTask.id);
    NotifiHelper.addListNotifiTask(updatedTask);

  }

  ///Delete 'Task' and  all 'Notifi' to DataBase and canceled Notifications
  static Future<void> delete(int pickedIdTask) async {
    dbHelper.delete('Task', 'ID_Task', pickedIdTask);
    await NotificationHelperBackground.deleteTask(pickedIdTask);
  }
  ///Delete Task when is done and date is less then today
  static Future<void> deleteDoneTaskToday() async {
    Database db = await dbHelper.database;
    db.rawDelete("DELETE FROM Task WHERE date(Do_Kiedy) = date('now') AND Zrobione = 1" );
  }


  ///Delete Task when is done and date is less then today
  static Future<List<Task>> lists() async {
    //final List<Map<String, dynamic>> maps2 = await dbHelper.queryAllRows('Task');
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('''
        SELECT t.ID_Task, t.Nazwa, t.Zrobione, t.Do_Kiedy, t.Opis, t.Lokalizacja, t.Grupa,
        l.Nazwa AS Nazwa_Lokalizacji, l.Miasto, l.Ulica,
        g.Nazwa_grupa
        FROM Task AS t 
        INNER JOIN Lokalizacja AS l ON (l.ID_Lokalizacji = t.Lokalizacja) 
        INNER JOIN Grupa AS g ON (g.ID_Grupa = t.Grupa)''');

    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['ID_Task'],
        done: maps[i]['Zrobione']  == 1 ? true : false,
        name: maps[i]['Nazwa'],
        endTime: maps[i]['Do_Kiedy'] != null ? new DateFormat("yyyy-MM-dd HH:mm").parse(maps[i]['Do_Kiedy']) : null,
        description: maps[i]['Opis'],
        localization: Localization(
          id: maps[i]['Lokalizacja'],
          name: maps[i]['Nazwa_Lokalizacji'],
          city: maps[i]['Miasto'],
          street: maps[i]['Ulica'],
          isSelected: true,
        ),
        group: Group(
          id: maps[i]['Grupa'],
          name: maps[i]['Nazwa_grupa'],
          isSelected: true,
        ),
      );
    });
  }

  ///Used to query 'Tasks' by 'id' Group
  static Future<List<Task>> listsID(int id) async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('''
        SELECT t.ID_Task, t.Nazwa, t.Zrobione, t.Do_Kiedy, t.Opis, t.Lokalizacja, t.Grupa,
        l.Nazwa AS Nazwa_Lokalizacji, l.Miasto, l.Ulica, l.JestesBlisko,
        g.Nazwa_grupa
        FROM Task AS t 
        INNER JOIN Lokalizacja AS l ON (l.ID_Lokalizacji = t.Lokalizacja) 
        INNER JOIN Grupa AS g ON (g.ID_Grupa = t.Grupa)
        WHERE Grupa = ?
        ''', [id]);

    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['ID_Task'],
        done: maps[i]['Zrobione']  == 1 ? true : false,
        name: maps[i]['Nazwa'],
        endTime: maps[i]['Do_Kiedy'] != null ? new DateFormat("yyyy-MM-dd HH:mm").parse(maps[i]['Do_Kiedy']) : null,
        description: maps[i]['Opis'],
        localization: Localization(
          id: maps[i]['Lokalizacja'],
          name: maps[i]['Nazwa_Lokalizacji'],
          city: maps[i]['Miasto'],
          street: maps[i]['Ulica'],
          isNearBy: maps[i]['JestesBlisko']== 1? true:false,
          isSelected: true,
        ),
        group: Group(
          id: maps[i]['Grupa'],
          name: maps[i]['Nazwa_grupa'],
          isSelected: true,
        ),
      );
    });
  }


  ///Used to query 'Tasks' by 'id' Localization
  static Future<List<Task>> listsIDLocal(int idloca) async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('''
        SELECT t.ID_Task, t.Nazwa, t.Zrobione, t.Do_Kiedy, t.Opis,
        g.Nazwa_grupa
        FROM Task AS t 
        INNER JOIN Grupa AS g ON (g.ID_Grupa = t.Grupa)
        WHERE Lokalizacja = ?
        ''', [idloca]);

    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['ID_Task'],
        done: maps[i]['Zrobione']  == 1 ? true : false,
        name: maps[i]['Nazwa'],
        description: maps[i]['Opis'],
        group: Group(
          name: maps[i]['Nazwa_grupa'],
        ),
      );
    });
  }



}
