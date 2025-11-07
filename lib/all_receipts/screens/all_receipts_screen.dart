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

  FilterPreset _selectedPreset = FilterPreset.custom;
  late DateTime _filterStartDate;
  late DateTime _filterEndDate;

  @override
  void initState() {
    super.initState();
    _setDefaultFilter();
  }

  void _setDefaultFilter() {
    final now = DateTime.now();
    _filterEndDate = DateTime(
      now.year,
      now.month + 1,
      1,
    ).subtract(Duration(days: 1));
    _filterStartDate = DateTime(now.year, now.month, 1);
  }

  void _calculateDateRange(FilterPreset preset) {
    final now = DateTime.now();
    _filterEndDate = DateTime(now.year, now.month, now.day);

    switch (preset) {
      case FilterPreset.custom:
        break;
      case FilterPreset.last3Months:
        _filterStartDate = DateTime(now.year, now.month - 2, 1);
        break;
      case FilterPreset.last6Months:
        _filterStartDate = DateTime(now.year, now.month - 5, 1);
        break;
      case FilterPreset.allTime:
        _filterStartDate = DateTime(2000, 1, 1);
        break;
    }
  }

  void _showFilterSheet() {
    // These variables are locally scoped to _showFilterSheet but are MODIFIED
    // within the setModalState callback, which triggers the rebuild.
    FilterPreset tempPreset = _selectedPreset;
    DateTime tempStartDate = _filterStartDate;
    DateTime tempEndDate = _filterEndDate;

    // Set tempDates if current preset is not custom, ensuring dates reflect
    // the current preset when the modal is first opened.
    if (tempPreset != FilterPreset.custom) {
      final now = DateTime.now();
      tempEndDate = DateTime(now.year, now.month, now.day);
      if (tempPreset == FilterPreset.last3Months) {
        tempStartDate = DateTime(now.year, now.month - 2, 1);
      } else if (tempPreset == FilterPreset.last6Months) {
        tempStartDate = DateTime(now.year, now.month - 5, 1);
      } else if (tempPreset == FilterPreset.allTime) {
        tempStartDate = DateTime(2000, 1, 1);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        // The key is that setModalState updates the variables defined
        // *outside* of the builder, but *inside* of _showFilterSheet.
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> _selectDate(BuildContext context, bool isStart) async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: isStart ? tempStartDate : tempEndDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
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
              final isSelected =
                  value ==
                  tempPreset; // Use the tempPreset from StateSetter's scope

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(title),
                    leading: Radio<FilterPreset>(
                      value: value,
                      groupValue: tempPreset,
                      // Use the tempPreset from StateSetter's scope
                      onChanged: (FilterPreset? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            // **FIX:** Directly update the shared tempPreset variable
                            tempPreset = newValue;
                            if (newValue != FilterPreset.custom) {
                              // Recalculate dates based on the new preset selection
                              final now = DateTime.now();
                              tempEndDate = DateTime(
                                now.year,
                                now.month,
                                now.day,
                              );
                              if (newValue == FilterPreset.last3Months) {
                                tempStartDate = DateTime(
                                  now.year,
                                  now.month - 2,
                                  1,
                                );
                              } else if (newValue == FilterPreset.last6Months) {
                                tempStartDate = DateTime(
                                  now.year,
                                  now.month - 5,
                                  1,
                                );
                              } else if (newValue == FilterPreset.allTime) {
                                tempStartDate = DateTime(2000, 1, 1);
                              }
                            }
                          });
                        }
                      },
                    ),
                    onTap: () {
                      setModalState(() {
                        // **FIX:** Directly update the shared tempPreset variable
                        tempPreset = value;
                        if (value != FilterPreset.custom) {
                          // Recalculate dates on tap as well
                          final now = DateTime.now();
                          tempEndDate = DateTime(now.year, now.month, now.day);
                          if (value == FilterPreset.last3Months) {
                            tempStartDate = DateTime(
                              now.year,
                              now.month - 2,
                              1,
                            );
                          } else if (value == FilterPreset.last6Months) {
                            tempStartDate = DateTime(
                              now.year,
                              now.month - 5,
                              1,
                            );
                          } else if (value == FilterPreset.allTime) {
                            tempStartDate = DateTime(2000, 1, 1);
                          }
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
                  _buildFilterOption(FilterPreset.allTime, "All Time"),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            _setDefaultFilter();
                            _applyFilter(
                              FilterPreset.last3Months,
                              _filterStartDate,
                              _filterEndDate,
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
    if (_selectedPreset != preset ||
        _filterStartDate != startDate ||
        _filterEndDate != endDate) {
      setState(() {
        _selectedPreset = preset;
        _filterStartDate = startDate;
        _filterEndDate = endDate;

        if (preset != FilterPreset.custom) {
          _calculateDateRange(preset);
        }
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
    // The previous textTheme and colorScheme locals were unused, removing them for cleanup.

    // Display the current filter range under the segmented button for better context
    String filterDisplay;
    if (_selectedPreset == FilterPreset.allTime) {
      filterDisplay = "All Time";
    } else if (_selectedPreset == FilterPreset.custom) {
      filterDisplay =
          "${DateFormat('d MMM yyyy').format(_filterStartDate)} - ${DateFormat('d MMM yyyy').format(_filterEndDate)}";
    } else {
      filterDisplay =
          "${capitalize(_selectedPreset.name)} (${DateFormat('d MMM yyyy').format(_filterStartDate)} - ${DateFormat('d MMM yyyy').format(_filterEndDate)})";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Receipts"),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
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

          // Display current filter range
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Filtering by: $filterDisplay',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Expanded(child: _buildContentForSegment(_selectedSegment)),
        ],
      ),
    );
  }

  Widget _buildContentForSegment(ViewSegment segment) {
    final DateTime startDate = _filterStartDate;
    final DateTime endDate = _filterEndDate;

    // You MUST update your child screens to accept these date parameters.
    // I've temporarily added the parameters below to ensure the code compiles
    // if you update those screen files next.
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
