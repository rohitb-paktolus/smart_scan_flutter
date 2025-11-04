part of 'transactions_bloc.dart';

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsLoadAll extends TransactionsEvent {
  const TransactionsLoadAll();
}
