import 'package:flutter/material.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import '../utils/prefs.dart';
import '../utils/route.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // State to hold fetched receipts
  late Future<List<Receipt>> _receiptsFuture;

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _receiptsFuture = Future.value([]);
    // Start loading user email and receipts on initialization
    _loadUserAndReceipts();

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
      if (_currentUserId != null) {
        _loadReceipts(_currentUserId!);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  // Method to fetch the user's email and then load the associated receipts
  void _loadUserAndReceipts() async {
    final userId = await DatabaseHelper.instance.getLoggedInUserEmail();
    if (userId != null) {
      _currentUserId = userId;
      _loadReceipts(userId);
    } else {
      if (mounted) {
        setState(() {
          _receiptsFuture = Future.error("User not logged in.");
        });
      }
    }
  }

  // Method to fetch receipts for a specific userId
  void _loadReceipts(String userId) {
    setState(() {
      _receiptsFuture = DatabaseHelper.instance.getReceipts(userId: userId);
    });
  }

  void _onLogOut() {
    Prefs.clear();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(ROUT_LOGIN_EMAIL, (route) => false);
  }

  // Handle navigation to the detail screen and reload on return
  void _onReceiptTap(Receipt receipt) async {
    // We navigate and wait for the result (if any) to know if we need to refresh
    await Navigator.pushNamed(
      context,
      ROUTE_RECEIPT_DETAIL,
      arguments: receipt.id,
    );

    // Reload the list whenever the user returns, ensuring any edits are visible
    if (_currentUserId != null) {
      _loadReceipts(_currentUserId!);
    }
  }

  // Helper method for the floating action button
  void _onScanButtonPressed() async {
    // Navigate to the scan route and wait for its completion
    await Navigator.pushNamed(context, ROUTE_SCAN);

    // Reload the list if a user is logged in
    if (_currentUserId != null) {
      _loadReceipts(_currentUserId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _onLogOut, // Use logout for now, or add filter logic
            icon: const Icon(
              Icons.logout,
            ), // Changed to logout icon for clarity
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Receipt>>(
                future: _receiptsFuture,
                builder: (context, snapshot) {
                  if (_currentUserId == null) {
                    return const Center(
                      child: Text(
                        "Loading user data...",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    final errorText =
                        snapshot.error.toString().contains("User not logged in")
                            ? "Please log in to view receipts."
                            : "Error loading receipts: ${snapshot.error}";
                    return Center(child: Text(errorText));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No receipts saved yet. Scan one now!",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Display the list of receipts
                  final receipts = snapshot.data!;
                  return ListView.builder(
                    itemCount: receipts.length,
                    itemBuilder: (context, index) {
                      final receipt = receipts[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          onTap: () => _onReceiptTap(receipt),
                          leading: const Icon(
                            Icons.receipt,
                            color: Colors.blue,
                          ),
                          title: Text(
                            receipt.vendorName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Category: ${receipt.category} | Date: ${receipt.date}",
                          ),
                          trailing: Text(
                            "\$${receipt.totalAmount}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _onLogOut();
                },
                child: Text("Log Out"),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 20),
        child: FloatingActionButton(
          onPressed: _onScanButtonPressed,
          child: const Icon(Icons.scanner),
        ),
      ),
    );
  }
}
