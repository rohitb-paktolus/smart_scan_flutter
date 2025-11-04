import 'package:flutter/material.dart';

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
        return const Center(
          child: Text(
            'Displaying Transaction List',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      case ViewSegment.categories:
        return const Center(
          child: Text(
            'Displaying Categories View',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      case ViewSegment.vendors:
        return const Center(
          child: Text(
            'Displaying Vendor List',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
    }
  }
}
