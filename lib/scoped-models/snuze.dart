import 'dart:async';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';
import 'package:snuze/models/snuze.dart';

mixin SnuzeModel on Model {
  final Firestore _firestore = Firestore.instance;
}