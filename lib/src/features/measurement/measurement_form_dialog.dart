import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

class MeasureFormDialog extends StatefulWidget {
  MeasureFormDialog(
      {Key key, this.dataLogged, this.tasksAndCosts, this.colaborator})
      : super(key: key);
  Map dataLogged;
  var tasksAndCosts;
  Map colaborator;
  @override
  _MeasureFormDialog createState() => _MeasureFormDialog();
}

class _MeasureFormDialog extends State<MeasureFormDialog> {
  double valor_unitario;
  int qte_consumida;
  final _controller = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$');
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: SafeArea(
      child: Column(
        children: [
          TextFormField(
            decoration: new InputDecoration(hintText: 'valor unitario'),
            maxLength: 40,
            controller: _controller,
            onChanged: (value) {
              valor_unitario = _controller.numberValue;
            },
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            decoration: new InputDecoration(hintText: 'quantidade'),
            maxLength: 40,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              qte_consumida = int.parse(value);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Voltar')),
              ElevatedButton(
                  onPressed: () {
                    Map object = {
                      "valor_unitario": valor_unitario,
                      "qte_consumida": qte_consumida,
                    };
                    Navigator.pop(context, object);
                  },
                  child: Text('Salvar')),
            ],
          )
        ],
      ),
    ));
  }
}
