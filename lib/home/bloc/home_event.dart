part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeLoadUserAndReceipts extends HomeEvent {}

class HomeReloadReceipts extends HomeEvent {}

class HomeCalculateMonthlyTotal extends HomeEvent {}

class HomeSearchQueryChanged extends HomeEvent {
  final String query;

  const HomeSearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class HomeReceiptsListUpdated extends HomeEvent {
  const HomeReceiptsListUpdated();
}

class HomeDeleteReceipt extends HomeEvent {
  final int receiptId;

  const HomeDeleteReceipt(this.receiptId);

  @override
  List<Object> get props => [receiptId];
}
