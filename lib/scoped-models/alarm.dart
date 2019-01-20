import 'dart:async';
import 'package:scoped_model/scoped_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:snuze/models/alarm.dart';
import 'package:snuze/helpers/alarm_settings.dart';

mixin AlarmModel on Model {
  Alarm _alarm;

  static final _alarmChannel = MethodChannel('snuze.app/alarm');

  Alarm get alarm => _alarm;

  // // send alarm message to iOS devices
  // Future<Null> _setNativeAlarm() async {
  //   var jsonArgs = json.encode(<String, dynamic> {
  //     'hour': this._militaryHour(hour: _alarm.hour, meridiem: _alarm.meridiem),
  //     'minute': _alarm.minute
  //   });

  //   try {
  //     final String result = await _alarmChannel.invokeMethod('setAlarm', jsonArgs);
  //     print(result);
  //   } catch (err) {
  //     print(err);
  //   }
  // }
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  int _militaryHour() {
    int convertedHour;
    if(alarm.meridiem == 0) {
      convertedHour = alarm.hour != 11 ? alarm.hour + 1 : 0;
    } else {
      convertedHour = alarm.hour != 11 ? alarm.hour + 1 + 12 : 12;
    }
    return convertedHour;
  }

  // Future<Null> _cancelNativeAlarm() async {
  //   try {
  //     final String result = await _alarmChannel.invokeMethod('cancelAlarm', "test");
  //   } catch(err) {
  //     print(err);
  //   }
  // }

  void updateAlarm(Map<String, dynamic> alarmData) {
    SharedPreferences.getInstance().then((prefs) {
      final Map<String, Function> typeMap = {
        "int": prefs.setInt,
        "bool": prefs.setBool,
        "double": prefs.setDouble,
        "String": prefs.setString,
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

  Future<void> setAlarm() async { 
    DateTime alarmDate = new DateTime(2019, 1, 1, _militaryHour(), _alarm.minute).toUtc();
    String hour = alarmDate.hour.toString().padLeft(2, "0");
    String minute = alarmDate.minute.toString().padLeft(2, "0");
    String topic = '$hour$minute';
    this.updateAlarm({
      'isActive': true,
      'subscriptionTopic': topic,
    });
    _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> cancelAlarm() async {
    this.updateAlarm({
      'isActive': false,
      'subscriptionTopic': '',
    });
    _firebaseMessaging.unsubscribeFromTopic(_alarm.subscriptionTopic);
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
        "double": prefs.getDouble,
        "String": prefs.getString,
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
    "snuzeAmount": "double",
    "sound": "String",
    "isTriggered": "bool",
    "subscriptionTopic": "String",
  };

  String alarmTimeToString() {
    int hour = _alarm.hour != 11 ? _alarm.hour + 1 : 12;
    return "$hour:${_alarm.minute < 10 ? '0'+_alarm.minute.toString() : _alarm.minute} ${_alarm.meridiem == 0 ? 'AM' : 'PM'}";
  }

  String snuzeAmountToString() {
    double price = toPrice(_alarm.snuzeAmount);
    return "\$${price.toStringAsFixed(2)}";
  }

}