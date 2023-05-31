class EffectiveApointment {
  late DataBody data;
  String ckc = 'CONPROD001';
  String cko = '000000000000000000';

  EffectiveApointment({required this.data});

  EffectiveApointment.fromJson(Map<String, dynamic> json) {
    data = (json["data"] == null ? null : DataBody.fromJson(json["data"]))!;
    ckc = json["ckc"];
    cko = json["cko"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["data"] = this.data.toJson();
    data["ckc"] = ckc;
    data["cko"] = cko;
    return data;
  }
}

class DataBody {
  String type = "EFET";
  late String? code;
  late String description;
  late String datetime;
  late CompanyName companyName;
  late BuildName buildName;
  late String address;
  late String segment;
  late String pointer;
  late String effectiveTotalQuantity;
  late String quantityPresentes;
  late List<Effective> effective;

  DataBody({
    required this.type,
    required this.code,
    required this.description,
    required this.datetime,
    required this.companyName,
    required this.buildName,
    required this.address,
    required this.segment,
    required this.pointer,
    required this.effectiveTotalQuantity,
    required this.quantityPresentes,
    required this.effective,
  });

  DataBody.fromJson(Map<String, dynamic> json) {
    type = json["h0_cp002"];
    code = json["h0_cp003"];
    description = json["h0_cp004"];
    datetime = json["h0_cp008"];
    companyName = (json["h0_cp005"] == null
        ? null
        : CompanyName.fromJson(json["h0_cp005"]))!;
    buildName = (json["h0_cp013"] == null
        ? null
        : BuildName.fromJson(json["h0_cp013"]))!;
    address = json["h0_cp006"];
    segment = json["h0_cp015"];
    pointer = json["h0_cp009"];
    effectiveTotalQuantity = json["h0_cp010"];
    quantityPresentes = json["h0_cp011"];
    effective = (json["tb01_cp011"] == null
        ? null
        : (json["tb01_cp011"] as List)
            .map((e) => Effective.fromJson(e))
            .toList())!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["h0_cp002"] = type;
    data["h0_cp003"] = null;
    data["h0_cp004"] = description;
    data["h0_cp008"] = datetime;
    data["h0_cp005"] = companyName.toJson();
    data["h0_cp013"] = buildName.toJson();
    data["h0_cp006"] = address;
    data["h0_cp015"] = segment;
    data["h0_cp009"] = pointer;
    data["h0_cp010"] = effectiveTotalQuantity;
    data["h0_cp011"] = quantityPresentes;
    data["tb01_cp011"] = effective.map((e) => e.toJson()).toList();
    return data;
  }
}

class Effective {
  late String effectiveCode;
  late String effectiveName;
  late String effectiveFixed;
  late String effectiveStatus;
  late String id;

  Effective(
      {required this.effectiveCode,
      required this.effectiveName,
      required this.effectiveFixed,
      required this.effectiveStatus,
      required this.id});

  Effective.fromJson(Map<String, dynamic> json) {
    effectiveCode = json["tp_cp012"];
    effectiveName = json["tp_cp013"];
    effectiveFixed = json["tp_cp014"];
    effectiveStatus = json["tp_cp015"];
    id = json["_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["tp_cp012"] = effectiveCode;
    data["tp_cp013"] = effectiveName;
    data["tp_cp014"] = effectiveFixed;
    data["tp_cp015"] = effectiveStatus;
    data["_id"] = id;
    return data;
  }
}

class BuildName {
  late String name;
  late String id;

  BuildName({
    required this.name,
    required this.id,
  });

  BuildName.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    id = json["_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["name"] = name;
    data["_id"] = id;
    return data;
  }
}

class CompanyName {
  late String name;
  late String id;

  CompanyName({
    required this.name,
    required this.id,
  });

  CompanyName.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    id = json["id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["name"] = name;
    data["_id"] = id;
    return data;
  }
}
