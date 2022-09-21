import 'dart:convert';
import 'package:constata_0_0_2/src/models/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

//SELEÇÃO DE OBRA
class SelectObra extends StatefulWidget {
  var localDeNegocio;
  var empresa;
  var filial;
  var user;

  var obraData;

  SelectObra(
      {Key key,
      this.user,
      this.localDeNegocio,
      this.empresa,
      this.filial,
      this.obraData})
      : super(key: key);

  @override
  _SelectObraState createState() => _SelectObraState();
}

//ESTADO DA SELEÇÃO DE OBRA
class _SelectObraState extends State<SelectObra> {
  //SOLICITA AS OBRAS UTILIZANDO COMO PARAMETRO DE FILTRO O LOCAL DE OBRA SELECIONADO NA PÁGINA ANTERIOR, ARMAZENANDO A RESPOSTA EM UM ARRAY

  List listaDeObras = []; //INICIALIZADOR DA LISTA QUE IRÁ RECEBER AS OBRAS

  @override
  void initState() {
    // REALIZA A BUSCA DAS OBRAS EM TODA INICIALIZAÇÃO DA PÁGINA
    super.initState();
    listaDeObras = widget.obraData;
  }

//WIDGET QUE VERIFICA O ARRAY DE OBRAS E RETORNA DE ACORDO COM A QUANTIDADE DE ITENS
  listagem() {
    if (listaDeObras.isEmpty) {
      return const Center(
        child: Text(
          'Não há obras cadastradas nesse usuário!',
          style: TextStyle(color: Colors.red),
        ),
      );
    } else {
      return GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 1.7),
          shrinkWrap: true,
          itemCount: listaDeObras.isEmpty ? 0 : listaDeObras.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 3,
              child: InkWell(
                onTap: () {
                  setState(() {
                    DateTime now = DateTime.now();
                    SharedPreferences.getInstance().then((value) =>
                        value.setString("timeLogged", now.toString()));
                    print(now.toString());
                    var route = MaterialPageRoute(
                      builder: (BuildContext context) => HomePage(
                        dataLogged: {
                          'user': widget.user,
                          'local_negocio': listaDeObras[index]['data']
                              ['tb01_cp003'],
                          'empresa': {
                            "name": "Constata",
                            "id": "60e5a9782212ef44c4d3b27e"
                          },
                          'filial': {},
                          'obra': listaDeObras[index]
                        },
                      ),
                    );
                    SharedPreferences.getInstance()
                        .then((value) => value.setString(
                            "data",
                            json.encode({
                              'user': widget.user,
                              'token':
                                  Provider.of<Token>(context, listen: false)
                                      .token,
                              'local_negocio': listaDeObras[index]['data']
                                  ['tb01_cp003'],
                              'empresa': {
                                "name": "Constata",
                                "id": "60e5a9782212ef44c4d3b27e"
                              },
                              'filial': {},
                              'obra': listaDeObras[index]
                            })));

                    Navigator.of(context).push(route);
                  });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Escolha uma obra'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/constata_big.png',
                      width: double.infinity,
                    )),
                Divider(),
                listagem(),
              ],
            ),
          ),
        ));
  }
}
