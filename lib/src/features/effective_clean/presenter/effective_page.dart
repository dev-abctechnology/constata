import 'package:constata/src/features/effective_clean/data/repositories/check_effective_repository.dart';
import 'package:constata/src/features/effective_clean/domain/usecases/check_effective_usecase_impl.dart';
import 'package:constata/src/features/effective_clean/external/datasources/check_effective_datasource.dart';
import 'package:constata/src/features/effective_clean/presenter/check_effective_controller.dart';
import 'package:constata/src/models/build_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class EffectiveClean extends StatefulWidget {
  const EffectiveClean({
    Key key,
  }) : super(key: key);

  @override
  State<EffectiveClean> createState() => _EffectiveCleanState();
}

class _EffectiveCleanState extends State<EffectiveClean> {
  final _controller = CheckEffectiveController(CheckEffectiveUseCaseImpl(
      CheckEffectiveRepositoryImpl(CheckEffectiveDataSourceImpl())));

  final ValueNotifier<DateTime> _date = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isError = ValueNotifier<bool>(false);

  _openDatePicker(BuildContext context) async {
    showDatePicker(
      context: context,
      initialDate: _date.value,
      firstDate: DateTime(2021),
      lastDate: DateTime(2030),
    ).then((value) {
      if (value != null) {
        _date.value = value;
        checkEffective();
      }
    });
  }

  checkEffective() async {
    _isLoading.value = true;
    _isError.value = false;
    try {
      final response = await _controller.checkEffective(_date.value);
      if (response == true) {
        _isLoading.value = false;
      } else {
        _isLoading.value = false;
        _isError.value = true;
      }
    } catch (e, s) {
      print(e);
      print(s);
      _isLoading.value = false;
      _isError.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Effective Clean'),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ValueListenableBuilder<bool>(
              valueListenable: _isError,
              builder: (context, isError, child) {
                if (isError) {
                  return const Center(
                    child: Text('Erro ao buscar efetivos'),
                  );
                } else {
                  return ValueListenableBuilder<DateTime>(
                    valueListenable: _date,
                    builder: (context, date, child) {
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Data: ${DateFormat('dd/MM/yyyy').format(date)}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _openDatePicker(context);
                                  },
                                  icon: const Icon(Icons.calendar_today),
                                ),
                              ],
                            ),
                          ),
                          if (_controller.effectiveApointments.isEmpty)
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Nenhum efetivo encontrado.',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          if (_controller.effectiveApointments.isNotEmpty)
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    _controller.effectiveApointments.length,
                                itemBuilder: (context, index) {
                                  final effectiveApointment =
                                      _controller.effectiveApointments[index];
                                  return ListTile(
                                      title: Text(
                                          '${effectiveApointment.data.buildName.name}'),
                                      subtitle: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: effectiveApointment
                                            .data.effective.length,
                                        itemBuilder: (context, index) {
                                          final effective = effectiveApointment
                                              .data.effective[index];
                                          return Text(
                                              '${effective.effectiveName} - ${effective.effectiveStatus}');
                                        },
                                      ));
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
