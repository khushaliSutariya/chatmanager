import 'package:flutter/material.dart';


class MyTextBox extends StatefulWidget {
  TextEditingController? controller;
  TextInputType? keybord;
  MyTextBox({required this.controller,required this.keybord});
  @override
  State<MyTextBox> createState() => _MyTextBoxState();
}

class _MyTextBoxState extends State<MyTextBox> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:widget.controller,
      keyboardType: widget.keybord,
      decoration: InputDecoration(border: OutlineInputBorder()),
    );
  }
}

