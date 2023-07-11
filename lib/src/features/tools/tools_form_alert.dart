import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class ToolsFormAlert extends StatefulWidget {
  var tool;
  ToolsFormAlert({Key? key, this.tool}) : super(key: key);

  @override
  _ToolsFormAlertState createState() => _ToolsFormAlertState();
}

class _ToolsFormAlertState extends State<ToolsFormAlert> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller1 = TextEditingController();
  double disponivel = 0;
  double saldo = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saldo = double.parse(widget.tool["tp_cp044"].toString());
    disponivel = double.parse(widget.tool["tp_cp041"].toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Center(
                  child: Text(widget.tool['tp_cp039']['name'].toString())),
              subtitle: Center(
                  child: Text(widget.tool['tp_cp040']['name'].toString())),
            ),
            Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: controller,
                      validator: (value) {
                        if (controller.text.isNotEmpty &&
                            double.tryParse(controller.text)! > disponivel) {
                          controller.clear();
                          return "Valor inválido!";
                        } else if (controller.text.isNotEmpty) {
                          saldo = widget.tool["tp_cp041"] +
                              double.tryParse(controller.text);
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          icon: Icon(Icons.arrow_back),
                          labelText: 'Entrada de ferramentas'),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: controller1,
                      validator: (value) {
                        if (controller1.text.isNotEmpty &&
                            double.tryParse(controller1.text)! > saldo) {
                          controller1.clear();
                          return "Valor inválido!";
                        }
                        print(saldo);
                        return null;
                      },
                      decoration: const InputDecoration(
                          icon: Icon(Icons.arrow_forward),
                          labelText: 'Saída de ferramentas'),
                    ),
                  ],
                )),
            ElevatedButton(
                onPressed: () {
                  if (controller1.text.isEmpty) {
                    controller1.text = '0';
                  }
                  if (controller.text.isEmpty) {
                    controller.text = '0';
                  }
                  Navigator.pop(context, {
                    'tp_cp110': controller.text,
                    'tp_cp111': controller1.text,
                    'tp_cp108': {
                      "name": widget.tool['tp_cp039']['name'],
                      "_id": widget.tool['tp_cp039']['_id']
                    },
                    'tp_cp109': {
                      "name": widget.tool['tp_cp040']['name'],
                      "_id": widget.tool['tp_cp040']['_id']
                    },
                    "_id": const Uuid().v4()
                  });
                },
                child: const Text('Salvar'))
          ],
        ),
      ),
    );
  }
}
