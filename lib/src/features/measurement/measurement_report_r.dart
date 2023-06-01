import 'dart:convert';
import 'dart:developer' as developer;
import 'package:constata/main.dart';
import 'package:constata/src/features/measurement/controllers/measurement_jarvis.dart';

import 'package:constata/src/features/measurement/model/measurement_object_r.dart';
import 'package:constata/src/models/build_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/currency_input.dart';
import '../../shared/pallete.dart';
import '../../shared/seletor_model.dart';
import 'data/measurement_data.dart';
import 'model/measurement_model.dart';

class MeasurementReportReworked extends StatefulWidget {
  final dataLogged;

  final date;

  final bool edittingMode;

  const MeasurementReportReworked(
      {Key? key, this.dataLogged, this.date, this.edittingMode = false})
      : super(key: key);

  @override
  State<MeasurementReportReworked> createState() =>
      _MeasurementReportReworkedState();
}

class _MeasurementReportReworkedState extends State<MeasurementReportReworked> {
  MeasurementJarvis measurementJarvis = MeasurementJarvis();
  List colaborators = [];
  late Build storedBuild;
  late MeasurementBody measurementBody;
  late MeasurementAppointment measurementAppointment;
  bool loading = false;
  void initialize() async {
    loading = true;
    try {
      try {
        storedBuild = Build.fromJson(widget.dataLogged['obra']['data']);
        for (Task task in storedBuild.tasks!) {
          print(task.local!.name +
              ' | ' +
              task.sector!.name +
              ' | ' +
              task.service!.name);
          print(task.budgetedQuantity);
          print('-----------------------');
        }
      } catch (e, s) {
        print(e);
        print(s);
      }

      String obra = widget.dataLogged['obra']['data']['tb01_cp002'];
      colaborators = await measurementJarvis.fetchColaborators(
          buildName: obra, context: context, date: widget.date);
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString().substring(11), Colors.red);
      SharedPreferences.getInstance().then((value) {
        if (value.containsKey('colaboradores')) {
          colaborators = jsonDecode(value.getString('colaboradores')!);
          // print(colaboradores);
          colaborators = colaborators
              .where((element) =>
                  element['data']['tb01_cp123'][0]['tp_cp132'] == "Sim")
              .toList();
          setState(() {});
        }
      });
    }
    loading = false;
  }

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(message),
    ));
  }

  void addMeasurement(
      {colaborator,
      required Task task,
      required double quantity,
      required double unitValue,
      String observation = ''}) {
    try {
      measurementBody.measurements.add(MeasurementModel(
        codePerson: colaborator['data']['tb01_cp004'],
        namePerson: colaborator['data']['tb01_cp002'],
        measurementUnit:
            Seletor(name: task.measureUnit!.name, sId: task.measureUnit!.sId),
        local: Seletor(name: task.local!.name, sId: task.local!.sId),
        sector: Seletor(name: task.sector!.name, sId: task.sector!.sId),
        service: Seletor(name: task.service!.name, sId: task.service!.sId),
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

    if (widget.edittingMode == true) {
      measurementBody = Provider.of<MeasurementData>(context, listen: false)
          .measurementData
          .data;
    } else {
      measurementBody = MeasurementBody(
        address: widget.dataLogged["local_negocio"]["name"],
        measurements: [],
        date: widget.date,
        company: widget.dataLogged['empresa']['name'].toString(),
        nameBuild: Seletor(
            name: widget.dataLogged['obra']['data']["tb01_cp002"],
            sId: widget.dataLogged['obra']['id']),
        responsible: widget.dataLogged['user']['name'],
        segment: widget.dataLogged['obra']['data']['tb01_cp026']['name'],
      );
    }
  }

  returnScreenAlert(BuildContext context) {
    if (measurementBody.measurements.isEmpty) {
      Provider.of<MeasurementData>(context, listen: false)
          .clearMeasurementData();
      Navigator.pop(context, true);
    } else {
      return showDialog(
          barrierDismissible: false,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                              'measurementAppointment: ${jsonEncode(measurementAppointment.toJson())}');
                          await Future.delayed(Duration(seconds: 1));
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();

                          showSnackBar(
                              'Rascunho salvo com sucesso', Colors.green);
                        },
                        child: const Text('Sim')),
                  ],
                )
              ],
            );
          });
    }
    ;
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
          title: Text('${widget.date} - ${measurementBody.nameBuild.name}'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: loading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text('Carregando...')
                    ],
                  ),
                )
              : Column(
                  children: [
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
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            MeasurementDetailTile(
                                                icon: Icon(Icons.person),
                                                label: 'Nome',
                                                value: measurementBody
                                                    .measurements[index]
                                                    .namePerson),
                                            Divider(
                                                color: Colors.black12,
                                                thickness: 2),
                                            MeasurementDetailTile(
                                                icon: Icon(Icons.location_on),
                                                label: 'Local',
                                                value: measurementBody
                                                    .measurements[index]
                                                    .local
                                                    ?.name),
                                            Divider(
                                                color: Colors.black12,
                                                thickness: 2),
                                            MeasurementDetailTile(
                                                icon: Icon(Icons
                                                    .construction_outlined),
                                                label: 'Setor',
                                                value: measurementBody
                                                    .measurements[index]
                                                    .sector
                                                    ?.name),
                                            Divider(
                                                color: Colors.black12,
                                                thickness: 2),
                                            MeasurementDetailTile(
                                                icon: Icon(Icons.handyman),
                                                label: 'Serviço',
                                                value: measurementBody
                                                    .measurements[index]
                                                    .service
                                                    ?.name),
                                            Divider(
                                                color: Colors.black12,
                                                thickness: 2),
                                            MeasurementDetailTile(
                                              icon: Icon(Icons.account_balance),
                                              label: 'Quantidade',
                                              value: measurementBody
                                                  .measurements[index].quantity
                                                  .toString(),
                                            ),
                                            Divider(
                                                color: Colors.black12,
                                                thickness: 2),
                                            MeasurementDetailTile(
                                              icon: SizedBox(
                                                height: 20,
                                                width: 0,
                                              ),
                                              label: 'Valor Unitário',
                                              value: 'R\$' +
                                                  measurementBody
                                                      .measurements[index]
                                                      .unitValue
                                                      .toStringAsFixed(2),
                                            ),
                                            Divider(
                                                color: Colors.black12,
                                                thickness: 2),
                                            MeasurementDetailTile(
                                              icon: SizedBox(
                                                height: 20,
                                                width: 0,
                                              ),
                                              label: 'Valor Total',
                                              value: 'R\$' +
                                                  measurementBody
                                                      .measurements[index]
                                                      .totalValue
                                                      .toStringAsFixed(2),
                                            ),
                                            Divider(
                                                color: Colors.black12,
                                                thickness: 2),
                                            MeasurementDetailTile(
                                              icon: SizedBox(
                                                height: 20,
                                                width: 0,
                                              ),
                                              label: 'Observação',
                                              value: measurementBody
                                                  .measurements[index]
                                                  .observation,
                                            ),
                                          ],
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceAround,
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            measurementBody.measurements
                                                .removeAt(index);
                                            showSnackBar('Medição removida!',
                                                Colors.red);
                                            Navigator.pop(context);
                                            setState(() {});
                                          },
                                          child: Text('Excluir'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Voltar'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: ListTile(
                                title: Text(measurementBody
                                        .measurements[index].namePerson +
                                    ' - ' +
                                    measurementBody
                                        .measurements[index].codePerson),
                                subtitle: Text(measurementBody
                                        .measurements[index].sector!.name +
                                    '\n' +
                                    measurementBody
                                        .measurements[index].service!.name +
                                    '\n' +
                                    measurementBody
                                        .measurements[index].local!.name),
                                trailing: Icon(Icons.search),
                              ),
                            ),
                          );
                        }),
                    GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            colaborators == null ? 0 : colaborators.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 2,
                                crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          late Task selected;
                          return Card(
                            shadowColor: measurementBody.measurements
                                    .where((element) =>
                                        element.namePerson ==
                                        colaborators[index]['data']
                                            ['tb01_cp002'])
                                    .isNotEmpty
                                ? Colors.green.shade100
                                : Colors.red,
                            elevation: 5,
                            color: measurementBody.measurements
                                    .where((element) =>
                                        element.namePerson ==
                                        colaborators[index]['data']
                                            ['tb01_cp002'])
                                    .isNotEmpty
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      List<DropdownMenuItem<Task>>
                                          dropdownMenuItems = [];
                                      for (Task task in storedBuild.tasks!) {
                                        dropdownMenuItems.add(DropdownMenuItem(
                                          child: Text(task.local!.name +
                                              ' | ' +
                                              task.sector!.name +
                                              ' | ' +
                                              task.service!.name),
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
                                      return searchService(
                                          _globalKey,
                                          dropdownMenuItems,
                                          quantidadeController,
                                          valorUnitarioController,
                                          observacaoController,
                                          context,
                                          index);
                                    });
                              },
                              child: ListTile(
                                  title: Center(
                                child: Text(
                                  colaborators[index]['data']['tb01_cp002']
                                          .toString()
                                          .toUpperCase() +
                                      '\n' +
                                      colaborators[index]['data']['tb01_cp004']
                                          .toString()
                                          .toUpperCase(),
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                            ),
                          );
                        }),
                  ],
                ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 28),
          backgroundColor: Palette.customSwatch,
          visible: true,
          curve: Curves.bounceInOut,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.send, color: Colors.white),
              backgroundColor: Palette.customSwatch,
              onTap: () async {
                if (colaborators
                    .where((element) => measurementBody.measurements
                        .where((element2) =>
                            element2.namePerson ==
                            element['data']['tb01_cp002'])
                        .isEmpty)
                    .isNotEmpty) {
                  showSnackBar('Existem colaboradores sem medição', Colors.red);
                } else if (measurementBody.measurements.isEmpty) {
                  showSnackBar('Não há medições para enviar', Colors.red);
                } else {
                  try {
                    await measurementJarvis
                        .sendMeasurement(
                            MeasurementAppointment(data: measurementBody),
                            context)
                        .then((value) {
                      if (value == 'created') {
                        showSnackBar(
                            'Medição enviada com sucesso!', Colors.green);
                        Navigator.of(context).pop();
                        Provider.of<MeasurementData>(context, listen: false)
                            .clearMeasurementData();
                      } else {
                        var nav = Navigator.of(context);
                        nav.pop();

                        alerta(context);
                        showSnackBar('Erro ao enviar a medição!', Colors.red);
                      }
                    });
                    setState(() {});
                  } catch (e, s) {
                    print(s);
                    showSnackBar(e.toString(), Colors.red);
                  }
                }
              },
              label: 'Enviar',
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  AlertDialog searchService(
      GlobalKey<FormState> _globalKey,
      List<DropdownMenuItem<Task>> dropdownMenuItems,
      TextEditingController quantidadeController,
      TextEditingController valorUnitarioController,
      TextEditingController observacaoController,
      BuildContext context,
      int index) {
    late Task selected;
    return AlertDialog(
      content: Form(
        key: _globalKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SearchChoices.single(
            items: dropdownMenuItems,
            hint: "Escolha um serviço",
            onClear: () {
              setState(() {});
            },
            validator: (value) {
              if (value == null) {
                return 'Campo obrigatório';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (Task value) {
              setState(() {
                selected = value;
                print(selected.toJson());
              });
            },
            closeButton: "Fechar",
            searchFn: (String keyword, items) {
              print(keyword);
              List<int> ret = [];
              if (items != null && keyword.isNotEmpty) {
                keyword.split(" ").forEach((k) {
                  int i = 0;
                  items.forEach((item) {
                    String name = item.value.local.name +
                        ' | ' +
                        item.value.sector.name +
                        ' | ' +
                        item.value.service.name;
                    if (!ret.contains(i) &&
                        k.isNotEmpty &&
                        (name
                            .toString()
                            .toLowerCase()
                            .contains(k.toLowerCase()))) {
                      ret.add(i);
                    }
                    i++;
                  });
                });
              }
              if (keyword.isEmpty) {
                ret = Iterable<int>.generate(items.length).toList();
              }
              return (ret);
            },
            isExpanded: true,
          ),
          TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
            controller: quantidadeController,
            keyboardType: const TextInputType.numberWithOptions(),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Quantidade',
            ),
          ),
          TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
            controller: valorUnitarioController,
            keyboardType: const TextInputType.numberWithOptions(),
            decoration: InputDecoration(
              labelText: 'Valor Unitário',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,2}')),
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
            if (_globalKey.currentState!.validate()) {
              addMeasurement(
                  colaborator: colaborators[index],
                  task: selected,
                  quantity: double.parse(
                      quantidadeController.text.replaceAll(',', '.')),
                  unitValue: double.parse(
                      valorUnitarioController.text.replaceAll(',', '.')),
                  observation: observacaoController.text);
              Navigator.pop(context);
              showSnackBar('Medição criada!', Colors.green);
            }
          },
          child: Text('Adicionar'),
        ),
      ],
    );
  }

  Future alerta(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro no envio!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Parece que você está sem internet.'),
                Text(
                    'O apontamento ficará pendente para envio.\n\nCertifique-se de estar conectado à internet para tentar novamente.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                var nav = Navigator.of(context);
                nav.pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class MeasurementDetailTile extends StatelessWidget {
  const MeasurementDetailTile({
    Key? key,
    this.label,
    this.value,
    this.icon,
  }) : super(key: key);
  final label;
  final icon;
  final value;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          Text(
            label,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}
