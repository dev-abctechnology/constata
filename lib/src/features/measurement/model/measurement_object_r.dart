import 'package:constata_0_0_2/src/features/measurement/model/measurement_model.dart';

import '../../../shared/seletor_model.dart';

class MeasurementAppointment {
  MeasurementBody data;
  String ckc = 'CONPROD001';
  String cko = '000000000000000000';

  MeasurementAppointment({this.data});

  MeasurementAppointment.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? MeasurementBody.fromJson(json['data']) : null;
    ckc = json['ckc'];
    cko = json['cko'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['ckc'] = ckc;
    data['cko'] = cko;
    return data;
  }
}

class MeasurementBody {
  String type = "MEDI";
  String code;
  String description;
  List<MeasurementModel> measurements;
  String company;
  String address;
  Seletor nameBuild;
  String date;
  String responsible;
  String segment;

  MeasurementBody(
      {this.type,
      this.code,
      this.description,
      this.measurements,
      this.company,
      this.address,
      this.nameBuild,
      this.date,
      this.responsible,
      this.segment});

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
        json['h0_cp007'] != null ? Seletor.fromJson(json['h0_cp007']) : null;
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
