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

  Future<void> createSnuze({double snuzeAmount}) async {
    try {
      FirebaseUser currentUser = await _auth.currentUser();
      DocumentReference userRef = _firestore.collection('users').document(currentUser.uid);
      DocumentSnapshot userDoc = await userRef.get();
      DocumentReference invoiceRef = _firestore.collection('invoices').document(userDoc.data['activeInvoice']);
      DocumentReference snuzeRef = _firestore.collection('snuzes').document();
      Map<String, dynamic> snuzeData = {
        'snuzeTime': Timestamp.now(),
        'id': snuzeRef.documentID,
        'snuzeAmount': snuzeAmount,
        'userId': currentUser.uid,
        'invoiceId': invoiceRef.documentID,
      };
      WriteBatch batch = _firestore.batch();
      batch.setData(snuzeRef, snuzeData);
      batch.updateData(invoiceRef, <String, dynamic>{
        'snuzeIds': FieldValue.arrayUnion([snuzeRef.documentID]),
      });
      await batch.commit();
    } catch(e) {
      print('ERROR CREATING SNUZE');
      print(e.toString());
    }
  }
}