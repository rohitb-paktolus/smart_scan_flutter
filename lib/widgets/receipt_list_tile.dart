import 'package:flutter/material.dart';

import '../db/database_helper.dart';

class ReceiptListTile extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback? onTap;

  const ReceiptListTile({super.key, required this.receipt, this.onTap});

  String capitalize(String text) =>
      text.isNotEmpty ? text[0].toUpperCase() + text.substring(1) : text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.receipt_long, color: Colors.blue),
        title: Text(
          receipt.vendorName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Category: ${capitalize(receipt.category.name)} | Date: ${receipt.date}",
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Text(
          "₹${receipt.totalAmount.toStringAsFixed(2)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
