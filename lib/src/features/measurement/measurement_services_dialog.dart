import 'dart:developer';

import 'package:constata_0_0_2/src/features/measurement/measurement_form_dialog.dart';
import 'package:constata_0_0_2/src/models/measurement_object.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MeasureServiceDialog extends StatefulWidget {
  MeasureServiceDialog(
      {Key key, this.dataLogged, this.tasksAndCosts, this.colaborator})
      : super(key: key);
  Map dataLogged;
  var tasksAndCosts;
  Map colaborator;
  @override
  _MeasureServiceDialog createState() => _MeasureServiceDialog();
}

class _MeasureServiceDialog extends State<MeasureServiceDialog> {
  MeasurementObject object = MeasurementObject();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.tasksAndCosts);
    print(widget.tasksAndCosts.length);
    print('ola mariilene');
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: widget.tasksAndCosts.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () async {
                      Map response = {};
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(content: MeasureFormDialog());
                          }).then((value) => {response = value});
                      if (response != null) {
                        object.namePessoa = widget.colaborator['name'];
                        object.pessoaId = widget.colaborator['id'];
                        object.localName =
                            widget.tasksAndCosts[index]['tp_cp081']['name'];
                        object.localId =
                            widget.tasksAndCosts[index]['tp_cp081']['_id'];
                        object.serviceId =
                            widget.tasksAndCosts[index]['tp_cp083']['_id'];
                        object.serviceName =
                            widget.tasksAndCosts[index]['tp_cp083']['name'];
                        object.typeServiceId =
                            widget.tasksAndCosts[index]['tp_cp082']['_id'];
                        object.typeServiceName =
                            widget.tasksAndCosts[index]['tp_cp082']['name'];
                        object.unidadeId =
                            widget.tasksAndCosts[index]["tp_cp085"]["_id"];
                        object.unidadeName =
                            widget.tasksAndCosts[index]["tp_cp085"]["name"];
                        object.rg = widget.colaborator["rg"];
                        object.qte_consumida = response['qte_consumida'];
                        object.valor_unitario = response['valor_unitario'];
                        object.total = double.parse(double.parse(
                                (response['qte_consumida'] *
                                        response['valor_unitario'])
                                    .toString())
                            .toStringAsFixed(2));
                        Navigator.pop(context, object);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: ListTile(
                      title: Text(
                          '${widget.tasksAndCosts[index]['tp_cp081']['name']} | ${widget.tasksAndCosts[index]['tp_cp082']['name']} | ${widget.tasksAndCosts[index]['tp_cp083']['name']}'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
