import 'package:constata/src/features/transfers/data/repositories/create_transfer_repository.dart';
import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/usecases/create_transfer/create_transfer_usercase_impl.dart';
import 'package:constata/src/features/transfers/external/datasources/create_transfer/create_transfer_datasouce.dart';
import 'package:constata/src/features/transfers/presenter/create_transfer/create_transfer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class CreateTransferPage extends StatefulWidget {
  const CreateTransferPage({Key key}) : super(key: key);

  @override
  State<CreateTransferPage> createState() => _CreateTransferPageState();
}

class _CreateTransferPageState extends State<CreateTransferPage> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> _isError = ValueNotifier(false);
  final ValueNotifier<bool> _isSuccess = ValueNotifier(false);

  send(TransferEntity entity) async {
    _isLoading.value = true;
    final _createTransferController = CreateTransferController(
        CreateTransferUseCaseImpl(
            CreateTransferRepositoryImpl(CreateTransferDataSourceImpl())),
        entity);

    final response = await _createTransferController.createTransfer();
    _isLoading.value = false;
    if (response) {
      _isSuccess.value = true;
      _isError.value = false;
      print("Transferência criada com sucesso");
    } else {
      _isError.value = true;
      _isSuccess.value = false;
      print("Erro ao criar transferência");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Transferência'),
      ),
      body: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return const CircularProgressIndicator();
            } else if (_isSuccess.value) {
              return Column(
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
                      child: const Text('Voltar'))
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
                      final _transferEntity = TransferEntity(
                          nameEffective: "Transfer Entity 5",
                          codeEffective: "TE005",
                          originBuild: "Origin Building I",
                          targetBuild: "Target Building J",
                          status: "Pending",
                          date: "2023-05-29");
                      send(_transferEntity);
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              );
            } else {
              return ElevatedButton(
                onPressed: () {
                  final _transferEntity = TransferEntity(
                      nameEffective: "Transfer Entity 5",
                      codeEffective: "TE005",
                      originBuild: "Origin Building I",
                      targetBuild: "Target Building J",
                      status: "Pending",
                      date: "2023-05-29");
                  send(_transferEntity);
                },
                child: const Text('Enviar Transferência'),
              );
            }
          },
        ),
      ),
    );
  }
}
