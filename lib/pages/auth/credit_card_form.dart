import 'package:flutter/material.dart';
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
        errorStyle: TextStyle(color: Colors.white),
      ),
      style: new TextStyle(height: .3, fontFamily: 'Montserrat'),
      keyboardType: TextInputType.number,
      validator: (String value) {
        if (value.isEmpty || value.trim().length != 16) {
          return 'invalid credit card number';
        }
      },
      onSaved: (String value) {
        onCardChange(<String, String>{'number': value.trim()});
      },
    );
  }

  Widget _buildExpMonthField() {
    return Container(
        width: 70,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'MM',
            labelStyle: new TextStyle(color: Colors.white),
            filled: true,
            fillColor: Color.fromRGBO(255, 255, 255, 0.2),
            errorStyle: TextStyle(color: Colors.white),
          ),
          style: new TextStyle(height: .3, fontFamily: 'Montserrat'),
          keyboardType: TextInputType.number,
          validator: (String value) {
            if (value.isEmpty || !RegExp(r"^(0[1-9]|1[012])$")
                .hasMatch(value.trim())) {
              return 'invalid';
            }
          },
          onSaved: (String value) {
            value.trim();
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
            errorStyle: TextStyle(color: Colors.white),
          ),
          style: new TextStyle(height: .3, fontFamily: 'Montserrat'),
          keyboardType: TextInputType.number,
          validator: (String value) {
            if (value.isEmpty || value.trim().length != 4) {
              return 'invalid';
            }
          },
          onSaved: (String value) {
            var val = int.tryParse(value.trim());
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
            errorStyle: TextStyle(color: Colors.white),
          ),
          style: new TextStyle(height: .3, fontFamily: 'Montserrat'),
          keyboardType: TextInputType.number,
          validator: (String value) {
            if (value.isEmpty || value.trim().length != 3) {
              return 'invalid';
            }
          },
          onSaved: (String value) {
            onCardChange(<String, String>{'cvc': value.trim()});
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
