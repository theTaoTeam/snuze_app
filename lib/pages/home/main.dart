import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import './alarm_manager.dart';
import '../../scoped-models/main.dart';

class MainPage extends StatelessWidget {
  final MainModel model;

  MainPage(this.model);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Snüze',
        ),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.settings),
            textColor: Theme.of(context).highlightColor,
            onPressed: () {
              model.getUserTheme(model.user.darkTheme);
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
        centerTitle: true,
      ),
      body: AlarmManager(),
    );
  }
}
