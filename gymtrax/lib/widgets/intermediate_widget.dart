import 'package:flutter/material.dart';

class IntermediateWidget extends StatefulWidget {
  final String label;
  final double startingValue;

  const IntermediateWidget({
    super.key,
    required this.label,
    required this.startingValue,
  });

  @override
  State<IntermediateWidget> createState() => _IntermediateWidgetState();
}

class _IntermediateWidgetState extends State<IntermediateWidget> {
  double currentWeight = 0.0;
  double selectedIncrement = 0.0;
  bool? _successfulLift;

  @override
  void initState() {
    super.initState();
    currentWeight = widget.startingValue;
  }

  void _updateValue() {
    if (_successfulLift == true) {
      setState(() {
        currentWeight += selectedIncrement;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PR updated to ${currentWeight.toStringAsFixed(1)} kg!',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildIncrementButton(double value) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedIncrement = value;
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

              const Text('kg', style: TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Successful lift?',
            style: TextStyle(color: Colors.white70, fontSize: 16),
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
        ],
      ),
    );
  }
}
