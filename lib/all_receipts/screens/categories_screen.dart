import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scan_flutter/all_receipts/transactions_bloc/transactions_bloc.dart';
import 'package:smart_scan_flutter/utils/app_functions.dart';

import '../../db/database_helper.dart';

const Map<ReceiptCategory, Color> categoryColors = {
  ReceiptCategory.groceries: Color(0xFF4C8EF9),
  ReceiptCategory.foodDining: Color(0xFFFFCC00),
  ReceiptCategory.transportation: Color(0xFF34C759),
  ReceiptCategory.utilities: Color(0xFFFF3B30),
  ReceiptCategory.housing: Color(0xFF5856D6),
  ReceiptCategory.entertainment: Color(0xFF007AFF),
  ReceiptCategory.health: Color(0xFF17C3B2),
  ReceiptCategory.services: Color(0xFFC97B8F),
  ReceiptCategory.shopping: Color(0xFFFF9500),
  ReceiptCategory.travel: Color(0xFFE55C00),
  ReceiptCategory.general: Color(0xFF6E6E6E),
};

class CategoryChart extends StatelessWidget {
  final List<Receipt> receipts;

  const CategoryChart({super.key, required this.receipts});

  List<PieChartSectionData> _prepareChartData(
    double grandTotal,
    double radius,
  ) {
    final Map<ReceiptCategory, double> categoryTotals = {};

    for (var receipt in receipts) {
      categoryTotals.update(
        receipt.category,
        (existingTotal) => existingTotal + receipt.totalAmount,
        ifAbsent: () => receipt.totalAmount,
      );
    }

    final sortedTotals =
        categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTotals.map((entry) {
      final category = entry.key;
      final total = entry.value;
      final percentage = total / grandTotal;
      final color =
          categoryColors[category] ?? categoryColors[ReceiptCategory.general]!;

      return PieChartSectionData(
        color: color,
        value: total,
        title: "${(percentage * 100).toStringAsFixed(0)}%",
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 2)],
        ),
        showTitle: percentage > 0.04,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = receipts.fold(
      0.0,
      (sum, item) => sum + item.totalAmount,
    );

    if (grandTotal == 0.0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            "No transaction data to generate category chart.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final chartSize = isPortrait ? 130.0 : 160.0;
    const double radius = 25;

    final sections = _prepareChartData(grandTotal, radius);

    final legendEntries =
        sections.map((section) {
          final category =
              categoryColors.entries
                  .firstWhere(
                    (entry) => entry.value == section.color,
                    orElse:
                        () => MapEntry(
                          ReceiptCategory.general,
                          categoryColors[ReceiptCategory.general]!,
                        ),
                  )
                  .key;
          return {
            "category": category,
            "value": section.value,
            "percentage": section.value / grandTotal,
            "color": section.color,
          };
        }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: chartSize / 3.5,
                          startDegreeOffset: 270,
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 4,
                          pieTouchData: PieTouchData(enabled: false),
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "\$${grandTotal.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: chartSize / 7.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Total",
                            style: TextStyle(fontSize: chartSize / 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        legendEntries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: entry["color"] as Color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          capitalize(
                                            (entry["category"]
                                                    as ReceiptCategory)
                                                .name,
                                          ),
                                          style: TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${((entry["percentage"] as double) * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

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

        final receipts = state.allReceipts;

        if (receipts.isEmpty) {
          return const Center(
            child: Text(
              "No transactions found to analyze categories.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return CategoryChart(receipts: receipts);
      },
    );
  }
}
