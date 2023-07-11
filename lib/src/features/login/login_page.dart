import 'dart:convert';
import 'package:constata/services/messaging/firebase_messaging_service.dart';
import 'package:constata/services/messaging/notification_service.dart';
import 'package:constata/src/features/login/login_controller.dart';
import 'package:constata/src/features/login/login_repository.dart';
import 'package:constata/src/home_page.dart';
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/custom_page_route.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'select_build_page.dart';

//LOGIN
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

//ESTADO DO LOGIN
class _LoginState extends State<Login> {
  final loginController = LoginController(
    LoginRepository(
      Dio(),
    ),
  );

  final ValueNotifier _isLoading = ValueNotifier<bool>(false);

  Future<void> login(String username, String password) async {
    _isLoading.value = true;
    try {
      await loginController.generateToken(username, password);

      final user = await loginController.fetchUserSigned(username);

      final userData = await loginController.pegarParceiroDeNegocio(username);

      final obraData =
          await loginController.fetchObraData(userData['tb01_cp004']);

      var route = CustomPageRoute(
        builder: (BuildContext context) => SelectObra(
          obraData: obraData,
          user: user,
        ),
      );
      _usernameController.clear();
      _passwordController.clear();
      await Navigator.of(context).push(route).then((value) async {
        print(value);
        _usernameController.text = 'kkkkkkkkkkk';
        _passwordController.text = 'kkkkkkkkkkk';
        setState(() {});
        await login(value['user'], value['password']);
      });
    } catch (e, s) {
      print(s);
      String error = e.toString();
      error = error.replaceAll('Exception: ', '');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          );
        },
      );
    }
    _isLoading.value = false;
  }

  Future<void> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("data")) {
      Map dataLogged = await json.decode(prefs.getString("data")!);
      Provider.of<Token>(context, listen: false).setToken(dataLogged['token']);

      var route = CustomPageRoute(
        builder: (BuildContext context) => HomePage(
          dataLogged: dataLogged,
        ),
      );
      Navigator.of(context).push(route);
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFirebaseMessaging();
    checkNotifications();
    isLogged();
    // subscribeToTopic();
  }

  unsubscribeFromTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('all');
  }

  subscribeToTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('all');
  }

  initializeFirebaseMessaging() async {
    await Provider.of<FirebaseMessagingService>(context, listen: false).init();
  }

  checkNotifications() async {
    await Provider.of<NotificationService>(context, listen: false)
        .checkForNotifications();
  }

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/constata_big.png',
                      color: Colors.blue,
                      height: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'nome de usuário',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, value, child) {
                    if (value == true) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await login(
                            _usernameController.text,
                            _passwordController.text,
                          );
                        }
                      },
                      child: const Text('Entrar'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//   var usernameController = TextEditingController();
//   var passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   Map loginResponse = {};
//   Map privilegiesResponse = {};
//   var privilegeDetail;
//   String userType = 'Perfil';
//   var token;
//   var user;
//   List userData = [];
//   List obraData = [];
//   bool termsOfUse = false;
//   bool _hidePassword = true;
//   //Gerar TOKEN - RECEBE O USUÁRIO E A SENHA DIGITADAS PELO USUÁRIO E RETORNA A RESPOSTA DA REQUISIÇÃO
//   Future generateToken() async {
//     try {
//       var headers = {
//         'Authorization': 'Basic amFydmlzQGVmY3MyMDE4OlM0SkJ4NzRv',
//         'Content-Type': 'application/x-www-form-urlencoded',
//       };
//       var request = http.Request('POST',
//           Uri.parse('http://abctech.ddns.net:4230/jarvis/api/oauth/token'));
//       request.bodyFields = {
//         'username': usernameController.text,
//         'password': passwordController.text,
//         'grant_type': 'password'
//       };
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();

//       // verifica se a resposta da requisição foi um sucesso
//       if (response.statusCode == 200) {
//         var auth = jsonDecode(await response.stream.bytesToString());
//         Provider.of<Token>(context, listen: false)
//             .setToken(auth["access_token"]);
//         SharedPreferences.getInstance().then((value) => value.setString(
//             "authentication",
//             jsonEncode({
//               "user": usernameController.text,
//               "password": passwordController.text
//             })));
//         return loginResponse = {'result': true, 'token': auth};
//       } else {
//         return loginResponse = {
//           'result': false,
//           'debug': await response.stream.bytesToString()
//         };
//       }
//     } catch (e) {
//       return loginResponse = {'result': 'exception', 'error': e};
//     }
//   }

// // FUNÇÃO RESPONSÁVEL POR VERIFICAR A RESPOSTA DA FUNÇÃO QUE GERA O TOKEN E
// //CASO TENHA RETORNADO COM SUCESSO, SEGUE O FLUXO DE LOGIN (GERAR TOKEN > CHECAR PRIVILEGIOS > MUDAR DE TELA)
//   Future checkAuth() async {
//     print(loginResponse);

//     switch (loginResponse['result']) {
//       case true:
//         fetchPrivilegies(loginResponse['token']['access_token']).then(
//           (value) {
//             privilegeDetail = json.decode(privilegiesResponse['privilege']);
//             print(privilegeDetail[0]);
//             setState(() {
//               userType = privilegeDetail[0].toString();
//             });

//             fetchCollaborators().then((value) {
//               if (value == true) {
//                 fetchObras().then((value) => mudarTela(user));
//               } else {
//                 showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return const AlertDialog(
//                         content: Text(
//                             'Usuário sem perfil cadastrado, por favor, entre em contato com o escritório!'),
//                       );
//                     });
//               }
//             });
//           },
//         );
//         break;
//       case false:
//         print('nao logou');
//         usernameController.clear();
//         passwordController.clear();

//         showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text('Erro ao entrar'),
//                 content: const Text('Verifique o usuário e/ou a senha!'),
//                 actions: [
//                   ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: const Text('Ok'))
//                 ],
//               );
//             });
//         break;
//       default:
//         print('caiu no default');
//         showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 content: SizedBox(
//                     width: MediaQuery.sizeOf(context).width * 0.7,
//                     height: MediaQuery.sizeOf(context).width * 0.8,
//                     child: Column(children: [
//                       SizedBox(
//                           height: MediaQuery.sizeOf(context).width * 0.5,
//                           child: Icon(Icons.wifi_off_sharp,
//                               size: MediaQuery.sizeOf(context).height * .17)),
//                       SizedBox(
//                         height: MediaQuery.sizeOf(context).width * 0.3,
//                         child: const Text(
//                           'Aparentemente você está sem conexão à internet. Tente novamente mais tarde.',
//                         ),
//                       ),
//                     ])),
//                 actions: [
//                   ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: const Text('Ok'))
//                 ],
//               );
//             });
//     }
//   }

// //FUNÇÃO RESPONSÁVEL POR CONSULTAR O USUÁRIO QUE FOI VALIDADO PELO TOKEN E ARMAZENAR SUAS INFORMAÇÕES NO OBJETO GLOBAL
//   Future fetchPrivilegies(authToken) async {
//     try {
//       var headers = {
//         'Authorization': 'Bearer $authToken',
//         'Content-Type': 'application/json'
//       };
//       var request = http.Request('POST',
//           Uri.parse('http://abctech.ddns.net:4230/jarvis/api/users/filter'));
//       request.body = json.encode({
//         "filters": [
//           {"fieldName": "ckc", "value": "CONPROD001", "expression": "EQUAL"},
//           {
//             "fieldName": "username",
//             "value": usernameController.text,
//             "expression": "EQUAL"
//           }
//         ]
//       });
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         var resposta = await response.stream.bytesToString();
//         setState(() {
//           user = jsonDecode(resposta);
//         });
//         return privilegiesResponse = {'result': true, 'privilege': resposta};
//       } else {
//         return privilegiesResponse = {
//           'result': false,
//           'debug': await response.stream.bytesToString()
//         };
//       }
//     } catch (e) {
//       return privilegiesResponse = {'result': 'exception', 'error': e};
//     }
//   }

// // NAVEGAÇÃO PARA AS TELAS DE SELEÇÕES DE EMPRESA, ETC
//   mudarTela(userLogged) async {
//     print(userLogged);
//     // SharedPreferences.getInstance().then((value) => value.setString("user", json.encode(userLogged[0])));
//     // SharedPreferences.getInstance().then((value) => value.setString("token", json.encode(tokenGenerated)));
//     setState(() {
//       var route = CustomPageRoute(
//         builder: (BuildContext context) => SelectObra(
//           obraData: obraData,
//           user: userLogged[0],
//         ),
//       );
//       usernameController.clear();
//       passwordController.clear();
//       Navigator.of(context).push(route);
//     });
//   }

//   Future isLogged() async {
//     late SharedPreferences sharedPreferences;
//     await SharedPreferences.getInstance()
//         .then((value) => sharedPreferences = value);
//     if (sharedPreferences.containsKey("data")) {
//       Map dataLogged = await json.decode(sharedPreferences.getString("data")!);
//       Provider.of<Token>(context, listen: false).setToken(dataLogged['token']);

//       var route = CustomPageRoute(
//         builder: (BuildContext context) => HomePage(
//           dataLogged: dataLogged,
//         ),
//       );
//       await Navigator.of(context).push(route).then((value) {
//         print(value);
//         usernameController.text = value['username'];
//         passwordController.text = value['password'];

//         showLoading(context);
//         generateToken().then((value) {
//           TextInput.finishAutofillContext();
//           Navigator.of(context).pop();
//           checkAuth();
//         });
//       });

//       return true;
//     }
//   }

//   Future<bool> fetchCollaborators() async {
//     var headers = {
//       'Authorization':
//           'Bearer ${Provider.of<Token>(context, listen: false).token}',
//       'Content-Type': 'application/json'
//     };
//     var request = http.Request(
//         'POST',
//         Uri.parse(
//             'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-pem-permd-00/filter'));
//     request.body =
//         '''{"filters": [{"fieldName": "data.tb01_cp137.name","value": "${usernameController.text}","expression": "EQUAL"}]}''';
//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       userData = jsonDecode(await response.stream.bytesToString());
//       setState(() {});
//       if (userData.isNotEmpty) {
//         print(userData[0]['data']['tb01_cp004']);
//         print('fetch user');
//         return true;
//       }
//     } else {
//       print(response.reasonPhrase);
//       print('fetch user erro');
//       print(response.statusCode);
//       return false;
//     }
//     return false;
//   }

//   Future<bool> fetchObras() async {
//     var headers = {
//       'Authorization':
//           'Bearer ${Provider.of<Token>(context, listen: false).token}',
//       'Content-Type': 'application/json'
//     };
//     var request = http.Request(
//         'POST',
//         Uri.parse(
//             'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjmd-00/filter'));
//     request.body =
//         '''{"filters": [{"fieldName": "data.tb03_cp008.tp_cp009","value": "${userData[0]['data']['tb01_cp004']}","expression": "EQUAL"}]}''';

//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();
//     developer.log(response.statusCode.toString(), name: 'statusCode');
//     if (response.statusCode == 200) {
//       obraData = jsonDecode(await response.stream.bytesToString());
//       setState(() {});
//       if (obraData.isNotEmpty) {
//         print('fetch obra');
//         developer.log(obraData.length.toString(), name: 'Quantidade de Obras');
//         return true;
//       }
//     } else {
//       print(response.reasonPhrase);
//       developer.log(obraData.length.toString(), name: 'Quantidade de Obras');

//       print('fetch obra erro');
//       return false;
//     }
//     return false;
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       isLogged();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SizedBox(
//       width: MediaQuery.sizeOf(context).width,
//       height: MediaQuery.sizeOf(context).height,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(8),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const SizedBox(
//               height: 50,
//             ),
//             Container(
//                 alignment: Alignment.center,
//                 child: Image.asset(
//                   'assets/images/constata_big.png',
//                   width: double.infinity,
//                 )),
//             const Divider(),
//             const SizedBox(
//               height: 30,
//             ),
//             Form(
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 key: _formKey,
//                 child: AutofillGroup(
//                   onDisposeAction: AutofillContextAction.commit,
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: TextFormField(
//                           autofillHints: const [
//                             AutofillHints.username,
//                           ],
//                           controller: usernameController,
//                           enableSuggestions: false,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return 'Digite o usuário';
//                             }
//                             return null;
//                           },
//                           decoration: const InputDecoration(
//                               border: OutlineInputBorder(),
//                               labelText: 'Digite o seu usuário'),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: TextFormField(
//                           autofillHints: const [
//                             AutofillHints.password,
//                           ],
//                           onEditingComplete: () =>
//                               TextInput.finishAutofillContext(),
//                           controller: passwordController,
//                           obscureText: _hidePassword,
//                           enableSuggestions: false,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return 'Digite a senha';
//                             }
//                             return null;
//                           },
//                           decoration: InputDecoration(
//                               suffixIcon: IconButton(
//                                 icon: Icon(_hidePassword
//                                     ? Icons.visibility_off
//                                     : Icons.visibility),
//                                 onPressed: () {
//                                   setState(() {
//                                     _hidePassword = !_hidePassword;
//                                   });
//                                 },
//                               ),
//                               border: const OutlineInputBorder(),
//                               labelText: 'Digite a sua senha'),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 20.0,
//                         width: double.infinity,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: termsOfUse
//                                 ? () {
//                                     showLoading(context);
//                                     generateToken().then((value) {
//                                       TextInput.finishAutofillContext();
//                                       Navigator.of(context).pop();
//                                       checkAuth();
//                                     });
//                                   }
//                                 : null,
//                             child: const Text('Entrar'),
//                           ),
//                         ),
//                       ),
//                       CheckboxListTile(
//                           value: termsOfUse,
//                           title: RichText(
//                             text: TextSpan(
//                               style: const TextStyle(color: Colors.black),
//                               text: 'Concordo com os ',
//                               children: [
//                                 _buildLink(
//                                     context: context,
//                                     title: 'Termos de uso',
//                                     onTap: () {
//                                       showDialog(
//                                         context: context,
//                                         barrierDismissible:
//                                             false, // user must tap button!

//                                         builder: (BuildContext context) {
//                                           return AlertDialog(
//                                             title: const Text(
//                                                 'Termos e condições gerais de uso (e de compra e venda) do OU site ___ OU aplicativo ____'),
//                                             content:
//                                                 const SingleChildScrollView(
//                                               child: ListBody(
//                                                 children: [
//                                                   Text('''
//                                                         Por meio de seus termos e condições gerais de uso e/ou de venda, um site ou um aplicativo explica aos usuários quais são as condições de utilização do serviço disponibilizado através de sua página ou programa, seja ele gratuito ou pago. Além de informar o usuário sobre a necessidade de cadastro ou sobre os elementos protegidos por direitos autorais, este instrumento determina, ainda, as responsabilidades de cada uma das partes - editor (pessoa que mantém o site ou aplicativo) e usuário -, em relação ao uso do serviço.

//                 Nos casos em que o site ou o aplicativo colocar à venda produtos ou serviços, este documento virá, também, complementado pelas condições gerais de venda, que regularão os detalhes desta transação, tais como as formas de pagamento, a entrega e a política de trocas e devoluções.

//                 Este documento, ainda, estabelecerá o limite mínimo de idade que o usuário do site deve ter para utilizá-lo. Nos casos em que houver a possibilidade ou a necessidade de cadastro prévio ao acesso a todas ou a parte das funcionalidades do site ou aplicativo, será possível definir, ainda, a idade mínima para cadastro.

//                 Como utilizar este documento?

//                 Após devidamente preenchidos com as informações do site ou aplicativo, os termos e condições gerais de uso e/ou de venda devem ser colocados à disposição para consulta direta dos internautas, em link na própria página ou programa.

//                 Toda pessoa que desejar ter acesso ao serviço oferecido pelo site ou pelo aplicativo deverá, antes, concordar com as normas contidas neste documento. Por isso, no momento de início da navegação ou de cadastro do usuário, o documento deve ser exibido ao usuário, para que este o leia e, ao final, o aprove. Quando o site ou o aplicativo realizar venda de produtos ou serviços, as condições gerais de venda devem ser apresentadas ao cliente antes do registro de seu pedido.

//                 As pessoas que não concordarem com quaisquer das regras presentes nos termos e condições gerais de uso e/ou de venda não deverão utilizar o serviço; ao mesmo tempo, aqueles que efetivamente usarem o site ou o aplicativo estarão demonstrando a aprovação destas normas.

//                 Em caso de modificação deste instrumento, a sua versão atualizada deverá ser colocada imediatamente no site ou no aplicativo, para consulta dos usuários, que poderão, ainda, ser notificados via mensagem pessoal sobre as alterações realizadas.

//                 Proteção de dados pessoais

//                 Este modelo não inclui disposições específicas sobre proteção de dados pessoais. Ele apenas faz menção à existência de uma Política de Privacidade, documento previsto na Lei Federal n. 13.709/2018 (Lei Geral de Proteção de Dados Pessoais), sendo que este modelo, em si, não contém a referida política.

//                 A Política de Privacidade é documento por meio do qual uma pessoa física ou jurídica que realiza qualquer operação de tratamento de dados pessoais (coleta, armazenamento, transferência etc.) informa aos titulares daqueles dados sobre o que é feito com eles e sobre como podem exercer seus direitos previstos na Lei Geral de Proteção de Dados Pessoais, dentre outras disposições.
//                                                         '''),
//                                                 ],
//                                               ),
//                                             ),
//                                             actions: [
//                                               ElevatedButton(
//                                                 child: const Text('Ok'),
//                                                 onPressed: () {
//                                                   Navigator.of(context).pop();
//                                                 },
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       );
//                                     }),
//                                 const TextSpan(text: ' e a '),
//                                 _buildLink(
//                                   context: context,
//                                   title: 'Política de Privacidade',
//                                   onTap: () {
//                                     showDialog(
//                                       context: context,
//                                       barrierDismissible:
//                                           false, // user must tap button!

//                                       builder: (BuildContext context) {
//                                         return AlertDialog(
//                                           title: const Text(
//                                               'Termos e condições gerais de uso (e de compra e venda) do OU site ___ OU aplicativo ____'),
//                                           content: const SingleChildScrollView(
//                                             child: ListBody(
//                                               children: [
//                                                 Text('''
//                                                         Por meio de seus termos e condições gerais de uso e/ou de venda, um site ou um aplicativo explica aos usuários quais são as condições de utilização do serviço disponibilizado através de sua página ou programa, seja ele gratuito ou pago. Além de informar o usuário sobre a necessidade de cadastro ou sobre os elementos protegidos por direitos autorais, este instrumento determina, ainda, as responsabilidades de cada uma das partes - editor (pessoa que mantém o site ou aplicativo) e usuário -, em relação ao uso do serviço.

//                 Nos casos em que o site ou o aplicativo colocar à venda produtos ou serviços, este documento virá, também, complementado pelas condições gerais de venda, que regularão os detalhes desta transação, tais como as formas de pagamento, a entrega e a política de trocas e devoluções.

//                 Este documento, ainda, estabelecerá o limite mínimo de idade que o usuário do site deve ter para utilizá-lo. Nos casos em que houver a possibilidade ou a necessidade de cadastro prévio ao acesso a todas ou a parte das funcionalidades do site ou aplicativo, será possível definir, ainda, a idade mínima para cadastro.

//                 Como utilizar este documento?

//                 Após devidamente preenchidos com as informações do site ou aplicativo, os termos e condições gerais de uso e/ou de venda devem ser colocados à disposição para consulta direta dos internautas, em link na própria página ou programa.

//                 Toda pessoa que desejar ter acesso ao serviço oferecido pelo site ou pelo aplicativo deverá, antes, concordar com as normas contidas neste documento. Por isso, no momento de início da navegação ou de cadastro do usuário, o documento deve ser exibido ao usuário, para que este o leia e, ao final, o aprove. Quando o site ou o aplicativo realizar venda de produtos ou serviços, as condições gerais de venda devem ser apresentadas ao cliente antes do registro de seu pedido.

//                 As pessoas que não concordarem com quaisquer das regras presentes nos termos e condições gerais de uso e/ou de venda não deverão utilizar o serviço; ao mesmo tempo, aqueles que efetivamente usarem o site ou o aplicativo estarão demonstrando a aprovação destas normas.

//                 Em caso de modificação deste instrumento, a sua versão atualizada deverá ser colocada imediatamente no site ou no aplicativo, para consulta dos usuários, que poderão, ainda, ser notificados via mensagem pessoal sobre as alterações realizadas.

//                 Proteção de dados pessoais

//                 Este modelo não inclui disposições específicas sobre proteção de dados pessoais. Ele apenas faz menção à existência de uma Política de Privacidade, documento previsto na Lei Federal n. 13.709/2018 (Lei Geral de Proteção de Dados Pessoais), sendo que este modelo, em si, não contém a referida política.

//                 A Política de Privacidade é documento por meio do qual uma pessoa física ou jurídica que realiza qualquer operação de tratamento de dados pessoais (coleta, armazenamento, transferência etc.) informa aos titulares daqueles dados sobre o que é feito com eles e sobre como podem exercer seus direitos previstos na Lei Geral de Proteção de Dados Pessoais, dentre outras disposições.
//                                                         '''),
//                                               ],
//                                             ),
//                                           ),
//                                           actions: [
//                                             ElevatedButton(
//                                               child: const Text('Ok'),
//                                               onPressed: () {
//                                                 Navigator.of(context).pop();
//                                               },
//                                             ),
//                                           ],
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           onChanged: (value) {
//                             setState(() {
//                               termsOfUse = value!;
//                             });
//                           }),
//                     ],
//                   ),
//                 )),
//           ],
//         ),
//       ),
//     ));
//   }

//   _buildLink({
//     required BuildContext context,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return TextSpan(
//       text: title,
//       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//             fontSize: 14.0,
//             color: Colors.redAccent,
//           ),
//       recognizer: TapGestureRecognizer()..onTap = onTap,
//     );
//   }
}
