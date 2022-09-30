import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeasurementCard extends StatefulWidget {
  bool editing = true;
  MeasurementCard({Key key, this.jsonBody, this.callback, this.editing})
      : super(key: key);
  Map jsonBody;
  final VoidCallback callback;
  @override
  _MeasurementCard createState() => _MeasurementCard();
}

class _MeasurementCard extends State<MeasurementCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        leading: Icon(Icons.handyman),
        title: Text(widget.jsonBody["tp_cp052"]),
        subtitle: Text('Local: ' +
            widget.jsonBody["tp_cp053"]["name"] +
            '\nSetor: ' +
            widget.jsonBody["tp_cp054"]["name"] +
            '\nTarefa: ' +
            widget.jsonBody["tp_cp055"]["name"]),
        trailing: Icon(Icons.search),
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: MeasurementeDetails(
                      details: widget.jsonBody, editing: widget.editing),
                );
              }).then((value) => {
                if (value != null && value) {widget.callback()}
              });
        },
      ),
    );
  }
}

class MeasurementeDetails extends StatefulWidget {
  bool editing;
  MeasurementeDetails({Key key, this.details, this.editing}) : super(key: key);
  Map details;
  @override
  _MeasurementeDetailsState createState() => _MeasurementeDetailsState();
}

List<Widget> buildButton(editing, context) {
  
  if (editing) {
    return [
      ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.red),
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Icon(Icons.delete_forever)),
      ElevatedButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Icon(Icons.arrow_back)),
    ];
  } else {
    return [
      Center(
          child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context, false);
        },
        child: Text('voltar'),
      ))
    ];
  }
}

class _MeasurementeDetailsState extends State<MeasurementeDetails> {
  @override
  Widget build(BuildContext context) {
    print(widget.details);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.details["tp_cp052"],
              style: TextStyle(fontSize: 16),
            ),
            Container(
              child: RichText(
                  text: TextSpan(
                      text: '',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                    TextSpan(text: widget.details["tp_cp051"].toString())
                  ])),
            ),
            Divider(color: Colors.black12, thickness: 2),
            ListTile(
              leading: Column(
                children: [
                  Icon(Icons.map),
                  Text("Local"),
                ],
              ),
              title: Text(widget.details["tp_cp053"]["name"]),
            ),
            Divider(color: Colors.black12, thickness: 2),
            ListTile(
              leading: Column(
                children: [
                  Icon(Icons.run_circle_outlined),
                  Text("Setor"),
                ],
              ),
              title: Text(widget.details["tp_cp054"]["name"]),
            ),
            Divider(color: Colors.black12, thickness: 2),
            ListTile(
              leading: Column(
                children: [
                  Icon(Icons.handyman),
                  Text("Tarefa"),
                ],
              ),
              title: Text(widget.details["tp_cp055"]["name"]),
            ),
            Divider(color: Colors.black12, thickness: 2),
            Icon(Icons.account_balance),
            RichText(
                text: TextSpan(
                    text: '',
                    style: DefaultTextStyle.of(context).style,
                    children: [
                  TextSpan(
                      text: 'Quantidade: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: widget.details["tp_cp058"].toString())
                ])),
            RichText(
                text: TextSpan(
                    text: '',
                    style: DefaultTextStyle.of(context).style,
                    children: [
                  TextSpan(
                      text: 'Valor unitario: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'R\$ ' +
                          NumberFormat("#,##0.00", 'pt-Br')
                              .format(widget.details["tp_cp057"]))
                ])),
            RichText(
                text: TextSpan(
                    text: '',
                    style: DefaultTextStyle.of(context).style,
                    children: [
                  TextSpan(
                      text: 'Total: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'R\$ ' +
                          NumberFormat("#,##0.00", 'pt-Br')
                              .format(widget.details["tp_cp059"]))
                ])),
            Divider(color: Colors.black12, thickness: 2),
            Container(
              child: Column(
                children: [
                  Text('Observações:', style: TextStyle(fontWeight: FontWeight.bold,)),
                  Text(widget.details["tp_cp060"].toString(), style: TextStyle(fontSize: 20))
                ],
              )
            ),
            Divider(color: Colors.black12, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buildButton(widget.editing, context),
            )
          ],
        ),
      ),
    );
  }
}
