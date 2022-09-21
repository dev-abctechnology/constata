import 'package:flutter/material.dart';

class EpiAppointmentDetails extends StatefulWidget {
  var epiAppointment;

  EpiAppointmentDetails({Key key, this.epiAppointment}) : super(key: key);

  @override
  State<EpiAppointmentDetails> createState() => _EpiAppointmentDetailsState();
}

class _EpiAppointmentDetailsState extends State<EpiAppointmentDetails> {
  @override
  Widget build(BuildContext context) {
    var validated = widget.epiAppointment['data']['h0_cp056'] == null
        ? 'Não'
        : widget.epiAppointment['data']['h0_cp056'];

    List epis = widget.epiAppointment['data']['tb03_cp011'];

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.epiAppointment['data']['h0_cp013']}"),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            ListTile(
                title: Text(
                    "Funcionário: ${widget.epiAppointment['data']['h0_cp013']}")),
            ListTile(
                title:
                    Text("ID: ${widget.epiAppointment['data']['h0_cp014']}")),
            ListTile(title: Text("Validado: $validated")),
            Divider(),
            ListTile(title: Center(child: Text("Lista de EPIs"))),
            ListView.builder(
              shrinkWrap: true,
              itemCount: epis.isEmpty ? 0 : epis.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Text(epis[index]['tp_cp016'].toString()),
                    subtitle: Text(
                        'Motivo: ${epis[index]['tp_cp019']}\nQuantidade: ${epis[index]['tp_cp017']}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
