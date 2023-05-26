import 'dart:ui';

import 'package:constata/src/features/transfers/data/repositories/accept_transfer_repository.dart';
import 'package:constata/src/features/transfers/data/repositories/get_transfers_repository.dart';
import 'package:constata/src/features/transfers/domain/usecases/accept_transfer/accept_transfer_usecase_impl.dart';
import 'package:constata/src/features/transfers/domain/usecases/get_transfers/get_transfers_usecase_impl.dart';
import 'package:constata/src/features/transfers/external/datasources/accept_transfer/accept_transfer_datasource.dart';
import 'package:constata/src/features/transfers/external/datasources/get_transfers_datasource.dart';
import 'package:constata/src/features/transfers/presenter/create_transfer/create_transfer_controller.dart';
import 'package:constata/src/features/transfers/presenter/create_transfer/create_transfer_page.dart';
import 'package:constata/src/features/transfers/presenter/get_transfer/get_transfer_controller.dart';
import 'package:constata/src/shared/http_client.dart';
import 'package:flutter/material.dart';

class TransferPage extends StatefulWidget {
  final Map<String, dynamic> obra;

  const TransferPage({Key key, this.obra}) : super(key: key);

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _controller = TransferController(
      GetTransfersUseCaseImpl(
        GetTransfersRepositoryImpl(
          GetTransfersDataSouceImpl(
            HttpClientAdapter(),
          ),
        ),
      ),
      AcceptTransferUseCaseImpl(
          AcceptTransferRepositoryImpl(AcceptTransferDataSourceImpl())));

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> _isError = ValueNotifier(false);
  void getData() async {
    _isLoading.value = true;
    bool getTransfer = await _controller.getTransfers();
    if (getTransfer) {
      print('Transferências carregadas com sucesso!');
      _isError.value = false;
    } else {
      print('Erro ao carregar transferências!');
      _isError.value = true;
    }
    setState(() {});
    _isLoading.value = false;
    print(_controller.transfers);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferências'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var route = MaterialPageRoute(
            builder: (BuildContext context) =>
                CreateTransferPage(originObra: widget.obra),
          );
          Navigator.of(context).push(route);
        },
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, value, child) {
          return value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ValueListenableBuilder(
                  valueListenable: _isError,
                  builder: (context, value, child) {
                    return value
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Erro ao carregar transferências!'),
                                ElevatedButton(
                                  onPressed: () {
                                    getData();
                                  },
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  'Transferências pendentes',
                                  style: Theme.of(context).textTheme.headline4,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 20),
                                    itemCount: _controller.transfers.length,
                                    itemBuilder: (context, index) {
                                      final transfer =
                                          _controller.transfers[index];
                                      return ExpansionTile(
                                        onExpansionChanged: (value) {
                                          print(transfer);
                                        },
                                        title: Text(transfer.nameEffective),
                                        subtitle: // from to
                                            // Text(
                                            //     '${transfer.originBuild} -> ${transfer.targetBuild}'),
                                            Text(
                                                '${transfer.originBuild} -> ${transfer.targetBuild}'),
                                        trailing: Text(transfer.status),
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                                onPressed: () async {
                                                  final accepted =
                                                      await _controller
                                                          .acceptTransfer(
                                                              transfer);
                                                  if (accepted) {
                                                    //remove from screen and update and show a dialog with success

                                                    _controller.transfers
                                                        .removeAt(index);
                                                    setState(() {});
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Sucesso!'),
                                                          content: const Text(
                                                              'Transferência aceita com sucesso!'),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Ok'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    print(
                                                        'Erro ao aceitar transferência!');
                                                  }
                                                },
                                                child: const Text(
                                                  'Confirmar',
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  final canceled =
                                                      await _controller
                                                          .denyTransfer(
                                                              transfer);
                                                  if (canceled) {
                                                    //remove from screen and update and show a dialog with success

                                                    _controller.transfers
                                                        .removeAt(index);
                                                    setState(() {});
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Sucesso!'),
                                                          content: const Text(
                                                              'Transferência cancelada com sucesso!'),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Ok'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    print(
                                                        'Erro ao cancelar transferência!');
                                                  }
                                                },
                                                child: const Text('Cancelar'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                  },
                );
        },
      ),
    );
  }
}
