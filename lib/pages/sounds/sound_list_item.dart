import 'package:flutter/material.dart';

class SoundListItem extends StatelessWidget {
  final String sound;

  SoundListItem({this.sound});
  @override
  Widget build(BuildContext context) {
    print("sound:" + sound);
    return ListTile(
      title: Text(sound),
      // trailing:  Icon(Icons.check, color: Colors.red,),
      onTap: () {
        print("$sound tapped");
      },
    );
  }
}
