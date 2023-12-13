import 'dart:convert';

import 'package:flutter/foundation.dart';

class TransferEntity {
  late String? id;
  late String? innerId;
  late String? nameEffective;
  late String? codeEffective;
  late String? originBuild;
  late String? originBuildId;
  late String? targetBuild;
  late String? targetBuildId;
  late String? status;
  late String? date;

  TransferEntity({
    this.id,
    this.innerId,
    this.nameEffective,
    this.codeEffective,
    this.originBuild,
    this.originBuildId,
    this.targetBuild,
    this.targetBuildId,
    this.status,
    this.date,
  });

  TransferEntity.fromMap(Map<String, dynamic> map) {
    debugPrint(jsonEncode(map));

    //{"id":"6470d5dd7b7191235cd59645","ckc":null,"cko":null,"createdBy":null,"created":"2023-05-26T16:06:41.195+0000","deleted":false,"lastUpdate":"2023-05-26T16:06:41.195+0000","lastUpdateBy":null,"data":{"tb01_cp001":"-00004","tb01_cp002":"26/05/2023","tb01_cp003":{"name":"ADAILTON NARCISO PEREIRA","_id":"6321dc967b7191293e5dfb68"},"tb01_cp004":{"name":"AGE 360","_id":"61b9f0382212ef074ca781e9"},"tb01_cp005":{"name":"ALBA","_id":"6258507f2212ef0f8843f37e"},"tb01_cp006":"Aguardando"}}
    id = map['id'];
    innerId = map['data']['tb01_cp001'];
    nameEffective = map['data']['tb01_cp003']['name'];
    codeEffective = map['data']['tb01_cp003']['_id'];
    originBuild = map['data']['tb01_cp004']['name'];
    originBuildId = map['data']['tb01_cp004']['_id'];
    targetBuild = map['data']['tb01_cp005']['name'];
    targetBuildId = map['data']['tb01_cp005']['_id'];
    status = map['data']['tb01_cp006'];
    date = map['data']['tb01_cp002'];
  }

  Map<String, dynamic> toMap() {
    // {"data":{"tb01_cp001":null,"tb01_cp002":"26/05/2023","tb01_cp003":{"name":"ADAILTON NARCISO PEREIRA","_id":"6321dc967b7191293e5dfb68"},"tb01_cp004":{"name":"AGE 360","_id":"61b9f0382212ef074ca781e9"},"tb01_cp005":{"name":"ALBA","_id":"6258507f2212ef0f8843f37e"},"tb01_cp006":"Aguardando"},"ckc":"CONPROD001","cko":"000000000000000000"}

    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tb01_cp001'] = innerId;
    data['tb01_cp002'] = date;
    data['tb01_cp003'] = {"name": nameEffective, "_id": codeEffective};
    data['tb01_cp004'] = {"name": originBuild, "_id": originBuildId};
    data['tb01_cp005'] = {"name": targetBuild, "_id": targetBuildId};
    data['tb01_cp006'] = status;
    return data;
  }

  // copywith

  TransferEntity.copyWith({
    String? id,
    String? innerId,
    String? nameEffective,
    String? codeEffective,
    String? originBuild,
    String? originBuildId,
    String? targetBuild,
    String? targetBuildId,
    String? status,
    String? date,
  }) {
    TransferEntity(
      id: id ?? this.id,
      innerId: innerId ?? this.innerId,
      nameEffective: nameEffective ?? this.nameEffective,
      codeEffective: codeEffective ?? this.codeEffective,
      originBuild: originBuild ?? this.originBuild,
      originBuildId: originBuildId ?? this.originBuildId,
      targetBuild: targetBuild ?? this.targetBuild,
      targetBuildId: targetBuildId ?? this.targetBuildId,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    //{"data":{"tb01_cp001":null,"tb01_cp002":"26/05/2023","tb01_cp003":{"name":"ADAILTON NARCISO PEREIRA","_id":"6321dc967b7191293e5dfb68"},"tb01_cp004":{"name":"AGE 360","_id":"61b9f0382212ef074ca781e9"},"tb01_cp005":{"name":"ALBA","_id":"6258507f2212ef0f8843f37e"},"tb01_cp006":"Aguardando"},"ckc":"CONPROD001","cko":"000000000000000000"}
    return '{"data":{"tb01_cp001":null,"tb01_cp002":"$date","tb01_cp003":{"name":"$nameEffective","_id":"$codeEffective"},"tb01_cp004":{"name":"$originBuild","_id":"$originBuildId"},"tb01_cp005":{"name":"$targetBuild","_id":"$targetBuildId"},"tb01_cp006":"$status"},"ckc":"CONPROD001","cko":"000000000000000000"}';
  }
}
