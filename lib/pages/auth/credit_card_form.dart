import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CreditCardFrom extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreditCardFormState();
  }
}

class _CreditCardFormState extends State<CreditCardFrom> {
  final Map<String, dynamic> _creditCardInfo = {
    'cardNumber': '',
    'expMonth': null,
    'expYear': null,
    'cvc': '',
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildCCNumberField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'xxxxxxxxxxxxxxxx', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[^([0-9]{4}]").hasMatch(value) ||
            value.length != 16) {
          return 'please enter a valid credit card number';
        }
      },
      onSaved: (String value) {
        _creditCardInfo['cardNumber'] = value;
      },
    );
  }

  Widget _buildExpMonthField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'xx/xx', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[^([0-9]{4}]").hasMatch(value) ||
            value.length != 16) {
          return 'please enter a valid credit card number';
        }
      },
      onSaved: (String value) {
        _creditCardInfo['cardNumber'] = value;
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _buildCCNumberField(),
        ],
      ),
    );
  }
}
