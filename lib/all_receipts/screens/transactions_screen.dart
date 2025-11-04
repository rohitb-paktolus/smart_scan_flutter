import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scan_flutter/all_receipts/transactions_bloc/transactions_bloc.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import 'package:smart_scan_flutter/utils/route.dart';

import '../../utils/app_functions.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  Future<bool> _confirmDismiss(BuildContext context, Receipt receipt) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Deletion?"),
          content: Text(
            "Are you sure you want to delete the receipt for \"${receipt.vendorName}\"",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    return shouldDelete ?? false;
  }

  void _onDeleteReceipt(BuildContext context, int receiptId) async {
    await DatabaseHelper.instance.deleteReceipt(receiptId);
    if (!context.mounted) return;
    context.read<TransactionsBloc>().add(const TransactionsLoadAll());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Receipt deleted."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onReceiptTap(BuildContext context, Receipt receipt) async {
    await Navigator.pushNamed(
      context,
      ROUTE_RECEIPT_DETAIL,
      arguments: receipt.id,
    );
    if (!context.mounted) return;
    context.read<TransactionsBloc>().add(const TransactionsLoadAll());
  }

  Widget _buildListTile({
    required BuildContext context,
    required Receipt receipt,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: () => _onReceiptTap(context, receipt),
        leading: const Icon(Icons.receipt, color: Colors.blue),
        title: Text(
          receipt.vendorName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Category: ${capitalize(receipt.category.name)} | Date: ${receipt.date}",
        ),
        trailing: Text(
          "\$${receipt.totalAmount.toStringAsFixed(2)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptsList(BuildContext context, List<Receipt> receipts) {
    return ListView.builder(
      itemCount: receipts.length,
      itemBuilder: (context, index) {
        final receipt = receipts[index];
        return Dismissible(
          key: Key(receipt.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          confirmDismiss: (direction) => _confirmDismiss(context, receipt),
          onDismissed: (direction) {
            if (receipt.id != null) {
              _onDeleteReceipt(context, receipt.id!);
            }
          },
          child: _buildListTile(context: context, receipt: receipt),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<TransactionsBloc>().add(const TransactionsLoadAll());

    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        if (state is TransactionsLoading && state.allReceipts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TransactionsError) {
          return Center(child: Text("Error: ${state.message}"));
        }

        if (state.allReceipts.isEmpty) {
          return const Center(
            child: Text(
              "No transactions found.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return _buildReceiptsList(context, state.allReceipts);
      },
    );
  }
}
