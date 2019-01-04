import 'package:flutter/material.dart';

import 'package:snuze/pages/sounds/sound_list_item.dart';

class SoundsList extends StatelessWidget {
  final List<String> sounds;

  SoundsList({this.sounds});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              SoundListItem(sound: sounds[index]),
              Divider(),
            ],
          );
        });
  }
}
