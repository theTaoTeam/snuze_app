import 'package:scoped_model/scoped_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:snuze/models/alarm.dart';

class AlarmModel extends Model {
  Alarm _alarm = new Alarm(hour: 7, minute: 30, snuzeAmount: 0.25, isActive: false);

  Alarm get alarm => _alarm;

  void updateAlarm(Map<String, dynamic> alarmData) {
    var jsonAlarm = _alarm.toJson();

    alarmData.forEach((key, value) => jsonAlarm[key] = value);
    print(jsonAlarm);
    _alarm = new Alarm.fromJson(jsonAlarm);
  }
}