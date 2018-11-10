// import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snuze/scoped-models/connected_user_alarm.dart';
import 'package:snuze/models/alarm.dart';

mixin AlarmModel on ConnectedUserAlarmModel {
  Alarm _alarm;

  Alarm get alarm => _alarm;

  void updateAlarm(Map<String, dynamic> alarmData) {
    SharedPreferences.getInstance().then((prefs) {
      final Map<String, Function> typeMap = {
        "int": prefs.setInt,
        "bool": prefs.setBool,
        "double": prefs.setDouble
      };

      // prevents null error on startup
      if(_alarm == null) {
        _alarm = new Alarm.fromJson(alarmData);
      }

      var jsonAlarm = _alarm.toJson();

      alarmData.forEach((key, value) {
        jsonAlarm[key] = value;
        typeMap[_alarmMap[key]](key, value);
      });

      _alarm = new Alarm.fromJson(jsonAlarm);
      print(_alarm.toJson());
      notifyListeners();
    });
  }

  void defaultAlarm() {
    final Alarm initialAlarm = new Alarm();
    updateAlarm(initialAlarm.toJson());
  }

  void fetchAlarm() {
    SharedPreferences.getInstance().then((prefs) {
      final Map<String, Function> typeMap = {
        "int": prefs.getInt,
        "bool": prefs.getBool,
        "double": prefs.getDouble
      };

      print(prefs.getInt('hour'));
      print('THIS IS THE HOUR FROM PREFS');

      bool setDefault = false;
      // update alarm for all prefs stored in shared pref
      // will only work with single-alarm implementation
      Map<String, dynamic> fetchedAlarm = {};
      _alarmMap.forEach((key, type) {
        fetchedAlarm[key] = typeMap[type](key);
        if(fetchedAlarm[key] == null) {
          setDefault = true;
        }
      });

      if(setDefault == true) {
        print('DID NOT FETCH ALARM');
        this.defaultAlarm();
      } else {
        print('FETCHED ALARM');
        print(fetchedAlarm);
        this.updateAlarm(fetchedAlarm);
      }
    });
  }

  // Map<String,dynamic> convertPref(String key, dynamic value) {
  //   return <String, dynamic>{key: value};
  // }

  Map<String, String> _alarmMap = {
    "hour": "int",
    "minute": "int",
    "meridiem": "int",
    "isActive": "bool",
    "snuzeAmount": "double"
  };

}