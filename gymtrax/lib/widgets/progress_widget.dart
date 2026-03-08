import 'package:flutter/material.dart';

class ProgressWidget extends StatefulWidget {
  final List<String> options;
  final String initialValue;
  final ValueChanged<String>? onChanged;

  const ProgressWidget({
    super.key,
    required this.options,
    required this.initialValue,
    this.onChanged,
  });

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      dropdownColor: Colors.grey,
      value: selectedValue,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      items: widget.options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        if (value != null && widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
    );
  }
}
