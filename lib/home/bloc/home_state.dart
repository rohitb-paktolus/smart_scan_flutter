part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  final List<Receipt> allReceipts;
  final List<Receipt> filteredReceipts;
  final String searchQuery;
  final String? userId;
  final double currentMonthTotal;

  const HomeState({
    this.allReceipts = const [],
    this.filteredReceipts = const [],
    this.searchQuery = "",
    this.currentMonthTotal = 0.0,
    this.userId,
  });

  @override
  List<Object?> get props => [
    allReceipts,
    filteredReceipts,
    searchQuery,
    userId,
    currentMonthTotal,
  ];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading({
    super.allReceipts,
    super.filteredReceipts,
    super.searchQuery,
    super.userId,
    super.currentMonthTotal,
  });

  @override
  List<Object?> get props => [
    allReceipts,
    filteredReceipts,
    searchQuery,
    userId,
    currentMonthTotal,
  ];
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required super.allReceipts,
    required super.filteredReceipts,
    required super.searchQuery,
    required super.userId,
    required super.currentMonthTotal,
  });

  HomeLoaded copyWith({
    List<Receipt>? allReceipts,
    List<Receipt>? filteredReceipts,
    String? searchQuery,
    String? userId,
    double? currentMonthTotal,
  }) {
    return HomeLoaded(
      allReceipts: allReceipts ?? this.allReceipts,
      filteredReceipts: filteredReceipts ?? this.filteredReceipts,
      searchQuery: searchQuery ?? this.searchQuery,
      userId: userId ?? this.userId,
      currentMonthTotal: currentMonthTotal ?? this.currentMonthTotal,
    );
  }

  @override
  List<Object?> get props => [
    allReceipts,
    filteredReceipts,
    searchQuery,
    userId,
    currentMonthTotal,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({
    required this.message,
    super.allReceipts,
    super.filteredReceipts,
    super.searchQuery,
    super.userId,
    super.currentMonthTotal,
  });

  @override
  List<Object?> get props => [
    message,
    allReceipts,
    filteredReceipts,
    searchQuery,
    userId,
    currentMonthTotal,
  ];
}
