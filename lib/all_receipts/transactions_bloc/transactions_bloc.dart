import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

part 'transactions_event.dart';

part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc() : super(TransactionsInitial()) {
    on<TransactionsLoadAll>(_onLoadAll);
    on<TransactionsLoadFiltered>(_onLoadFiltered);
  }

  Future<void> _onLoadAll(
    TransactionsLoadAll event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(
      TransactionsLoading(allReceipts: state.allReceipts, userId: state.userId),
    );

    try {
      final userId = await DatabaseHelper.instance.getLoggedInUserEmail();
      if (userId == null) {
        return emit(TransactionsError(message: "User not logged in."));
      }

      final receipts = await DatabaseHelper.instance.getReceipts(
        userId: userId,
      );

      emit(TransactionsLoaded(allReceipts: receipts, userId: userId));
    } catch (e) {
      emit(
        TransactionsError(
          message: "Failed to load all receipts: $e",
          allReceipts: state.allReceipts,
          userId: state.userId,
        ),
      );
    }
  }

  Future<void> _onLoadFiltered(
    TransactionsLoadFiltered event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(
      TransactionsLoading(allReceipts: state.allReceipts, userId: state.userId),
    );

    try {
      final userId = await DatabaseHelper.instance.getLoggedInUserEmail();
      if (userId == null) {
        return emit(const TransactionsError(message: "User not logged in."));
      }

      // 1. Call the DatabaseHelper with the date parameters.
      // NOTE: You must ensure DatabaseHelper.instance.getReceipts can handle
      // these optional startDate and endDate parameters to filter the SQL query.
      final receipts = await DatabaseHelper.instance.getReceipts(
        userId: userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(TransactionsLoaded(allReceipts: receipts, userId: userId));
    } catch (e) {
      emit(
        TransactionsError(
          message: "Failed to load filtered receipts: $e",
          allReceipts: state.allReceipts,
          userId: state.userId,
        ),
      );
    }
  }
}
