class Event {
  int id;
  String name;
  DateTime beginTime;
  DateTime endTime;
  String cycle;
  String color;
  String description;


  List<Notifi> listNotifi;

  Event({
    this.id,
    this.name,
    this.beginTime,
    this.endTime,
    this.cycle,
    this.color,
    this.description,
    this.listNotifi,
  }){
    listNotifi = List();
  }


}


class Group {
  int id;
  String name;
  int howMuchDone;
  bool isSelected;

  Group({
    this.id,
    this.name,
    this.howMuchDone,
    this.isSelected = false,
  });

}
class Localization {
  int id;
  double latitude;
  double longitude;
  String name;
  String city;
  String street;
  bool isNearBy;
  bool wasNotified;
  bool isSelected ;

  Localization(
      {
        this.id,
        this.latitude,
        this.longitude,
        this.name,
        this.city,
        this.street,
        this.isNearBy,
        this.wasNotified,
        this.isSelected = false
      });
}
class Notifi{
  int id;
  int idTask;
  int idEvent;
  Duration duration;

  Notifi({
    this.id,
    this.idTask,
    this.idEvent,
    this.duration,
  }){
    idTask =-1;
    idEvent=-1;
  }



}
class Task {
  int id;
  String name;
  bool done;
  DateTime endTime;
  String description;
  Localization localization;
  Group group;

  List<Notifi> listNotifi;

  Task({
    this.id,
    this.name,
    this.done,
    this.endTime,
    this.description,
    this.localization,
    this.group,
    this.listNotifi,
  }){
    listNotifi = List();
  }

}
