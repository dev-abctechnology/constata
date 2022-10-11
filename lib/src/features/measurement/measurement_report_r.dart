import 'dart:convert';
import 'dart:developer' as developer;
import 'package:constata_0_0_2/src/features/measurement/controllers/measurement_jarvis.dart';

import 'package:constata_0_0_2/src/features/measurement/model/measurement_object_r.dart';
import 'package:constata_0_0_2/src/models/build_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/currency_input.dart';
import '../../shared/seletor_model.dart';
import 'data/measurement_data.dart';
import 'model/measurement_model.dart';

class MeasurementReportReworked extends StatefulWidget {
  final dataLogged;

  final date;

  final bool edittingMode;

  const MeasurementReportReworked(
      {Key key, this.dataLogged, this.date, this.edittingMode = false})
      : super(key: key);

  @override
  State<MeasurementReportReworked> createState() =>
      _MeasurementReportReworkedState();
}

class _MeasurementReportReworkedState extends State<MeasurementReportReworked> {
  MeasurementJarvis measurementJarvis = MeasurementJarvis();
  List colaborators = [];
  Build storedBuild;
  void initialize() async {
    try {
      try {
        storedBuild = Build.fromJson(widget.dataLogged['obra']['data']);
        for (Task task in storedBuild.tasks) {
          print(task.local.name +
              ' | ' +
              task.sector.name +
              ' | ' +
              task.service.name);
          print(task.budgetedQuantity);
          print('-----------------------');
        }
      } catch (e, s) {
        print(e);
        print(s);
      }

      var dateParsed = DateTime.parse(widget.date);
      DateFormat dateFormat = DateFormat("dd/MM/yyyy");
      var date = dateFormat.format(dateParsed);
      String obra = widget.dataLogged['obra']['data']['tb01_cp002'];
      colaborators = await measurementJarvis.fetchColaborators(
          buildName: obra, context: context, date: date);
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString().substring(11), Colors.red);
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

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(message),
    ));
  }

  void addMeasurement(
      {colaborator,
      Task task,
      double quantity,
      double unitValue,
      String observation = ''}) {
    try {
      measurementBody.measurements.add(MeasurementModel(
        codePerson: colaborator['data']['tb01_cp004'],
        namePerson: colaborator['data']['tb01_cp002'],
        measurementUnit:
            Seletor(name: task.measureUnit.name, sId: task.measureUnit.sId),
        local: Seletor(name: task.local.name, sId: task.local.sId),
        sector: Seletor(name: task.sector.name, sId: task.sector.sId),
        service: Seletor(name: task.service.name, sId: task.service.sId),
        quantity: quantity,
        totalValue: quantity * unitValue,
        unitValue: unitValue,
        observation: observation,
      ));
      setState(() {});
    } catch (e, s) {
      print(e);
      print(s);
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
    var dateParsed = DateTime.parse(widget.date);
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    var date = dateFormat.format(dateParsed);
    measurementBody = MeasurementBody(
      address: widget.dataLogged["local_negocio"]["name"],
      measurements: [],
      date: date,
      company: widget.dataLogged['empresa']['name'].toString(),
      nameBuild: Seletor(
          name: widget.dataLogged['obra']['data']["tb01_cp002"],
          sId: widget.dataLogged['obra']['id']),
      responsible: widget.dataLogged['user']['name'],
      segment: widget.dataLogged['obra']['data']['tb01_cp026']['name'],
    );
  }

  Build obra;
  MeasurementBody measurementBody;
  MeasurementAppointment measurementAppointment;
  Future<bool> returnScreenAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Sair do apontamento'),
            content: Text('Deseja salvar um rascunho?'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        Provider.of<MeasurementData>(context, listen: false)
                            .clearMeasurementData();
                        Navigator.pop(context, true);
                        Navigator.pop(context);
                      },
                      child: const Text('Não')),
                  TextButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    CircularProgressIndicator(),
                                    Text('Salvando...')
                                  ],
                                ),
                              );
                            });
                        measurementAppointment = MeasurementAppointment(
                          data: measurementBody,
                        );
                        Provider.of<MeasurementData>(context, listen: false)
                            .setMeasurementData(measurementAppointment);
                        developer.log(
                            'measurementAppointment: ${jsonEncode(measurementAppointment.data.toJson())}');
                        await Future.delayed(Duration(seconds: 1));
                        Navigator.of(context).pop();
                        Navigator.pop(context, true);
                      },
                      child: const Text('Sim')),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldSave = await returnScreenAlert(context);

        print(shouldSave);
        return shouldSave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Relatório de Medição'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: colaborators == null ? 0 : colaborators.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 2,
                      crossAxisSpacing: 2,
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    Task selected;
                    return Card(
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                List<DropdownMenuItem> dropdownMenuItems = [];
                                for (Task task in storedBuild.tasks) {
                                  dropdownMenuItems.add(DropdownMenuItem(
                                    child: Text(task.local.name +
                                        ' | ' +
                                        task.sector.name +
                                        ' | ' +
                                        task.service.name),
                                    value: task,
                                  ));
                                }

                                var quantidadeController =
                                    TextEditingController();
                                var valorUnitarioController =
                                    TextEditingController();
                                var observacaoController =
                                    TextEditingController();
                                var _globalKey = GlobalKey<FormState>();
                                return AlertDialog(
                                  content: Form(
                                    key: _globalKey,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SearchChoices.single(
                                            items: dropdownMenuItems,
                                            value: selected,
                                            hint: "Escolha um serviço",
                                            onClear: () {
                                              selected = null;
                                            },
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Campo obrigatório';
                                              }
                                              return null;
                                            },
                                            onChanged: (Task value) {
                                              setState(() {
                                                selected = value;
                                                print(selected.toJson());
                                              });
                                            },
                                            isExpanded: true,
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Campo obrigatório';
                                              }
                                              return null;
                                            },
                                            controller: quantidadeController,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d+\,?\d{0,2}')),
                                            ],
                                            decoration: InputDecoration(
                                              labelText: 'Quantidade',
                                            ),
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Campo obrigatório';
                                              }
                                              return null;
                                            },
                                            controller: valorUnitarioController,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(),
                                            decoration: InputDecoration(
                                              labelText: 'Valor Unitário',
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d+\,?\d{0,2}')),
                                            ],
                                          ),
                                          TextFormField(
                                            controller: observacaoController,
                                            decoration: InputDecoration(
                                              labelText: 'Observação',
                                            ),
                                          ),
                                        ]),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (_globalKey.currentState
                                            .validate()) {
                                          addMeasurement(
                                              colaborator: colaborators[index],
                                              task: selected,
                                              quantity: double.parse(
                                                  quantidadeController.text
                                                      .replaceAll(',', '.')),
                                              unitValue: double.parse(
                                                  valorUnitarioController.text
                                                      .replaceAll(',', '.')),
                                              observation:
                                                  observacaoController.text);
                                          Navigator.pop(context);
                                          showSnackBar(
                                              'Medição criada!', Colors.green);
                                        }
                                      },
                                      child: Text('Adicionar'),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: ListTile(
                            title: Center(
                          child: Text(
                            colaborators[index]['data']['tb01_cp002'],
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        )),
                      ),
                    );
                  }),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: measurementBody.measurements.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Colaborador: ' +
                                          measurementBody
                                              .measurements[index].namePerson,
                                    ),
                                    Text(
                                      'Serviço: ' +
                                          measurementBody
                                              .measurements[index].service.name,
                                    ),
                                    Text(
                                      'Setor: ' +
                                          measurementBody
                                              .measurements[index].sector.name,
                                    ),
                                    Text(
                                      'Local: ' +
                                          measurementBody
                                              .measurements[index].local.name,
                                    ),
                                    Text(
                                      'Quantidade: ' +
                                          measurementBody
                                              .measurements[index].quantity
                                              .toString(),
                                    ),
                                    Text(
                                      'Valor Unitário: ' +
                                          measurementBody
                                              .measurements[index].unitValue
                                              .toString(),
                                    ),
                                    Text(
                                      'Valor Total: ' +
                                          measurementBody
                                              .measurements[index].totalValue
                                              .toString(),
                                    ),
                                    Text(
                                      'Observação: ' +
                                          measurementBody
                                              .measurements[index].observation,
                                    ),
                                  ],
                                ),
                                actionsAlignment: MainAxisAlignment.spaceAround,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Voltar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      measurementBody.measurements
                                          .removeAt(index);
                                      showSnackBar(
                                          'Medição removida!', Colors.red);
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: Text('Excluir'),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        child: ListTile(
                          title: Text(
                              measurementBody.measurements[index].namePerson),
                          subtitle: Text(measurementBody
                                  .measurements[index].sector.name +
                              '\n' +
                              measurementBody.measurements[index].service.name +
                              '\n' +
                              measurementBody.measurements[index].local.name),
                          trailing: Icon(Icons.search),
                        ),
                      ),
                    );
                  }),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      await measurementJarvis.sendMeasurement(
                          MeasurementAppointment(data: measurementBody),
                          context);
                      showSnackBar('Medição salva!', Colors.green);
                      setState(() {});
                    } catch (e, s) {
                      print(s);
                      showSnackBar(e.toString(), Colors.red);
                    }
                  },
                  child: Text('Salvar'))
            ],
          ),
        ),
      ),
    );
  }
}
