import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../db/database_helper.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<HomeLoadUserAndReceipts>(_onLoadUserAndReceipts);
    on<HomeReloadReceipts>(_onReloadReceipts);
    on<HomeSearchQueryChanged>(_onSearchQueryChanged);
    on<HomeDeleteReceipt>(_onDeleteReceipt);
  }

  Future<double> _fetchCurrentMonthTotal(String userId) async {
    final now = DateTime.now();
    return DatabaseHelper.instance.getTotalAmountForMonth(
      month: now.month,
      year: now.year,
      userId: userId,
    );
  }

  // Applies the current search query to a list of receipts
  List<Receipt> _applySearchFilter(List<Receipt> receipts, String query) {
    if (query.isEmpty) {
      return receipts;
    }
    final lowerCaseQuery = query.toLowerCase();
    return receipts.where((receipt) {
      final vendorMatch = receipt.vendorName.toLowerCase().contains(
        lowerCaseQuery,
      );
      final categoryMatch = receipt.category.name.toLowerCase().contains(
        lowerCaseQuery,
      );
      final dateMatch = receipt.date.toLowerCase().contains(lowerCaseQuery);

      return vendorMatch || categoryMatch || dateMatch;
    }).toList();
  }

  // Fetches receipts for a given userId
  Future<List<Receipt>> _fetchRecentReceipts(String userId) async {
    return DatabaseHelper.instance.getMostRecentReceipts(userId: userId);
  }

  Future<void> _onLoadUserAndReceipts(
    HomeLoadUserAndReceipts event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      HomeLoading(
        allReceipts: state.allReceipts,
        filteredReceipts: state.filteredReceipts,
        searchQuery: state.searchQuery,
        userId: state.userId,
        currentMonthTotal: state.currentMonthTotal,
      ),
    );

    try {
      final userId = await DatabaseHelper.instance.getLoggedInUserEmail();
      if (userId == null) {
        return emit(const HomeError(message: "User not logged in."));
      }

      final receipts = await _fetchRecentReceipts(userId);
      final filtered = _applySearchFilter(receipts, state.searchQuery);

      final currentMonthTotal = await _fetchCurrentMonthTotal(userId);

      emit(
        HomeLoaded(
          allReceipts: receipts,
          filteredReceipts: filtered,
          searchQuery: state.searchQuery,
          userId: userId,
          currentMonthTotal: currentMonthTotal,
        ),
      );
    } catch (e) {
      emit(HomeError(message: "Failed to load user or receipts: $e"));
    }
  }

  Future<void> _onReloadReceipts(
    HomeReloadReceipts event,
    Emitter<HomeState> emit,
  ) async {
    final userId = state.userId;
    if (userId == null) return;

    emit(
      HomeLoading(
        allReceipts: state.allReceipts,
        filteredReceipts: state.filteredReceipts,
        searchQuery: state.searchQuery,
        userId: userId,
        currentMonthTotal: state.currentMonthTotal,
      ),
    );

    try {
      final receipts = await _fetchRecentReceipts(userId);
      final filtered = _applySearchFilter(receipts, state.searchQuery);

      final currentMonthTotal = await _fetchCurrentMonthTotal(userId);

      emit(
        HomeLoaded(
          allReceipts: receipts,
          filteredReceipts: filtered,
          searchQuery: state.searchQuery,
          userId: userId,
          currentMonthTotal: currentMonthTotal,
        ),
      );
    } catch (e) {
      emit(
        HomeError(
          message: "Failed to reload receipts: $e",
          userId: userId,
          allReceipts: state.allReceipts,
          filteredReceipts: state.filteredReceipts,
          searchQuery: state.searchQuery,
        ),
      );
    }
  }

  void _onSearchQueryChanged(
    HomeSearchQueryChanged event,
    Emitter<HomeState> emit,
  ) {
    final newQuery = event.query.toLowerCase();

    final sourceReceipts = state.allReceipts;
    final newFilteredReceipts = _applySearchFilter(sourceReceipts, newQuery);

    if (state is HomeLoaded) {
      emit(
        (state as HomeLoaded).copyWith(
          filteredReceipts: newFilteredReceipts,
          searchQuery: newQuery,
        ),
      );
    } else {
      emit(
        HomeLoaded(
          allReceipts: state.allReceipts,
          filteredReceipts: newFilteredReceipts,
          searchQuery: newQuery,
          userId: state.userId,
          currentMonthTotal: state.currentMonthTotal,
        ),
      );
    }
  }

  void _onDeleteReceipt(
    HomeDeleteReceipt event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await DatabaseHelper.instance.deleteReceipt(event.receiptId);
      add(HomeReloadReceipts());
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
