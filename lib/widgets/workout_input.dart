import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class WorkoutInput extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
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
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = null);
      widget.onChanged?.call(null);
      return;
    }

    final value = double.tryParse(text);
    if (value == null) {
      setState(() => _errorText = 'Invalid');
      widget.onChanged?.call(null);
    } else {
      if (_errorText != null) setState(() => _errorText = null);
      widget.onChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 20, 30, 80), // Deep Blue Card
        borderRadius: BorderRadius.circular(20),      // Smooth Corners
        border: Border.all(color: Colors.white10),    // Subtle Border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.2),


         // Standard opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. LABEL (Left Side)
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // 2. INPUT FIELD (Right Side)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.2),
                 // Darker inner box
                  borderRadius: BorderRadius.circular(12),
                  border: _errorText != null 
                      ? Border.all(color: Colors.redAccent) // Red border on error
                      : null,
                ),
                child: TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.cyan, // Glowing Text Color
                    fontSize: 20, 
                    fontWeight: FontWeight.bold
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "0.0",
                    hintStyle: TextStyle(color: Colors.white24),
                    suffixText: "kg",
                    suffixStyle: TextStyle(color: Colors.white38, fontSize: 14),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              // Error Text (Shows only if there is an error)
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}