import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Text> numberTextList({num start = 1, num end = 12, num inc = 1}) {
  List<Text> numberList = [];
  for(var i = start; i <= end; i += inc) {
    numberList.add(numberTextWidget(i));
  }
  return numberList;
}

Widget numberTextWidget(num number) {
  String numberString = uniformString(number);
  return Text(numberString);
}

String uniformString(num number) {
  return number < 10 ? "0" + number.toString() : number.toString();
}