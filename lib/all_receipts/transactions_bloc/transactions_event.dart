part of 'transactions_bloc.dart';

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsLoadAll extends TransactionsEvent {
  const TransactionsLoadAll();
}

class TransactionsLoadFiltered extends TransactionsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const TransactionsLoadFiltered({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}
