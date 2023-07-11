import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantityForm extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  const QuantityForm({
    required this.hintText,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        validator: ((value) {
          if (value!.isEmpty) {
            return 'Preencha!';
          }
          return null;
        }),
        controller: controller,
        // keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
            hintText: hintText,
            disabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
            hintStyle: const TextStyle(fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red))),
      ),
    );
  }
}
