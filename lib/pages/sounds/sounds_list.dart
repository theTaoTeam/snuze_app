import 'package:flutter/material.dart';

import 'package:snuze/pages/sounds/sound_list_item.dart';
import 'package:snuze/helpers/sounds.dart';

class SoundsList extends StatelessWidget {

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
