import 'package:json_annotation/json_annotation.dart';

part 'snuze.g.dart';

@JsonSerializable()
class Snuze {
  DateTime alarmTime;
  double snuzeAmount;

  Snuze({this.alarmTime, this.snuzeAmount = 0.25});

  factory Snuze.fromJson(Map<String, dynamic> json) => _$SnuzeFromJson(json);

  Map<String, dynamic> toJson() => _$SnuzeToJson(this);
}
