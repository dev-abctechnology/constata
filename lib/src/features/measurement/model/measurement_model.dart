import 'package:uuid/uuid.dart' as uuid;

import '../../../shared/seletor_model.dart';

class MeasurementModel {
  late String namePerson;
  late String codePerson;
  late Seletor? local;
  late Seletor? sector;
  late Seletor? service;
  late Seletor? measurementUnit;
  late double unitValue;
  late double quantity;
  late double totalValue;
  late String observation;
  String sId = const uuid.Uuid().v4();

  MeasurementModel({
    required this.namePerson,
    required this.codePerson,
    required this.local,
    required this.sector,
    required this.service,
    required this.measurementUnit,
    required this.unitValue,
    required this.quantity,
    required this.totalValue,
    required this.observation,
  });

  MeasurementModel.fromJson(Map<String, dynamic> json) {
    namePerson = json['tp_cp052'];
    codePerson = json['tp_cp051'];
    local =
        json['tp_cp053'] != null ? Seletor.fromJson(json['tp_cp053']) : null;
    sector =
        json['tp_cp054'] != null ? Seletor.fromJson(json['tp_cp054']) : null;
    service =
        json['tp_cp055'] != null ? Seletor.fromJson(json['tp_cp055']) : null;
    measurementUnit =
        json['tp_cp056'] != null ? Seletor.fromJson(json['tp_cp056']) : null;
    unitValue = json['tp_cp057'];
    quantity = json['tp_cp058'];
    totalValue = json['tp_cp059'];
    observation = json['tp_cp060'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tp_cp052'] = namePerson;
    data['tp_cp051'] = codePerson;
    if (local != null) {
      data['tp_cp053'] = local!.toJson();
    }
    if (sector != null) {
      data['tp_cp054'] = sector!.toJson();
    }
    if (service != null) {
      data['tp_cp055'] = service!.toJson();
    }
    if (measurementUnit != null) {
      data['tp_cp056'] = measurementUnit!.toJson();
    }
    data['tp_cp057'] = unitValue;
    data['tp_cp058'] = quantity;
    data['tp_cp059'] = totalValue;
    data['tp_cp060'] = observation;
    data['_id'] = sId;
    return data;
  }
}
