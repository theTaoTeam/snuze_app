import 'package:flutter/material.dart';

class HomeNav extends StatelessWidget {
  final double targetWidth;

  HomeNav({this.targetWidth});

  @override
    Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ButtonTheme(
              minWidth: targetWidth,
              child: RaisedButton(
                color: Colors.white,
                child: Text('Sound'),
                onPressed: () {
                  print('Sound button pressed');
                },
              ),
            ),
            ButtonTheme(
              minWidth: targetWidth,
              child: RaisedButton(
                color: Colors.white,
                child: Text('My Snüze'),
                onPressed: () {
                  print('My Snüze button pressed');
                },
              ),
            ),
          ],
        ),
      ),
    );
    }
}