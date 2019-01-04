import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:snuze/scoped-models/main.dart';
import 'package:snuze/pages/sounds/sounds_list.dart';

class SoundsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> sounds = [
      'ring',
      'beep',
      'buzz'
    ];
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'sounds',
            style:
                TextStyle(fontSize: 23, color: Theme.of(context).dividerColor),
          ),
        ),
        body: SoundsList(sounds: sounds),
      );
    });
  }
}
