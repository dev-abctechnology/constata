import 'package:flutter/material.dart';

class ReportDetails extends StatefulWidget {
  final Map reportDetail;

  const ReportDetails({Key? key, required this.reportDetail}) : super(key: key);

  @override
  _ReportDetailsState createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  @override
  Widget build(BuildContext context) {
    List efetivo = widget.reportDetail['data']['tb01_cp011'];
    TextStyle style = const TextStyle(fontSize: 16);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do efetivo'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              ListTile(
                title: RichText(
                    text: TextSpan(text: '', style: style, children: [
                  const TextSpan(
                      text: 'Cod: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: widget.reportDetail['data']['h0_cp003'].toString())
                ])),
              ),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                const TextSpan(
                    text: 'Data: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp008']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                const TextSpan(
                    text: 'Obra: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: '${widget.reportDetail['data']['h0_cp013']['name']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                const TextSpan(
                    text: 'Local de Negócio: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp006']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                const TextSpan(
                    text: 'Segmento: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp015']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                const TextSpan(
                    text: 'Responsável: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp009']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                const TextSpan(
                    text: 'Qte Efetivos: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp010']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                const TextSpan(
                    text: 'Qte Presentes: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp011']}')
              ]))),
              const Divider(),
              Container(
                child: const Center(
                  child: Text('Lista de efetivo'),
                ),
              ),
              const Divider(color: Colors.transparent),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: efetivo.isEmpty ? 0 : efetivo.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        trailing: Text('${efetivo[index]['tp_cp015']}'),
                        title: Text('${efetivo[index]['tp_cp013']}'),
                        subtitle: Text('RG: ${efetivo[index]['tp_cp012']}'),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
