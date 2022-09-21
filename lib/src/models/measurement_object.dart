import 'package:uuid/uuid.dart';

class MeasurementObject {
  String namePessoa;
  String pessoaId;
  String rg;
  String localName;
  String localId;
  String typeServiceName;
  String typeServiceId;
  String serviceName;
  String serviceId;
  int cp115;
  String unidadeName;
  String unidadeId;
  int qte_consumida;
  double valor_unitario;
  double total;
  String eliminar = "false";
  String id = Uuid().v4();

  @override
  String toString() {
    // TODO: implement toString
    return '{nome $namePessoa pessoa $pessoaId rg $rg local $localName idlocal $localId typeService $typeServiceName typeServiceid $typeServiceId service $serviceName serviceId $serviceId 115 $cp115 unidade $unidadeName unidadeId $unidadeId quantidade $qte_consumida valor unitario $valor_unitario total $total eliminar $eliminar id $id}';
  }
}
