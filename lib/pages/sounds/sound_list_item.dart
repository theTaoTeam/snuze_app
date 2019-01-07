import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:snuze/scoped-models/main.dart';
import 'package:snuze/models/sound.dart';

class SoundListItem extends StatelessWidget {
  final Sound sound;

  SoundListItem({this.sound});

  _selectSound(sound, Function updateAlarm) {
    print("selecting sound and upating alarm");
    updateAlarm(<String, String>{"sound": sound});
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
          title: Text(sound.displayName),
          trailing: model.alarm.sound == sound.fileName
              ? Icon(
                  Icons.check,
                  color: Colors.red,
                )
              : Text(''),
          onTap: () {
            print("$sound tapped");
            _selectSound(sound.fileName, model.updateAlarm);
          });
    });
  }
}
