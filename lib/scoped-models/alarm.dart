import 'package:scoped_model/scoped_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:snuze/models/alarm.dart';

class AlarmModel extends Model {
  Alarm _alarm;

  Alarm get alarm => _alarm;

  void updateAlarm(Map<String, dynamic> alarmData) {
    // prevent error when _alarm is null on initial startup
    var jsonAlarm = _alarm != null ? _alarm.toJson() : this.defaultAlarm().toJson();

    alarmData.forEach((key, value) => jsonAlarm[key] = value);
    print('THIS IS THE NEW ALARM');
    print(jsonAlarm);
    _alarm = new Alarm.fromJson(jsonAlarm);
    notifyListeners();
  }

  Alarm defaultAlarm() {
    return new Alarm(
      hour: 7,
      minute: 30,
      meridiem: 0,
      isActive: false,
      snuzeAmount: 0.25
    );
  }

  void fetchAlarm() {

  }
}