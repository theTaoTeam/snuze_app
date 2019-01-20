// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alarm _$AlarmFromJson(Map<String, dynamic> json) {
  return Alarm(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      meridiem: json['meridiem'] as int,
      snuzeAmount: (json['snuzeAmount'] as num)?.toDouble(),
      isActive: json['isActive'] as bool,
      sound: json['sound'] as String,
      isTriggered: json['isTriggered'] as bool)
    ..subscriptionTopic = json['subscriptionTopic'] as String;
}

Map<String, dynamic> _$AlarmToJson(Alarm instance) => <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
      'meridiem': instance.meridiem,
      'snuzeAmount': instance.snuzeAmount,
      'isActive': instance.isActive,
      'isTriggered': instance.isTriggered,
      'sound': instance.sound,
      'subscriptionTopic': instance.subscriptionTopic
    };
