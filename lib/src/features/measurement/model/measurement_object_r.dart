import 'package:constata/src/features/measurement/model/measurement_model.dart';

import '../../../shared/seletor_model.dart';

class MeasurementAppointment {
  late MeasurementBody data;
  String ckc = 'CONPROD001';
  String cko = '000000000000000000';

  MeasurementAppointment({required this.data});

  MeasurementAppointment.fromJson(Map<String, dynamic> json) {
    data =
        (json['data'] != null ? MeasurementBody.fromJson(json['data']) : null)!;
    ckc = json['ckc'];
    cko = json['cko'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data.toJson();
    data['ckc'] = ckc;
    data['cko'] = cko;
    return data;
  }
}

class MeasurementBody {
  late String type = "MEDI";
  late String? code;
  late String description = "Apontamento de Medição";
  late List<MeasurementModel> measurements;
  late String company;
  late String address;
  late Seletor nameBuild;
  late String date;
  late String responsible;
  late String segment;

  MeasurementBody(
      {required this.measurements,
      required this.company,
      required this.address,
      required this.nameBuild,
      required this.date,
      required this.responsible,
      required this.segment});

  MeasurementBody.fromJson(Map<String, dynamic> json) {
    type = json['h0_cp002'];
    code = json['h0_cp003'];
    description = json['h0_cp004'];
    if (json['tb01_cp050'] != null) {
      measurements = <MeasurementModel>[];
      json['tb01_cp050'].forEach((v) {
        measurements.add(MeasurementModel.fromJson(v));
      });
    }
    company = json['h0_cp005'];
    address = json['h0_cp006'];
    nameBuild =
        (json['h0_cp007'] != null ? Seletor.fromJson(json['h0_cp007']) : null)!;
    date = json['h0_cp008'];
    responsible = json['h0_cp009'];
    segment = json['h0_cp013'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['h0_cp002'] = type;
    data['h0_cp003'] = code;
    data['h0_cp004'] = description;
    if (measurements != null) {
      data['tb01_cp050'] = measurements.map((v) => v.toJson()).toList();
    }
    data['h0_cp005'] = company;
    data['h0_cp006'] = address;
    if (nameBuild != null) {
      data['h0_cp007'] = nameBuild.toJson();
    }
    data['h0_cp008'] = date;
    data['h0_cp009'] = responsible;
    data['h0_cp013'] = segment;
    return data;
  }
}
