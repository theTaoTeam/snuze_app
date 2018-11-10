import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snuze/models/alarm.dart';

class AlarmModel extends Model {
  Alarm _alarm;

  Alarm get alarm => _alarm;

  void updateAlarm(Map<String, dynamic> alarmData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, Function> typeMap = {
      "int": prefs.setInt,
      "bool": prefs.setBool,
      "double": prefs.setDouble
    };

    var jsonAlarm = _alarm.toJson();

    alarmData.forEach((key, value) {
      jsonAlarm[key] = value;
      typeMap[_alarmMap[key]](key, value);
    });

    _alarm = new Alarm.fromJson(jsonAlarm);
    print(_alarm.toJson());
    notifyListeners();
  }

  void defaultAlarm() {
    final Alarm initialAlarm = new Alarm();
    _alarm = initialAlarm;
    updateAlarm(_alarm.toJson());
  }

  void fetchAlarm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    final Map<String, Function> typeMap = {
      "int": prefs.getInt,
      "bool": prefs.getBool,
      "double": prefs.getDouble
    };

    // update alarm for all prefs stored in shared prefs
    // will only work with single-alarm implementation
    _alarmMap.forEach((key, type) {
      this.updateAlarm(convertPref(key, typeMap[type](key)));
    });
  }

  Map<String,dynamic> convertPref(String key, dynamic value) {
    return <String, dynamic>{key: value};
  }

  Map<String, String> _alarmMap = {
    "hour": "int",
    "minute": "int",
    "meridiem": "int",
    "isActive": "bool",
    "snuzeAmount": "double"
  };

}