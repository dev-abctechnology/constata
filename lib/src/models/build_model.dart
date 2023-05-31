import 'package:constata/src/shared/seletor_model.dart';

class Build {
  late List<Task>? tasks;

  Build({
    this.tasks,
  });

  Build.fromJson(Map<String, dynamic> json) {
    tasks = json["tb02_cp080"] == null
        ? null
        : (json["tb02_cp080"] as List).map((e) => Task.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};

    if (tasks != null) {
      _data["tb02_cp080"] = tasks!.map((e) => e.toJson()).toList();
    }

    return _data;
  }
}

class Task {
  late Seletor? local;
  late Seletor? sector;
  late Seletor? service;
  late double? budgetedQuantity;
  late Seletor? measureUnit;
  late double? unitaryValue;
  late double? valorOrcado;
  late double? quantidadeConsumida;
  late double? valorRealConsumido;
  late double? saldoQuantidade;
  late double? saldoValor;
  late double? mediaConsumida;
  late String id;

  Task(
      {required this.local,
      required this.sector,
      required this.service,
      required this.measureUnit,
      required this.budgetedQuantity,
      required this.unitaryValue,
      required this.valorOrcado,
      required this.quantidadeConsumida,
      required this.valorRealConsumido,
      required this.saldoQuantidade,
      required this.saldoValor,
      required this.mediaConsumida,
      required this.id});

  Task.fromJson(Map<String, dynamic> json) {
    local =
        json["tp_cp081"] == null ? null : Seletor.fromJson(json["tp_cp081"]);
    sector =
        json["tp_cp082"] == null ? null : Seletor.fromJson(json["tp_cp082"]);
    service =
        json["tp_cp083"] == null ? null : Seletor.fromJson(json["tp_cp083"]);
    measureUnit =
        json["tp_cp085"] == null ? null : Seletor.fromJson(json["tp_cp085"]);

    budgetedQuantity = json["tp_cp084"] == null
        ? null
        : double.tryParse(json["tp_cp084"].toString());
    unitaryValue = json["tp_cp086"] == null
        ? null
        : double.tryParse(json["tp_cp086"].toString());
    valorOrcado = json["tp_cp087"] == null
        ? null
        : double.tryParse(json["tp_cp087"].toString());

    quantidadeConsumida = json["tp_cp088"] == null
        ? null
        : double.tryParse(json["tp_cp088"].toString());
    valorRealConsumido = json["tp_cp089"] == null
        ? null
        : double.tryParse(json["tp_cp089"].toString());
    saldoQuantidade = json["tp_cp090"] == null
        ? null
        : double.tryParse(json["tp_cp090"].toString());
    saldoValor = json["tp_cp091"] == null
        ? null
        : double.tryParse(json["tp_cp091"].toString());
    mediaConsumida = json["tp_cp092"] == null
        ? null
        : double.tryParse(json["tp_cp092"].toString());
    id = json["_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if (local != null) {
      _data["tp_cp081"] = local!.toJson();
    }
    if (sector != null) {
      _data["tp_cp082"] = sector!.toJson();
    }
    if (service != null) {
      _data["tp_cp083"] = service!.toJson();
    }
    _data["tp_cp084"] = budgetedQuantity;
    if (measureUnit != null) {
      _data["tp_cp085"] = measureUnit!.toJson();
    }
    _data["tp_cp086"] = unitaryValue;
    _data["tp_cp087"] = valorOrcado;
    _data["tp_cp088"] = quantidadeConsumida;
    _data["tp_cp089"] = valorRealConsumido;
    _data["tp_cp090"] = saldoQuantidade;
    _data["tp_cp091"] = saldoValor;
    _data["tp_cp092"] = mediaConsumida;
    _data["_id"] = id;
    return _data;
  }
}

class Responsible {
  late String code;
  late String name;
  late String id;

  Responsible({
    required this.code,
    required this.name,
    required this.id,
  });

  Responsible.fromJson(Map<String, dynamic> json) {
    code = json["tp_cp009"];
    name = json["tp_cp010"];
    id = json["_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["tp_cp009"] = code;
    _data["tp_cp010"] = name;
    _data["_id"] = id;
    return _data;
  }
}
