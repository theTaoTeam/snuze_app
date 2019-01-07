import 'package:flutter/material.dart';

import 'package:snuze/pages/sounds/sounds_list.dart';

class SoundsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'sounds',
            style:
                TextStyle(fontSize: 23, color: Theme.of(context).dividerColor),
          ),
        ),
        body: SoundsList(),
      );
  }
}
