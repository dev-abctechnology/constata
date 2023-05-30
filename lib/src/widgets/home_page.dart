import 'package:constata/src/features/effective_clean/presenter/effective_page.dart';
import 'package:constata/src/home_page.dart';
import 'package:constata/src/shared/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/transfers/presenter/get_transfer/transfer_page.dart';
import '../models/token.dart';
import '../shared/company_refresh_controller.dart';
import '../shared/load_controller.dart';
import '../features/effective_process/effective_control.dart';
import '../features/epi_process/epi_home_page.dart';
import '../features/measurement/measurement_page.dart';
import '../features/tools/select_date_page.dart';
import 'grid_button.dart';

class HomePageBody extends StatefulWidget {
  final Map arguments;

  const HomePageBody({Key key, this.arguments}) : super(key: key);

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  Future<dynamic> exitApplication(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Desconectar'),
          content: const Text(
              'Tem certeza que deseja sair?\n\nSerá necessário entrar com seu usuário e senha na próxima vez que for utilizar o aplicativo.\n'
              '\nTodos os dados armazenados no aplicativo serão apagados.'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Column(
                    children: const [Icon(Icons.approval), Text('Ficar')],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () {
                    SharedPreferences.getInstance().then(
                      (value) => value.remove("data"),
                    );
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Column(
                    children: const [Icon(Icons.exit_to_app), Text('Sair')],
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void navigateMedicao(BuildContext context) {
    return setState(() {
      showLoading(context);
      CompanyRefreshController.refresh(
              widget.arguments['obra']['data']['tb01_cp002'],
              Provider.of<Token>(context, listen: false).token)
          .then((value) {
        if (value == null) {
          Navigator.of(context).pop();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Verifique sua conexão!'),
                  content: Text(
                      'Não foi possível sincronizar os dados da obra. Caso prossiga, podem ocorrer inconsistências.'),
                );
              }).then((value) {
            var route = MaterialPageRoute(
              builder: (BuildContext context) => Measurement(
                dataLogged: widget.arguments,
              ),
            );

            Navigator.of(context).push(route);
          });
        } else if (value.isNotEmpty) {
          Navigator.of(context).pop();
          widget.arguments['obra'] = value[0];
          var route = MaterialPageRoute(
            builder: (BuildContext context) => Measurement(
              dataLogged: widget.arguments,
            ),
          );

          Navigator.of(context).push(route);
        } else {
          Navigator.of(context).pop();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Ocorreu um problema volte e tente novamente!'),
                  content: Text(
                      'Não foi possível sincronizar os dados da obra. Caso prossiga, podem ocorrer inconsistências.'),
                );
              }).then((value) {
            var route = MaterialPageRoute(
              builder: (BuildContext context) => Measurement(
                dataLogged: widget.arguments,
              ),
            );
            Navigator.of(context).push(route);
          });
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateBuild();
  }

  updateBuild() async {
    var prefs = SharedPrefs();
    String obra = widget.arguments['obra']['data']['tb01_cp002'];

    await prefs.setString('obra', obra);
  }

  @override
  Widget build(BuildContext context) {
    String obra = widget.arguments['obra']['data']['tb01_cp002'];

    String obraId = widget.arguments['obra']['id'].toString();
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02),
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          // color: Colors.green,
          image: DecorationImage(
            isAntiAlias: true,
            fit: BoxFit.cover,
            image: AssetImage('assets/constata.png'),
            opacity: 0.25,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  child: Text('Conectado em $obra',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      )),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/constata_big.png',
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: 1.8,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: <Widget>[
                      GridButton(
                          icon: const Icon(
                            Icons.edit_calendar,
                            size: 30,
                          ),
                          label: "Efetivo",
                          onPressed: () {
                            setState(() {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    EffectiveControl(
                                  dataLogged: widget.arguments,
                                ),
                              );
                              Navigator.of(context).push(route);

                              // var route = MaterialPageRoute(
                              //     builder: (BuildContext context) =>
                              //         EffectiveClean());
                              // Navigator.of(context).push(route);
                            });
                          }),
                      GridButton(
                        icon: const Icon(Icons.add_task, size: 30),
                        label: "medição",
                        onPressed: () => navigateMedicao(context),
                      ),
                      GridButton(
                          label: "EPI",
                          onPressed: () {
                            setState(() {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) => EpiHome(
                                  dataLogged: widget.arguments,
                                ),
                              );

                              Navigator.of(context).push(route);
                            });
                          },
                          icon: const Icon(Icons.health_and_safety, size: 30)),
                      GridButton(
                          onPressed: () {
                            var route = MaterialPageRoute(
                              builder: (BuildContext context) => SelectDatePage(
                                dataLogged: widget.arguments,
                              ),
                            );

                            Navigator.of(context).push(route);
                          },
                          label: "Ferramentas",
                          icon: const Icon(
                            Icons.handyman,
                            size: 30,
                          )),
                      GridButton(
                          onPressed: () async {
                            final prefs = SharedPrefs();
                            await prefs.remove('obra_id');
                            await prefs.setString('obra_id', obraId);

                            var route = MaterialPageRoute(
                              builder: (BuildContext context) => TransferPage(
                                  obra: {'id': obraId, 'name': obra}),
                            );

                            Navigator.of(context).push(route);
                          },
                          label: "Transferências",
                          icon: const Icon(
                            Icons.transfer_within_a_station,
                            size: 30,
                          )),
                      GridButton(
                          color: Colors.red,
                          onPressed: () {
                            exitApplication(context);
                          },
                          label: "Sair",
                          icon: const Icon(
                            Icons.exit_to_app,
                            size: 30,
                          )),
                    ],
                  ),
                ),
              ),
              // Divider(),
              // Container(
              //   width: MediaQuery.of(context).size.width * 0.95,
              //   height: MediaQuery.of(context).size.height * 0.065,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(primary: Colors.red),
              //     onPressed: () {
              //       exitApplication(context);
              //     },
              //     child: Text('Sair'),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
