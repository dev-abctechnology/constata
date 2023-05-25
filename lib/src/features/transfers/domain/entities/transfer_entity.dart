class TransferEntity {
  String nameEffective;
  String codeEffective;
  String originBuild;
  String targetBuild;
  String status;
  String date;

  TransferEntity({
    this.nameEffective,
    this.codeEffective,
    this.originBuild,
    this.targetBuild,
    this.status,
    this.date,
  });

  TransferEntity.fromMap(Map<String, dynamic> json) {
    nameEffective = json['nameEffective'];
    codeEffective = json['codeEffective'];
    originBuild = json['originBuild'];
    targetBuild = json['targetBuild'];
    status = json['status'];
    date = json['date'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nameEffective'] = nameEffective;
    data['codeEffective'] = codeEffective;
    data['originBuild'] = originBuild;
    data['targetBuild'] = targetBuild;
    data['status'] = status;
    data['date'] = date;
    return data;
  }

  @override
  String toString() {
    return 'TransferEntity(nameEffective: $nameEffective, codeEffective: $codeEffective, originBuild: $originBuild, targetBuild: $targetBuild, status: $status, date: $date)';
  }
}
