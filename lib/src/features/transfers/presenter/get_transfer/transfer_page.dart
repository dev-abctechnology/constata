import 'package:constata/src/features/transfers/data/repositories/get_transfers_repository.dart';
import 'package:constata/src/features/transfers/domain/usecases/get_transfers/get_transfers_usecase_impl.dart';
import 'package:constata/src/features/transfers/external/datasources/get_transfers_datasource.dart';
import 'package:constata/src/features/transfers/presenter/create_transfer/create_transfer_controller.dart';
import 'package:constata/src/features/transfers/presenter/create_transfer/create_transfer_page.dart';
import 'package:constata/src/features/transfers/presenter/get_transfer/get_transfer_controller.dart';
import 'package:constata/src/shared/http_client.dart';
import 'package:flutter/material.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({Key key}) : super(key: key);

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _getTransferController = TransferController(
    GetTransfersUseCaseImpl(
      GetTransfersRepositoryImpl(
        GetTransfersDataSouceImpl(
          HttpClientAdapter(),
        ),
      ),
    ),
  );

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  void getData() async {
    _isLoading.value = true;
    await _getTransferController.getTransfers();
    setState(() {});
    _isLoading.value = false;
    print(_getTransferController.transfers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var route = MaterialPageRoute(
            builder: (BuildContext context) => const CreateTransferPage(),
          );
          Navigator.of(context).push(route);
        },
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, value, child) {
          return value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: getData,
                        child: const Text('Get Transfers'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Transfers',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 20),
                          itemCount: _getTransferController.transfers.length,
                          itemBuilder: (context, index) {
                            final transfer =
                                _getTransferController.transfers[index];
                            return ExpansionTile(
                              title: Text(transfer.nameEffective),
                              subtitle: Text(transfer.codeEffective),
                              trailing: Text(transfer.status),
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Lógica para confirmar a transferência
                                      },
                                      child: const Text('Confirm'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Lógica para rejeitar a transferência
                                      },
                                      child: const Text('Reject'),
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
      ),
    );
  }
}
