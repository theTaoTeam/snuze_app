import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './alarm_manager.dart';

class HomePage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Snüze',
        ),
        centerTitle: true,
      ),
      body: AlarmManager(),
    );
  }
}
