class EffectiveApointment {
  DataBody data;
  String ckc = 'CONPROD001';
  String cko = '000000000000000000';

  EffectiveApointment({this.data});

  EffectiveApointment.fromJson(Map<String, dynamic> json) {
    data = json["data"] == null ? null : DataBody.fromJson(json["data"]);
    ckc = json["ckc"];
    cko = json["cko"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) data["data"] = this.data.toJson();
    data["ckc"] = ckc;
    data["cko"] = cko;
    return data;
  }
}

class DataBody {
  String type = "EFET";
  String code;
  String description;
  String datetime;
  CompanyName companyName;
  BuildName buildName;
  String address;
  String segment;
  String pointer;
  String morningQuantity;
  String afternoonQuantity;
  String deleted;
  List<Effective> effective;

  DataBody({
    this.type,
    this.code,
    this.description,
    this.datetime,
    this.companyName,
    this.buildName,
    this.address,
    this.segment,
    this.pointer,
    this.morningQuantity,
    this.afternoonQuantity,
    this.deleted,
    this.effective,
  });

  DataBody.fromJson(Map<String, dynamic> json) {
    type = json["h0_cp002"];
    code = json["h0_cp003"];
    description = json["h0_cp004"];
    datetime = json["h0_cp008"];
    companyName = json["h0_cp005"] == null
        ? null
        : CompanyName.fromJson(json["h0_cp005"]);
    buildName =
        json["h0_cp013"] == null ? null : BuildName.fromJson(json["h0_cp013"]);
    address = json["h0_cp006"];
    segment = json["h0_cp015"];
    pointer = json["h0_cp009"];
    morningQuantity = json["h0_cp010"];
    afternoonQuantity = json["h0_cp011"];
    deleted = json["f0_cp002"];
    effective = json["tb01_cp011"] == null
        ? null
        : (json["tb01_cp011"] as List)
            .map((e) => Effective.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["h0_cp002"] = type;
    data["h0_cp003"] = null;
    data["h0_cp004"] = description;
    data["h0_cp008"] = datetime;
    if (companyName != null) data["h0_cp005"] = companyName.toJson();
    if (buildName != null) data["h0_cp013"] = buildName.toJson();
    data["h0_cp006"] = address;
    data["h0_cp015"] = segment;
    data["h0_cp009"] = pointer;
    data["h0_cp010"] = morningQuantity;
    data["h0_cp011"] = afternoonQuantity;
    if (effective != null) {
      data["tb01_cp011"] = effective.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class Effective {
  String effectiveCode;
  String effectiveName;
  String effectiveFixed;
  String effectiveStatus;
  String id;

  Effective(
      {this.effectiveCode,
      this.effectiveName,
      this.effectiveFixed,
      this.effectiveStatus,
      this.id});

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
  String name;
  String id;

  BuildName({this.name, this.id});

  BuildName.fromJson(Map<String, dynamic> json) {
    name = json["data"]["tb01_cp002"] ?? json['h0_cp005']['name'];
    id = json["id"] ?? json['h0_cp005']['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["name"] = name;
    data["_id"] = id;
    return data;
  }
}

class CompanyName {
  String name;
  String id;

  CompanyName({this.name, this.id});

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
