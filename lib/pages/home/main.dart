import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import './alarm_manager.dart';
import 'package:snuze/scoped-models/main.dart';

class MainPage extends StatelessWidget {
  final MainModel model;

  MainPage(this.model);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'snüze', style: TextStyle(color: Theme.of(context).highlightColor),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.settings),
            highlightColor: Colors.transparent,
            textColor: Theme.of(context).highlightColor,
            color: Theme.of(context).backgroundColor,
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
