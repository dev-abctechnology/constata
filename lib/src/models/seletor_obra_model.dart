class ObraSeletor {
  String id;
  String name;

  ObraSeletor({this.id, this.name});

  ObraSeletor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['data']['tb01_cp002'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
