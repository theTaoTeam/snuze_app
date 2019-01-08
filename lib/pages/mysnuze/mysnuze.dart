import 'package:flutter/material.dart';

class MySnuzePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'my snüze',
          style: TextStyle(fontSize: 23, color: Theme.of(context).dividerColor),
        ),
      ),
      body: Center(
        child: Text('my snuze page'),
      ),
    );
  }
}
