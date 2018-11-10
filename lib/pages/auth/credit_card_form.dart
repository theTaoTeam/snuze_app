import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';

class CreditCardFrom extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreditCardFormState();
  }
}

class _CreditCardFormState extends State<CreditCardFrom> {
  void _addSource(String token) {
    print(token);
  }

  @override
  void initState() {
    StripeSource.setPublishableKey("pk_test");
    StripeSource.addSource().then((String token) {
      _addSource(token);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Stripe Setup');
  }
}
