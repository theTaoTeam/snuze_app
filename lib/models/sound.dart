import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Sound {
  String displayName;
  String fileName;


  Sound({this.displayName = "ring", this.fileName});

  factory Sound.fromJson(Map<String, dynamic> json) => _$SoundFromJson(json);

  Map<String, dynamic> toJson() => _$SoundToJson(this);
}
