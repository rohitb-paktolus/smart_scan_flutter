import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scan_flutter/all_receipts/transactions_bloc/transactions_bloc.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import 'package:smart_scan_flutter/utils/route.dart';

/// Aggregates receipts by vendor and calculates total spending per vendor.
Map<String, double> _getVendorSpending(List<Receipt> receipts) {
  final Map<String, double> vendorTotals = {};

  for (final receipt in receipts) {
    vendorTotals.update(
      receipt.vendorName,
      (existingTotal) => existingTotal + receipt.totalAmount,
      ifAbsent: () => receipt.totalAmount,
    );
  }

  return vendorTotals;
}

class VendorsScreen extends StatelessWidget {
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Ensure transactions are loaded when this screen is viewed
    context.read<TransactionsBloc>().add(const TransactionsLoadAll());

    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        if (state is TransactionsLoading && state.allReceipts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TransactionsError) {
          return Center(child: Text("Error: ${state.message}"));
        }

        final receipts = state.allReceipts;

        if (receipts.isEmpty) {
          return const Center(
            child: Text(
              "No transactions found to analyze vendor spending.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final vendorTotals = _getVendorSpending(receipts);

        // Convert map to a sortable list of entries
        final sortedVendors =
            vendorTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final vendorEntry = sortedVendors[index];
                final vendorName = vendorEntry.key;
                final totalSpent = vendorEntry.value;

                // Get all receipts for this specific vendor
                final vendorReceipts =
                    receipts.where((r) => r.vendorName == vendorName).toList();

                return GestureDetector(
                  onTap: () {
                    // Navigate to the detail screen, similar to CategoryScreen
                    Navigator.of(context).pushNamed(
                      ROUTE_CATEGORY_DETAIL,
                      arguments: {
                        "categoryName": vendorName,
                        "receipts": vendorReceipts,
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        width: 1,
                        color: colorScheme.secondary,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(26),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Vendor Name and Icon
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Placeholder icon (could be expanded later)
                              const Icon(
                                Icons.storefront,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  vendorName,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Total Spent amount
                        Text(
                          "\$${totalSpent.toStringAsFixed(2)}",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),

                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: sortedVendors.length),
            ),
          ],
        );
      },
    );
  }
}
