import 'package:json_annotation/json_annotation.dart';

part 'alarm.g.dart';

@JsonSerializable()
class Alarm {
  int hour;
  int minute;
  int meridiem;
  double snuzeAmount;
  bool isActive;


  Alarm({this.hour = 6, this.minute = 6, this.meridiem = 0, this.snuzeAmount = 0.25, this.isActive = false});

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);

  Map<String, dynamic> toJson() => _$AlarmToJson(this);
}
