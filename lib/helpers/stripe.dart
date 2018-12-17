import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:snuze/helpers/exceptions.dart';

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
    print('THIS IS THE TOKEN!!!!');
    print(token);
    return token;
  } catch(err) {
    print(err);
    throw new CausedException(cause: "Stripe", code:'7', message: "Error creating stripe token", userMessage: "Looks like your credit card information is invalid, please double-check your card and retry.");
  }
}