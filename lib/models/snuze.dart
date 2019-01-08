import 'package:json_annotation/json_annotation.dart';

part 'snuze.g.dart';

@JsonSerializable()
class Snuze {
  DateTime snuzeTime;
  double snuzeAmount;
  String id;

  Snuze({this.snuzeTime, this.snuzeAmount, this.id});

  factory Snuze.fromJson(Map<String, dynamic> json) => _$SnuzeFromJson(json);

  Map<String, dynamic> toJson() => _$SnuzeToJson(this);
}
