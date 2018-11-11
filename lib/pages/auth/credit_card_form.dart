import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CreditCardForm extends StatelessWidget {
  final Function onCardChange;

  CreditCardForm({this.onCardChange});

  Widget _buildCCNumberField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'XXXXXXXXXXXXXXXX', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.number,
      validator: (String value) {
        if (value.isEmpty || value.length != 16) {
          return 'please enter a valid credit card number';
        }
      },
      onSaved: (String value) {
        onCardChange(<String, String>{'number': value});
      },
    );
  }

  Widget _buildExpMonthField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'MM', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.number,
      validator: (String value) {
        if (value.isEmpty || value.length != 2) {
          return 'please enter a valid exp month';
        }
      },
      onSaved: (String value) {
        var val = int.tryParse(value);
        if (val == null) {
          print('Error parsing expMonth');
        }
        onCardChange(<String, int>{'expMonth': val});
      },
    );
  }

  Widget _buildExpYearField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'YYYY', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.number,
      validator: (String value) {
        if (value.isEmpty || value.length != 4) {
          return 'please enter a valid exp year';
        }
      },
      onSaved: (String value) {
        var val = int.tryParse(value);
        if (val == null) {
          print('Error parsing expMonth');
        }
        onCardChange(<String, int>{'expYear': val});
      },
    );
  }

  Widget _buildCvcField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'CVC', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.number,
      validator: (String value) {
        if (value.isEmpty || value.length != 3) {
          return 'please enter a valid cvc';
        }
      },
      onSaved: (String value) {
        onCardChange(<String, String>{'cvc': value});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildCCNumberField(),
        SizedBox(height: 10.0),
        _buildExpMonthField(),
        SizedBox(height: 10.0),
        _buildExpYearField(),
        SizedBox(height: 10.0),
        _buildCvcField(),
      ],
    );
  }
}
