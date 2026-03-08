import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorkoutInput extends StatefulWidget {
  final String label;
  // Controller is now optional. The widget will create one if not provided.
  final TextEditingController? controller;
  // Callback to return the parsed double value
  final ValueChanged<double?>? onChanged;

  const WorkoutInput({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
  });

  @override
  State<WorkoutInput> createState() => _WorkoutInputState();
}

class _WorkoutInputState extends State<WorkoutInput> {
  // --- STATE ---
  late final TextEditingController _controller;
  late final bool _ownsController;
  String? _errorText;
  // ---

  @override
  void initState() {
    super.initState();
    // 1. Check if a controller was passed in
    _ownsController = widget.controller == null;
    // 2. Use the passed-in controller or create a new one
    _controller = widget.controller ?? TextEditingController();

    // 3. Add a listener to handle validation and callbacks
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    // 4. Remove the listener
    _controller.removeListener(_handleTextChanged);
    // 5. Dispose the controller ONLY if this widget created it
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      // Clear error and send null back
      setState(() => _errorText = null);
      widget.onChanged?.call(null);
      return;
    }

    final value = double.tryParse(text);
    if (value == null) {
      // Set error and send null back
      setState(() => _errorText = 'Invalid');
      widget.onChanged?.call(null);
    } else {
      // Clear error and send the valid double
      if (_errorText != null) setState(() => _errorText = null);
      widget.onChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access properties from the "StatefulWidget" using "widget."
    return Card(
      color: Colors.blue,
      margin: const EdgeInsets.symmetric(vertical: 8), 
                    // Adjusted margin
    
   
      child: Padding(
        padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.label, // Use "widget.label"
              style: const TextStyle(
                color: Color.fromARGB(255, 235, 236, 239),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 110, // Increased width to fit 'kg' and error
            child: TextField(
              
              controller: _controller, // Use the internal _controller
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                // Allow digits and an optional single decimal point
                FilteringTextInputFormatter.allow(RegExp(r'\d*\.?\d*')),
              ],
              style: const TextStyle(color: Color.fromARGB(255, 108, 126, 243)),
              decoration: InputDecoration(
                 filled: true,
                 fillColor: Colors.transparent,

                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,

                ),
                hintText: '0',
                hintStyle: const TextStyle(color: Colors.white38),
                suffixText: 'kg', // Using suffixText is often better
                suffixStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                errorText: _errorText, // Show validation error
                errorStyle: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 10,
                ), // Custom error style
              ),
              cursorColor: const Color.fromARGB(255, 104, 121, 253),
            ),
          ),
        ],
      ),
    )
    );
  }
}
