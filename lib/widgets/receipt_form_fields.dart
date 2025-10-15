import 'package:flutter/material.dart';

/// A reusable widget that renders and manages the consistency of the receipt data fields.
/// This includes handling date picking and consistent amount formatting.
class ReceiptFormFields extends StatefulWidget {
  final Map<String, TextEditingController> controllers;
  final Function(String key, String value)? onFieldChanged;

  const ReceiptFormFields({
    super.key,
    required this.controllers,
    this.onFieldChanged,
  });

  @override
  State<ReceiptFormFields> createState() => _ReceiptFormFieldsState();
}

class _ReceiptFormFieldsState extends State<ReceiptFormFields> {
  static const String _defaultCurrencySymbol = '\$';

  // Helper to format date as MM/DD/YYYY
  String _formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
  }

  // Method to open the DatePicker dialog
  Future<void> _selectDate(BuildContext context, String key) async {
    final controller = widget.controllers[key]!;

    // Attempt to parse the current text, falling back to today if parsing fails
    DateTime initialDate;
    try {
      // Basic conversion attempt for MM/DD/YYYY to a parsable format
      final parts = controller.text.split("/");
      if (parts.length == 3) {
        // Rearrange to YYYY-MM-DD for reliable parsing
        initialDate =
            DateTime.tryParse("${parts[2]}-${parts[0]}-${parts[1]}") ??
            DateTime.now();
      } else {
        initialDate = DateTime.now();
      }
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && mounted) {
      setState(() {
        final newDate = _formatDate(picked);
        controller.text = newDate;
        // Notify parent if a change handler is provided
        widget.onFieldChanged?.call(key, newDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children:
          widget.controllers.entries.map((entry) {
            final key = entry.key;
            final controller = entry.value;
            final isAmountField = key.toLowerCase().contains("amount");
            final isDateField = key == "Date";

            // Dynamic Decoration
            InputDecoration decoration = InputDecoration(
              labelText: key,
              border: const OutlineInputBorder(),
              suffixIcon:
                  isDateField
                      ? const Icon(Icons.calendar_today)
                      : const Icon(Icons.edit),
            );

            if (isAmountField) {
              // Display currency symbol as a non-editable prefix
              decoration = decoration.copyWith(
                prefixText: "$_defaultCurrencySymbol ",
                prefixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: controller,
                decoration: decoration,
                readOnly: isDateField,
                onTap: isDateField ? () => _selectDate(context, key) : null,
                keyboardType:
                    isAmountField ? TextInputType.number : TextInputType.text,
                onChanged: (value) {
                  widget.onFieldChanged?.call(key, value);
                },
              ),
            );
          }).toList(),
    );
  }
}
