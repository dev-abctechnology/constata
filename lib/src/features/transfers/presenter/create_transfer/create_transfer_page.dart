import 'dart:convert';

import 'package:constata/src/features/transfers/data/repositories/create_transfer_repository.dart';
import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/usecases/create_transfer/create_transfer_usercase_impl.dart';
import 'package:constata/src/features/transfers/external/datasources/create_transfer/create_transfer_datasouce.dart';
import 'package:constata/src/features/transfers/presenter/create_transfer/create_transfer_controller.dart';
import 'package:constata/src/models/seletor_obra_model.dart';
import 'package:constata/src/shared/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;

class CreateTransferPage extends StatefulWidget {
  const CreateTransferPage({Key key}) : super(key: key);

  @override
  State<CreateTransferPage> createState() => _CreateTransferPageState();
}

class _CreateTransferPageState extends State<CreateTransferPage> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> _isError = ValueNotifier(false);
  final ValueNotifier<bool> _isSuccess = ValueNotifier(false);

  sendTransfer() async {
    _isLoading.value = true;
    final _createTransferController = CreateTransferController(
        CreateTransferUseCaseImpl(
            CreateTransferRepositoryImpl(CreateTransferDataSourceImpl())),
        _transferEntity);

    try {
      final response = await _createTransferController.createTransfer();
      if (response) {
        _isSuccess.value = true;
      } else {
        _isError.value = true;
      }
    } catch (e) {
      _isError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  List efetivo = [];
  void listaEfetivo() async {
    final prefs = SharedPrefs();
    efetivo = jsonDecode(await prefs.getString('colaboradores'));
    // print(efetivo);
    setState(() {});
  }

  int _currentStep = 0;
  TransferEntity _transferEntity = TransferEntity();

  List<ObraSeletor> obras = [];

  Future fetchObras() async {
    final prefs = SharedPrefs();
    final token = await prefs.getString('token');
    var headers = {
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
      'Authorization': 'Bearer $token',
      'Connection': 'keep-alive',
      'Content-Type': 'application/json',
      'DNT': '1',
      'Origin': 'http://abctech.ddns.net:4200',
      'Referer': 'http://abctech.ddns.net:4200/',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.50'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjmd-00/filter'));
    request.body = json.encode({
      "filters": [],
      "sort": {"fieldName": "data.tb01_cp002", "type": "ASC"},
      "fields": ["_id", "data.tb01_cp002"]
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var body = await response.stream.bytesToString();
      var data = jsonDecode(body);
      obras = data.map<ObraSeletor>((e) => ObraSeletor.fromJson(e)).toList();
      setState(() {});
      print(obras);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Erro'),
                content: const Text('Erro ao buscar obras'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Ok'))
                ],
              ),
          barrierDismissible: false);
    }
  }

  void nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      sendTransfer();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchObras();
    listaEfetivo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Transferência'),
        actions: [
          IconButton(
            onPressed: () {
              listaEfetivo();
            },
            icon: const Icon(Icons.list),
          )
        ],
      ),
      body: Container(
        child: Stepper(
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (_currentStep != 0 && _currentStep > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    child: const Text('Voltar'),
                  ),
                if (_currentStep != 2 && _currentStep < 0)
                  TextButton(
                    onPressed: () {
                      nextStep();
                    },
                    child: const Text('Próximo'),
                  ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Selecionar Efetivo'),
              content: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    title:
                        Text(efetivo[index]['data']['tb01_cp002'].toString()),
                    subtitle:
                        Text(efetivo[index]['data']['tb01_cp004'].toString()),
                    onTap: () {
                      // Salvar a seleção do efetivo no _transferEntity
                      _transferEntity = TransferEntity(
                        nameEffective:
                            efetivo[index]['data']['tb01_cp002'].toString(),
                        // Outros dados do efetivo
                      );
                      nextStep();
                    },
                  );
                },
                itemCount: efetivo.length,
              ),
            ),
            Step(
              title: const Text('Selecionar Obra de Destino'),
              content: Container(
                  child: ListView(
                shrinkWrap: true,
                children: [
                  for (var obra in obras)
                    ListTile(
                      title: Text(obra.name),
                      onTap: () {
                        _transferEntity = TransferEntity(
                          nameEffective: _transferEntity.nameEffective,
                          targetBuild: obra.name,
                          // Outros dados do efetivo
                        );
                        nextStep();
                      },
                    )
                ],
              )),
            ),
            Step(
              title: const Text('Enviar Transferência'),
              content: Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, _) {
                    if (isLoading) {
                      return const CircularProgressIndicator();
                    } else if (_isSuccess.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Solicitação de transferência realizada com sucesso!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Sair'),
                          )
                        ],
                      );
                    } else if (_isError.value) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Ocorreu um erro ao realizar a transferência.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              sendTransfer();
                            },
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Nome: ' + _transferEntity.nameEffective.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text('Saindo de: Obra de origem',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              'Indo para: ${_transferEntity.targetBuild.toString()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              sendTransfer();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Text('Enviar'),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
          currentStep: _currentStep,
          type: StepperType.vertical,
        ),
      ),
    );
  }
}
