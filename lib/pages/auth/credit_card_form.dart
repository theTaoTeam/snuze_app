import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class CreditCardForm extends StatelessWidget {
  final Function onCardChange;

  CreditCardForm({this.onCardChange});

  Widget _buildCCNumberField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'XXXXXXXXXXXXXXXX',
        labelStyle: new TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(255, 255, 255, 0.2),
        border: InputBorder.none,
      ),
      style: new TextStyle(height: .3),
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
    return Container(
        width: 52,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'MM',
            labelStyle: new TextStyle(color: Colors.white),
            filled: true,
            fillColor: Color.fromRGBO(255, 255, 255, 0.2),
            border: InputBorder.none,
          ),
          style: new TextStyle(height: .3),
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
        ));
  }

  Widget _buildExpYearField() {
    return Container(
        width: 66,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'YYYY',
            labelStyle: new TextStyle(color: Colors.white),
            filled: true,
            fillColor: Color.fromRGBO(255, 255, 255, 0.2),
            border: InputBorder.none,
          ),
          style: new TextStyle(
            height: .3,
          ),
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
        ));
  }

  Widget _buildCvcField() {
    return Container(
        width: 113,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'CVC',
            labelStyle: new TextStyle(color: Colors.white),
            filled: true,
            fillColor: Color.fromRGBO(255, 255, 255, 0.2),
            border: InputBorder.none,
          ),
          style: new TextStyle(height: .3),
          keyboardType: TextInputType.number,
          validator: (String value) {
            if (value.isEmpty || value.length != 3) {
              return 'please enter a valid cvc';
            }
          },
          onSaved: (String value) {
            onCardChange(<String, String>{'cvc': value});
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildCCNumberField(),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                _buildExpMonthField(),
                _buildExpYearField(),
              ],
            ),
            _buildCvcField(),
          ],
        ),
      ],
    );
  }
}
