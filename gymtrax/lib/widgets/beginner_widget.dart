import 'package:flutter/material.dart';

class BeginnerWidget extends StatefulWidget {
  final String label;
  final double startingValue;

  const BeginnerWidget({
    super.key,
    required this.label,
    required this.startingValue,
  });

  @override
  State<BeginnerWidget> createState() => _BeginnerWidgetState();
}

class _BeginnerWidgetState extends State<BeginnerWidget> {
  double totalIncrement = 0.0;
  bool? _successfulLift;
  double? prValue;

  @override
  void initState() {
    super.initState();
    prValue = widget.startingValue;
  }

  void _updateValue() {
    if (_successfulLift == true) {
      setState(() {
        final double currentWeight = widget.startingValue + totalIncrement;
        prValue = currentWeight;
        _successfulLift = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PR updated to ${prValue!.toStringAsFixed(1)} kg!'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildIncrementButton(double value) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          totalIncrement += value;
        });
      },
      child: Text(
        value.toString(),
        style: const TextStyle(
          color: Color.fromARGB(255, 90, 118, 245),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double currentWeight = widget.startingValue + totalIncrement;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 9, 18, 64),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.label}:',
            style: const TextStyle(
              color: Color.fromARGB(255, 90, 118, 245),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Increment by:',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(width: 12),
              _buildIncrementButton(2.5),
              const SizedBox(width: 8),
              _buildIncrementButton(5),
              const SizedBox(width: 12),
              const Text('kg', style: TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Successful lift?',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          RadioGroup<bool>(
            value: _successfulLift,
            onChanged: (value) {
              setState(() {
                _successfulLift = value;
              });
            },
            options: const [(true, 'Yes'), (false, 'No')],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _updateValue,
            child: const Text(
              'Update',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current: ${currentWeight.toStringAsFixed(1)} kg',
            style: const TextStyle(color: Colors.white60),
          ),
          Text(
            'PR: ${prValue!.toStringAsFixed(1)} kg',
            style: const TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class RadioGroup<T> extends StatelessWidget {
  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<(T, String)> options;

  const RadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final (optionValue, label) = option;
        final bool selected = optionValue == value;
        return InkWell(
          onTap: () => onChanged?.call(optionValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
