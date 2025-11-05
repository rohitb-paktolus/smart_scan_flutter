import 'package:flutter/material.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import 'package:smart_scan_flutter/widgets/receipt_list_tile.dart';

class CategoryDetail extends StatelessWidget {
  final String categoryName;
  final List<Receipt> receipts;

  const CategoryDetail({
    super.key,
    required this.categoryName,
    required this.receipts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: ListView.builder(
        itemCount: receipts.length,
        itemBuilder: (context, index) {
          final receipt = receipts[index];
          return ReceiptListTile(receipt: receipt);
        },
      ),
    );
  }
}
