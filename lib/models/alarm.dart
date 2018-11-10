import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'alarm.g.dart';

@JsonSerializable()
class Alarm {
  int hour;
  int minute;
  int meridiem;
  double snuzeAmount;
  bool isActive;


  Alarm({@required this.hour, @required this.minute, @required this.meridiem, @required this.snuzeAmount, @required this.isActive});

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);

  Map<String, dynamic> toJson() => _$AlarmToJson(this);
}
