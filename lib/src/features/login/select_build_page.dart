import 'dart:convert';
import 'package:constata/services/messaging/firebase_messaging_service.dart';
import 'package:constata/src/home_page.dart';
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/utils.dart';

class SelectObra extends StatefulWidget {
  var user;

  var obraData;

  SelectObra({Key? key, required this.user, required this.obraData})
      : super(key: key);

  @override
  _SelectObraState createState() => _SelectObraState();
}

class _SelectObraState extends State<SelectObra> {
  List listaDeObras = [];

  @override
  void initState() {
    listaDeObras = widget.obraData;
    super.initState();
  }

  Widget listagem() {
    if (listaDeObras.isEmpty) {
      return const Center(
        child: Text(
          'Não há obras cadastradas nesse usuário!',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
      );
    } else {
      return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 1.7),
          shrinkWrap: true,
          itemCount: listaDeObras.isEmpty ? 0 : listaDeObras.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 3,
              child: InkWell(
                onTap: () async {
                  var route = CustomPageRoute(
                    builder: (BuildContext context) => HomePage(
                      dataLogged: generateDataLogged(index),
                    ),
                  );
                  SharedPreferences.getInstance().then((value) =>
                      value.setString(
                          "data",
                          json.encode(
                              generateStoredDataLogged(context, index))));

                  final topicName = convertToValidTopicName(
                      listaDeObras[index]['data']['tb01_cp002']);
                  await Provider.of<FirebaseMessagingService>(context,
                          listen: false)
                      .unsubscribeFromAllTopics();
                  final subscribe = await Provider.of<FirebaseMessagingService>(
                          context,
                          listen: false)
                      .subscribeToTopic(topicName);
                  print(
                      'inscrição no tópico ${listaDeObras[index]['data']['tb01_cp002']}: $subscribe');
                  Navigator.of(context).push(route);
                },
                child: ListTile(
                    title: Center(
                        child: Text(
                            '${listaDeObras[index]['data']['tb01_cp002']}',
                            textAlign: TextAlign.center))),
              ),
            );
          });
    }
  }

  Map<String, dynamic> generateStoredDataLogged(
      BuildContext context, int index) {
    return {
      'user': widget.user,
      'token': Provider.of<Token>(context, listen: false).token,
      'local_negocio': listaDeObras[index]['data']['tb01_cp003'],
      'empresa': {"name": "Constata", "id": "60e5a9782212ef44c4d3b27e"},
      'filial': {},
      'obra': listaDeObras[index]
    };
  }

  Map<dynamic, dynamic> generateDataLogged(int index) {
    return {
      'user': widget.user,
      'local_negocio': listaDeObras[index]['data']['tb01_cp003'],
      'empresa': const {"name": "Constata", "id": "60e5a9782212ef44c4d3b27e"},
      'filial': const {},
      'obra': listaDeObras[index]
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Escolha uma obra'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Card(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/constata_big.png',
                    color: Colors.blue,
                    width: double.infinity,
                  ),
                )),
                const Divider(),
                listagem(),
              ],
            ),
          ),
        ));
  }
}
