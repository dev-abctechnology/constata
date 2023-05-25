import 'package:constata/src/home_page.dart';
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
  Widget build(BuildContext context) {
    String obra = widget.arguments['obra']['data']['tb01_cp002'];
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                isAntiAlias: true,
                alignment: Alignment.center,
                image: AssetImage('assets/constata.png'),
                opacity: 0.25)),
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
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  children: <Widget>[
                    GridButton(
                        icon: const Icon(
                          Icons.edit_calendar,
                          size: 30,
                        ),
                        label: "1 - Controle de Efetivo",
                        onPressed: () {
                          setState(() {
                            var route = MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  EffectiveControl(
                                dataLogged: widget.arguments,
                              ),
                            );
                            Navigator.of(context).push(route);
                          });
                        }),
                    GridButton(
                      icon: const Icon(Icons.add_task, size: 30),
                      label: "2 - Controle de medição",
                      onPressed: () => navigateMedicao(context),
                    ),
                    GridButton(
                        label: "3 - Controle de EPI",
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
                        label: "4 - Controle de Ferramentas",
                        icon: const Icon(
                          Icons.handyman,
                          size: 30,
                        )),
                    GridButton(
                        onPressed: () {
                          var route = MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const TransferPage(),
                          );

                          Navigator.of(context).push(route);
                        },
                        label: "5 - Transferências",
                        icon: const Icon(
                          Icons.transfer_within_a_station,
                          size: 30,
                        )),
                  ],
                ),
              ),
            ),
            Divider(),
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.065,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () {
                  exitApplication(context);
                },
                child: Text('Sair'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
