import 'dart:math';
import 'package:Locato/DatabaseHelper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../MainClasses.dart';


///Abstract class, helping to schedule Notification on project Loacato
abstract class NotificationHelperBackground{
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static AndroidInitializationSettings initSettingsAndroid;
  static IOSInitializationSettings initSettingsIOS;
  static  InitializationSettings initSettings;

  static  AndroidNotificationDetails androidPlatformChannelSpecifics ;
  static IOSNotificationDetails iOSChannelSpecifics ;
  static NotificationDetails platformChannelSpecifics;

  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin  {
    return init();
  }

  /// Creating some class needed to start using this class. This must be called before setting any notification.
  static init(){
    if(_flutterLocalNotificationsPlugin == null) {
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_notif');
      initSettingsIOS = IOSInitializationSettings();
      initSettings =
          InitializationSettings(initSettingsAndroid, initSettingsIOS);

      androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'chanel_ID', 'chanel name', 'channel description',
          importance: Importance.Max, priority: Priority.High);
      iOSChannelSpecifics = IOSNotificationDetails();
      platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSChannelSpecifics);


      _flutterLocalNotificationsPlugin.initialize(initSettings,
          onSelectNotification: _onSelectNotification
      );
    }
    return _flutterLocalNotificationsPlugin;
  }



/// Doing something after clicked notification
  static Future _onSelectNotification(String payload) async {
    if(payload != null){
      print('Notification payload: $payload');
    }
    //await Navigator.push(context, MaterialPageRoute(builder: (context)=> SecondRoute()));
  }
  /// Adding notification
  static Future<void> add(int id_notifi, String title, String description , DateTime when) async {
    await _flutterLocalNotificationsPlugin.schedule(id_notifi, title, description, when, platformChannelSpecifics);
  }

  /// When method is called then showing a notification immediately.
  static Future<void> now(String title,String decription) async {
    int isolateId = Random().nextInt(100000000);
    print("isolateId: $isolateId");
    await _flutterLocalNotificationsPlugin.show(isolateId,title, decription, platformChannelSpecifics);
  }

  /// When give class 'Task' to method then created is scheduled all Nofification
  static void ListOfTaskNotifi(Task task)  {
    String title;
      for(Notifi n in task.listNotifi) {
        title = (task.endTime.year == task.endTime.subtract(n.duration).year && task.endTime.month == task.endTime.subtract(n.duration).month && task.endTime.day-1 == task.endTime.subtract(n.duration).day)?"Jutro o ${DateFormat("HH:mm").format(task.endTime)}":
        (task.endTime.year == task.endTime.subtract(n.duration).year && task.endTime.month == task.endTime.subtract(n.duration).month && task.endTime.day == task.endTime.subtract(n.duration).day)?"Dziś o ${DateFormat("HH:mm").format(task.endTime)}":
        "${DateFormat("dd/MM/yyyy").format(task.endTime)}";
        _flutterLocalNotificationsPlugin.schedule(n.id, title + "Masz Zadanie do zrobienia:", task.name, task.endTime.subtract(n.duration), platformChannelSpecifics);
      }
  }
  /// When give class 'Event' to method then created is scheduled all Nofification
  static void ListOfEventNotifi(Event event) {
    String title;
    for(Notifi n in event.listNotifi){

      title = (event.beginTime.year == event.beginTime.subtract(n.duration).year && event.beginTime.month == event.beginTime.subtract(n.duration).month && event.beginTime.day-1 == event.beginTime.subtract(n.duration).day)?"Jutro o ${DateFormat("HH:mm").format(event.beginTime)}":
      (event.beginTime.year == event.beginTime.subtract(n.duration).year && event.beginTime.month == event.beginTime.subtract(n.duration).month && event.beginTime.day == event.beginTime.subtract(n.duration).day)?"Dziś o ${DateFormat("HH:mm").format(event.beginTime)}":
      "${DateFormat("dd/MM/yyyy").format(event.beginTime)}";

      _flutterLocalNotificationsPlugin.schedule(n.id, title + " jest Wydarzenie:", event.name, event.beginTime.subtract(n.duration), platformChannelSpecifics);
    }
  }


  /// Deleting all Notification associated with this 'Task' by id from Data Base and canceled from showing on device.
  static Future<void> deleteTask(int id) async {
    List<Notifi> notifi = await NotifiHelper.listsTaskID(id);
    notifi.forEach((n) => _flutterLocalNotificationsPlugin.cancel(n.id));
    NotifiHelper.deleteTaskID(id);
  }

  /// Deleting all Notification associated with this 'Event' by id from Data Base and canceled from showing on device.
  static Future<void> deleteEvent(int id) async {
    List<Notifi> notifi = await NotifiHelper.listsEventID(id);
     notifi.forEach((n) => _flutterLocalNotificationsPlugin.cancel(n.id));
     NotifiHelper.deleteEventID(id);
  }
  /// Canceled notification by "id' notification
  static  Future<void> deleteNotifi(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Canceled list of notification by 'id' using 'Notifi' class notification
  static  Future<void> deleteListNotifi(List<Notifi> list) async {
    list.forEach((n) => _flutterLocalNotificationsPlugin.cancel(n.id));
  }

}

