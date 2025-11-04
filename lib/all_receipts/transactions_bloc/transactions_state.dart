part of 'transactions_bloc.dart';

sealed class TransactionsState extends Equatable {
  final List<Receipt> allReceipts;
  final String? userId;

  const TransactionsState({this.allReceipts = const [], this.userId});

  @override
  List<Object?> get props => [allReceipts, userId];
}

final class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();

  @override
  List<Object> get props => [];
}

class TransactionsLoading extends TransactionsState {
  const TransactionsLoading({super.allReceipts, super.userId});
}

class TransactionsLoaded extends TransactionsState {
  const TransactionsLoaded({required super.allReceipts, required super.userId});

  @override
  List<Object?> get props => [allReceipts, userId];
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError({
    required this.message,
    super.allReceipts,
    super.userId,
  });

  @override
  List<Object?> get props => [message, allReceipts, userId];
}
