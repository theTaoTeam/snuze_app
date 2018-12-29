import 'dart:async';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/services.dart';
import 'package:snuze/models/snuze.dart';

mixin SnuzeModel on Model {
  final Firestore _firestore = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createSnuze({snuze}) async {
    FirebaseUser currentUser = await _auth.currentUser();
    final DocumentReference userRef = _firestore.collection('users').document(currentUser.uid);
    _firestore.runTransaction((Transaction tx) async {
      DocumentSnapshot userSnapshot = await tx.get(userRef);
      print(userSnapshot);
    });
  }
}