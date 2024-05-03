
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadioButtonsField extends StatefulWidget {
  final String title;
  final List<dynamic> options;

  RadioButtonsField({required this.title, required this.options});

  @override
  _RadioButtonsFieldState createState() => _RadioButtonsFieldState();
}

class _RadioButtonsFieldState extends State<RadioButtonsField> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          Column(
            children: widget.options.map<Widget>((option) {
              return RadioListTile(
                title: Text(option.toString()),
                value: option.toString(),
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value.toString();
                  });
                  print('Selected option: $value');
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
