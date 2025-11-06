import 'package:flutter/material.dart';
import 'package:smart_scan_flutter/all_receipts/screens/categories_screen.dart';
import 'package:smart_scan_flutter/all_receipts/screens/transactions_screen.dart';
import 'package:smart_scan_flutter/all_receipts/screens/vendors_screen.dart';

enum ViewSegment { transactions, categories, vendors }

class AllReceiptsScreen extends StatefulWidget {
  const AllReceiptsScreen({super.key});

  @override
  State<AllReceiptsScreen> createState() => _AllReceiptsScreenState();
}

class _AllReceiptsScreenState extends State<AllReceiptsScreen> {
  ViewSegment _selectedSegment = ViewSegment.transactions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Receipts")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),

            SegmentedButton(
              segments: <ButtonSegment<ViewSegment>>[
                ButtonSegment(
                  value: ViewSegment.transactions,
                  label: Text("Transactions"),
                ),
                ButtonSegment(
                  value: ViewSegment.categories,
                  label: Text("Categories"),
                ),
                ButtonSegment(
                  value: ViewSegment.vendors,
                  label: Text("Vendors"),
                ),
              ],
              selected: {_selectedSegment},
              onSelectionChanged: (Set<ViewSegment> newSelection) {
                setState(() {
                  _selectedSegment = newSelection.first;
                });
              },
              emptySelectionAllowed: false,
              multiSelectionEnabled: false,
              showSelectedIcon: false,
            ),

            const SizedBox(height: 40),

            Expanded(child: _buildContentForSegment(_selectedSegment)),
          ],
        ),
      ),
    );
  }

  Widget _buildContentForSegment(ViewSegment segment) {
    switch (segment) {
      case ViewSegment.transactions:
        return TransactionsScreen();
      case ViewSegment.categories:
        return CategoriesScreen();
      case ViewSegment.vendors:
        return VendorsScreen();
    }
  }
}
