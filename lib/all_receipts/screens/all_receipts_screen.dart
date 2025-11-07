import 'package:flutter/material.dart';
import 'package:smart_scan_flutter/all_receipts/screens/categories_screen.dart';
import 'package:smart_scan_flutter/all_receipts/screens/transactions_screen.dart';
import 'package:smart_scan_flutter/all_receipts/screens/vendors_screen.dart';
import 'package:intl/intl.dart';
import 'package:smart_scan_flutter/utils/app_functions.dart';

enum ViewSegment { transactions, categories, vendors }

enum FilterPreset { custom, last3Months, last6Months, allTime }

class AllReceiptsScreen extends StatefulWidget {
  const AllReceiptsScreen({super.key});

  @override
  State<AllReceiptsScreen> createState() => _AllReceiptsScreenState();
}

class _AllReceiptsScreenState extends State<AllReceiptsScreen> {
  ViewSegment _selectedSegment = ViewSegment.transactions;

  FilterPreset _selectedPreset = FilterPreset.allTime; // Default to All Time
  late DateTime _filterStartDate;
  late DateTime _filterEndDate;
  bool _isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    _setDefaultFilter();
    _checkIfFilterIsApplied();
  }

  void _setDefaultFilter() {
    _selectedPreset = FilterPreset.allTime;
    _filterStartDate = DateTime(2000, 1, 1);
    _filterEndDate = DateTime.now(); // Up to the current moment
  }

  void _checkIfFilterIsApplied() {
    setState(() {
      _isFilterApplied = _selectedPreset != FilterPreset.allTime;
    });
  }

  void _calculateDateRange(FilterPreset preset) {
    final now = DateTime.now();
    // For calculating range, ensure end date is the end of the current day.
    _filterEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (preset) {
      case FilterPreset.custom:
        // Dates are set directly during selection
        break;
      case FilterPreset.last3Months:
        // 3 months ago, starting from the 1st of that month
        _filterStartDate = DateTime(now.year, now.month - 2, 1);
        break;
      case FilterPreset.last6Months:
        // 6 months ago, starting from the 1st of that month
        _filterStartDate = DateTime(now.year, now.month - 5, 1);
        break;
      case FilterPreset.allTime:
        _filterStartDate = DateTime(2000, 1, 1);
        break;
    }
  }

  void _showFilterSheet() {
    FilterPreset tempPreset = _selectedPreset;
    DateTime tempStartDate = _filterStartDate;
    DateTime tempEndDate = _filterEndDate;

    if (tempPreset != FilterPreset.custom) {
      _calculateDateRange(tempPreset);
      tempStartDate = _filterStartDate;
      tempEndDate = _filterEndDate;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> _selectDate(BuildContext context, bool isStart) async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: isStart ? tempStartDate : tempEndDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );

              if (picked != null) {
                setModalState(() {
                  tempPreset = FilterPreset.custom;
                  if (isStart) {
                    tempStartDate = picked;
                    if (tempStartDate.isAfter(tempEndDate)) {
                      tempEndDate = tempStartDate;
                    }
                  } else {
                    tempEndDate = picked;
                    if (tempEndDate.isBefore(tempStartDate)) {
                      tempStartDate = tempEndDate;
                    }
                  }
                });
              }
            }

            // Helper to build a filter radio option in the sheet
            Widget _buildFilterOption(
              FilterPreset value,
              String title, [
              Widget? customContent,
            ]) {
              final isSelected = value == tempPreset;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(title),
                    leading: Radio<FilterPreset>(
                      value: value,
                      groupValue: tempPreset,
                      onChanged: (FilterPreset? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            tempPreset = newValue;
                            if (newValue != FilterPreset.custom) {
                              // Recalculate dates based on the new preset selection
                              _calculateDateRange(newValue);
                              tempStartDate = _filterStartDate;
                              tempEndDate = _filterEndDate;
                            }
                          });
                        }
                      },
                    ),
                    onTap: () {
                      setModalState(() {
                        tempPreset = value;
                        if (value != FilterPreset.custom) {
                          _calculateDateRange(value);
                          tempStartDate = _filterStartDate;
                          tempEndDate = _filterEndDate;
                        }
                      });
                    },
                  ),
                  if (isSelected && customContent != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: customContent,
                    ),
                ],
              );
            }

            // Helper to build the individual date row for the custom filter
            Widget _buildDateRow(
              BuildContext context,
              String label,
              DateTime date,
              VoidCallback onTap,
            ) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: onTap,
                      child: Row(
                        children: [
                          Text(
                            DateFormat('d MMMM yyyy').format(date),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Filter",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),

                  // Custom Date Range Selector
                  _buildFilterOption(
                    FilterPreset.custom,
                    "Custom Date",
                    Column(
                      children: [
                        _buildDateRow(
                          context,
                          "Start Date",
                          tempStartDate,
                          () => _selectDate(context, true),
                        ),
                        _buildDateRow(
                          context,
                          "End Date",
                          tempEndDate,
                          () => _selectDate(context, false),
                        ),
                      ],
                    ),
                  ),

                  // Preset Options
                  _buildFilterOption(FilterPreset.last3Months, "Last 3 Months"),
                  _buildFilterOption(FilterPreset.last6Months, "Last 6 Months"),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Apply the 'All Time' filter
                            _applyFilter(
                              FilterPreset.allTime,
                              DateTime(2000, 1, 1),
                              DateTime.now(),
                            );
                            Navigator.pop(context); // Close sheet
                          },
                          child: const Text("Clear filter"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Apply changes and close sheet
                            _applyFilter(
                              tempPreset,
                              tempStartDate,
                              tempEndDate,
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text("Apply filter"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _applyFilter(FilterPreset preset, DateTime startDate, DateTime endDate) {
    // Only update if the selection has actually changed
    if (_selectedPreset != preset ||
        !_filterStartDate.isAtSameMomentAs(startDate) ||
        !_filterEndDate.isAtSameMomentAs(endDate)) {
      setState(() {
        _selectedPreset = preset;
        _filterStartDate = startDate;
        _filterEndDate = endDate;

        if (preset != FilterPreset.custom) {
          _calculateDateRange(preset);
        }

        _checkIfFilterIsApplied();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Filter Applied: ${capitalize(preset.name)}"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Receipts"),
        actions: [
          // Filter Icon with Badge
          Stack(
            children: [
              IconButton(
                onPressed: _showFilterSheet,
                icon: const Icon(Icons.filter_list),
              ),
              if (_isFilterApplied)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Center(
            child: SegmentedButton<ViewSegment>(
              segments: const <ButtonSegment<ViewSegment>>[
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
          ),

          // Removed the permanent "Filtering by:" text
          const SizedBox(height: 24),

          Expanded(child: _buildContentForSegment(_selectedSegment)),
        ],
      ),
    );
  }

  Widget _buildContentForSegment(ViewSegment segment) {
    final DateTime endDate = DateTime(
      _filterEndDate.year,
      _filterEndDate.month,
      _filterEndDate.day,
      23,
      59,
      59,
      999,
    );

    switch (segment) {
      case ViewSegment.transactions:
        return TransactionsScreen(
          startDate: _filterStartDate,
          endDate: endDate,
        );
      case ViewSegment.categories:
        return CategoriesScreen();
      case ViewSegment.vendors:
        return VendorsScreen();
    }
  }
}
