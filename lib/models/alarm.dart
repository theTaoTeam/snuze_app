import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'alarm.g.dart';

@JsonSerializable()
class Alarm {
  num hour;
  num minute;
  double snuzeAmount;
  bool isActive;

  Alarm({@required this.hour, @required this.minute, @required this.snuzeAmount, @required this.isActive});

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);

  Map<String, dynamic> toJson() => _$AlarmToJson(this);
}
