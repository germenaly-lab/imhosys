import 'package:equatable/equatable.dart';
import '../../models/transaction_model.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> allTransactions;
  final List<TransactionModel> filteredTransactions;
  final String searchQuery;
  final String? selectedProject;
  final String? selectedCategory;
  final String? selectedAccount;
  final String? selectedPerson;

  const TransactionLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    this.searchQuery = '',
    this.selectedProject,
    this.selectedCategory,
    this.selectedAccount,
    this.selectedPerson,
  });

  // Calculate Aggregates
  double get totalEgp => filteredTransactions.fold(0.0, (sum, item) => sum + item.amountEgp);
  double get totalEur => filteredTransactions.fold(0.0, (sum, item) => sum + item.amountEur);
  double get totalUsd => filteredTransactions.fold(0.0, (sum, item) => sum + item.amountUsd);

  TransactionLoaded copyWith({
    List<TransactionModel>? allTransactions,
    List<TransactionModel>? filteredTransactions,
    String? searchQuery,
    String? selectedProject,
    String? selectedCategory,
    String? selectedAccount,
    String? selectedPerson,
  }) {
    return TransactionLoaded(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedProject: selectedProject ?? this.selectedProject,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      selectedPerson: selectedPerson ?? this.selectedPerson,
    );
  }

  @override
  List<Object?> get props => [
        allTransactions,
        filteredTransactions,
        searchQuery,
        selectedProject,
        selectedCategory,
        selectedAccount,
        selectedPerson,
      ];
}

class TransactionFailure extends TransactionState {
  final String error;
  const TransactionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
