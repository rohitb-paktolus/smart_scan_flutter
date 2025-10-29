import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scan_flutter/db/database_helper.dart'; // Import for Receipt
import '../utils/prefs.dart';
import '../utils/route.dart';
import 'bloc/home_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _homeBloc.add(HomeReloadReceipts());
    }
    super.didChangeAppLifecycleState(state);
  }

  void _onLogOut() {
    Prefs.clear();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(ROUT_LOGIN_EMAIL, (route) => false);
  }

  void _onReceiptTap(BuildContext context, Receipt receipt) async {
    await Navigator.pushNamed(
      context,
      ROUTE_RECEIPT_DETAIL,
      arguments: receipt.id,
    );

    context.read<HomeBloc>().add(HomeReloadReceipts());
  }

  Future<bool> _confirmDismiss(BuildContext context, Receipt receipt) async {
    // Show the confirmation dialog and wait for a result (true or false)
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text(
            "Are you sure you want to delete the receipt for **${receipt.vendorName}**?",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              // Do NOT dismiss
              child: const Text("Cancel"),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              // Confirm dismissal
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    // Return the result (default to false if dialog is dismissed unexpectedly)
    return shouldDelete ?? false;
  }

  void _onDeleteReceipt(int receiptId) {
    context.read<HomeBloc>().add(HomeDeleteReceipt(receiptId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Receipt deleted."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onScanButtonPressed(BuildContext context) async {
    await Navigator.pushNamed(context, ROUTE_SCAN);

    context.read<HomeBloc>().add(HomeReloadReceipts());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeError &&
            state.message.contains("User not logged in")) {
          // TODO: Navigate to Login
        }
      },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  "Smart Scan Menu",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Log Out"),
                onTap: () {
                  Navigator.pop(context);
                  _onLogOut();
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: TextField(
            onChanged: (query) {
              context.read<HomeBloc>().add(HomeSearchQueryChanged(query));
            },
            decoration: const InputDecoration(
              hintText: "Search...",
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Filter functionality coming soon!"),
                  ),
                );
              },
              icon: const Icon(Icons.filter_list),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state.userId == null && state is HomeInitial) {
                      return const Center(
                        child: Text(
                          "Loading user data...",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    if (state is HomeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is HomeError) {
                      final errorText =
                          state.message.contains("User not logged in")
                              ? "Please log in to view receipts."
                              : "Error loading receipts: ${state.message}";
                      return Center(child: Text(errorText));
                    }

                    final receipts = state.filteredReceipts;

                    if (state.allReceipts.isEmpty) {
                      return const Center(
                        child: Text(
                          "No receipts saved yet. Scan one now!",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    if (receipts.isEmpty && state.searchQuery.isNotEmpty) {
                      return Center(
                        child: Text(
                          "No receipts found matching '${state.searchQuery}'.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

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
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss:
                              (direction) => _confirmDismiss(context, receipt),
                          onDismissed: (direction) {
                            if (receipt.id != null) {
                              _onDeleteReceipt(receipt.id!);
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              onTap: () => _onReceiptTap(context, receipt),
                              leading: const Icon(
                                Icons.receipt,
                                color: Colors.blue,
                              ),
                              title: Text(
                                receipt.vendorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Category: ${receipt.category} | Date: ${receipt.date}",
                              ),
                              trailing: Text(
                                "\$${receipt.totalAmount}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 20),
          child: FloatingActionButton(
            onPressed: () => _onScanButtonPressed(context),
            child: const Icon(Icons.scanner),
          ),
        ),
      ),
    );
  }
}
