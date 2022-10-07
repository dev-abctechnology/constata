import 'dart:convert';

import 'package:constata_0_0_2/src/features/measurement/controllers/measurement_jarvis.dart';

import 'package:constata_0_0_2/src/features/measurement/model/measurement_object_r.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/seletor_model.dart';
import 'model/measurement_model.dart';

class MeasurementReportReworked extends StatefulWidget {
  final dataLogged;

  final date;

  const MeasurementReportReworked({Key key, this.dataLogged, this.date})
      : super(key: key);

  @override
  State<MeasurementReportReworked> createState() =>
      _MeasurementReportReworkedState();
}

class _MeasurementReportReworkedState extends State<MeasurementReportReworked> {
  MeasurementJarvis measurementJarvis = MeasurementJarvis();
  List colaborators = [];

  void initialize() async {
    try {
      print(widget.date);
      String obra = widget.dataLogged['obra']['data']['tb01_cp002'];
      colaborators = await measurementJarvis.fetchColaborators(
          buildName: obra, context: context, date: '07/10/2022');
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString().substring(11));
      SharedPreferences.getInstance().then((value) {
        if (value.containsKey('colaboradores')) {
          colaborators = jsonDecode(value.getString('colaboradores'));
          // print(colaboradores);
          colaborators = colaborators
              .where((element) =>
                  element['data']['tb01_cp123'][0]['tp_cp132'] == "Sim")
              .toList();
          setState(() {});
        }
      });
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message),
    ));
  }

  MeasurementModel addMeasurement(
      {colaborator, offlineData, quantity, unitValue, observation}) {
    return MeasurementModel(
      codePerson: colaborator['tb01_cp004'],
      local: Seletor(name: offlineData['local'], sId: offlineData['id']),
      measurementUnit: Seletor(name: offlineData['um'], sId: offlineData['id']),
      quantity: quantity,
      namePerson: colaborator['tb01_cp002'],
      observation: observation,
      sector: Seletor(name: offlineData['setor'], sId: offlineData['id']),
      service: Seletor(name: offlineData['servico'], sId: offlineData['id']),
      totalValue: quantity * unitValue,
      unitValue: unitValue,
    );
  }

  button() {
    measurementBody.measurements.add(addMeasurement(
        colaborator: colaborators[0],
        offlineData: widget.dataLogged,
        quantity: 1,
        unitValue: 1,
        observation: 'Trabalhou pakas'));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  MeasurementBody measurementBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Medição'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
                shrinkWrap: true,
                itemCount: colaborators == null ? 0 : colaborators.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        colaborators[index]['data']['tb01_cp002'].toString()),
                  );
                }),
            ElevatedButton(
                onPressed: () async {
                  try {
                    await measurementJarvis
                        .sendMeasurement(
                            MeasurementAppointment(data: measurementBody),
                            context)
                        .then((value) => print(value));
                  } catch (e) {
                    showSnackBar(e.toString().substring(11));
                  }
                },
                child: const Text('Enviar'))
          ],
        ),
      ),
    );
  }
}
