import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const MethodChannel _stripeChannel = MethodChannel('snuze.app/stripe');

Future<String> requestStripeToken(Map<String, dynamic> cardInfo) async {
  var jsonArgs = json.encode(<String, dynamic> {
    'number': cardInfo['number'],
    'expMonth': cardInfo['expMonth'],
    'expYear': cardInfo['expYear'],
    'cvc': cardInfo['cvc']
  });

  try {
    final String token = await _stripeChannel.invokeMethod('createStripeToken', jsonArgs);
    print('THIS IS THE TOKEN BIIIIIITCH');
    print(token);
    return token;
  } catch(err) {
    print(err);
    return "ERROR";
  }
}
