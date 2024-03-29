import 'package:constata/src/features/transfers/data/repositories/accept_transfer_repository.dart';
import 'package:constata/src/features/transfers/data/repositories/get_transfers_repository.dart';
import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/usecases/accept_transfer/accept_transfer_usecase_impl.dart';
import 'package:constata/src/features/transfers/domain/usecases/get_transfers/get_transfers_usecase_impl.dart';
import 'package:constata/src/features/transfers/external/datasources/accept_transfer/accept_transfer_datasource.dart';
import 'package:constata/src/features/transfers/external/datasources/get_transfers_datasource.dart';
import 'package:constata/src/features/transfers/presenter/create_transfer/create_transfer_page.dart';
import 'package:constata/src/features/transfers/presenter/get_transfer/get_transfer_controller.dart';
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/custom_page_route.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../services/messaging/firebase_messaging_service.dart';
import '../../common/update_colaboradores.dart';

class TransferPage extends StatefulWidget {
  final Map<String, dynamic> obra;

  const TransferPage({Key? key, required this.obra}) : super(key: key);

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _controller = TransferController(
    GetTransfersUseCaseImpl(
      GetTransfersRepositoryImpl(
        GetTransfersDataSouceImpl(),
      ),
    ),
    AcceptTransferUseCaseImpl(
      AcceptTransferRepositoryImpl(AcceptTransferDataSourceImpl()),
    ),
  );

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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferências'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var route = CustomPageRoute(
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
          return value == true
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ValueListenableBuilder(
                  valueListenable: _isError,
                  builder: (context, value, child) {
                    return value == true
                        ? _buildErrorContent()
                        : _buildTransferList();
                  },
                );
        },
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Erro ao carregar transferências!'),
          ElevatedButton(
            onPressed: () {
              getData();
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _controller.transfers.isEmpty
            ? [
                const Text(
                  'Nenhuma transferência pendente!'
                  '\n'
                  'Clique no botão + para criar uma nova transferência!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ]
            : [
                const SizedBox(height: 20),
                Text(
                  'Transferências pendentes',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemCount: _controller.transfers.length,
                    itemBuilder: (context, index) {
                      final transfer = _controller.transfers[index];
                      return _buildExpansionTile(transfer, index);
                    },
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildExpansionTile(TransferEntity transfer, int index) {
    return ExpansionTile(
      onExpansionChanged: (value) {
        print(transfer);
      },
      title: Text(transfer.nameEffective!),
      // subtitle: Text('${transfer.originBuild} (arrow icon here) ${transfer.targetBuild}'),
      subtitle:
          Text('De: ${transfer.originBuild}\nPara: ${transfer.targetBuild} '),

      trailing: Text(transfer.status!),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _showCancelDialog(transfer, index);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _showConfirmDialog(transfer, index);
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showConfirmDialog(TransferEntity transfer, int index) async {
    final token = Provider.of<Token>(context, listen: false).token;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar transferência'),
          content:
              const Text('Tem certeza que deseja confirmar a transferência?'),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () async {
                final accepted = await _controller.acceptTransfer(transfer);
                if (accepted) {
                  _controller.transfers.removeAt(index);
                  setState(() {});
                  _showSuccessDialog('Transferência aceita com sucesso!');
                  await Provider.of<FirebaseMessagingService>(context,
                          listen: false)
                      .sendMessageConfirmedTranfer(transfer.originBuild!,
                          transfer.targetBuild!, transfer.nameEffective!);
                  final updateColab = await UpdateColaborators()
                      .fetchColaboradores(
                          token: token, obra: transfer.targetBuild!);

                  updateColab == true
                      ? print('Colaboradores atualizados com sucesso!')
                      : print('Erro ao atualizar colaboradores!');
                } else {
                  print('Erro ao aceitar transferência!');
                }
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCancelDialog(
    TransferEntity transfer,
    int index,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar transferência'),
          content:
              const Text('Tem certeza que deseja cancelar a transferência?'),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () async {
                final canceled = await _controller.denyTransfer(transfer);
                if (canceled) {
                  _controller.transfers.removeAt(index);
                  await Provider.of<FirebaseMessagingService>(context,
                          listen: false)
                      .sendMessageDeniedTransfer(transfer.originBuild!,
                          transfer.targetBuild!, transfer.nameEffective!);
                  setState(() {});
                  Navigator.of(context).pop();
                  _showSuccessDialog('Transferência cancelada com sucesso!');
                } else {
                  _showErrorDialog('Erro ao cancelar transferência!');
                }
              },
              child: const Text('Sim'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Não'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sucesso!'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String s) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro!'),
          content: Text(s),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}

class TransferListLoading extends StatelessWidget {
  const TransferListLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class TransferListError extends StatelessWidget {
  final VoidCallback onRetry;

  const TransferListError({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Erro ao carregar transferências!'),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class TextWithIcon extends StatelessWidget {
  final String origin;
  final String target;

  const TextWithIcon({
    Key? key,
    required this.origin,
    required this.target,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: origin,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const WidgetSpan(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.black,
              ),
            ),
          ),
          TextSpan(
            text: target,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
