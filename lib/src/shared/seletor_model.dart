class Seletor {
  late String name;
  late String sId;

  Seletor({
    required this.name,
    required this.sId,
  });

  Seletor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['_id'] = sId;
    return data;
  }
}
