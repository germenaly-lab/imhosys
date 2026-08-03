import 'package:equatable/equatable.dart';
import '../models/cash_advance_model.dart';

abstract class CashAdvanceState extends Equatable {
  const CashAdvanceState();

  @override
  List<Object?> get props => [];
}

class CashAdvanceInitial extends CashAdvanceState {}

class CashAdvanceLoading extends CashAdvanceState {}

class CashAdvanceLoaded extends CashAdvanceState {
  final List<CashAdvanceModel> allAdvances;
  final List<CashAdvanceModel> filteredAdvances;
  final String searchQuery;
  final CashAdvanceType? selectedType;
  final CashAdvanceStatus? selectedStatus;
  final String? selectedRecipient;

  const CashAdvanceLoaded({
    required this.allAdvances,
    required this.filteredAdvances,
    this.searchQuery = '',
    this.selectedType,
    this.selectedStatus,
    this.selectedRecipient,
  });

  CashAdvanceLoaded copyWith({
    List<CashAdvanceModel>? allAdvances,
    List<CashAdvanceModel>? filteredAdvances,
    String? searchQuery,
    CashAdvanceType? selectedType,
    CashAdvanceStatus? selectedStatus,
    String? selectedRecipient,
  }) {
    return CashAdvanceLoaded(
      allAdvances: allAdvances ?? this.allAdvances,
      filteredAdvances: filteredAdvances ?? this.filteredAdvances,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedRecipient: selectedRecipient ?? this.selectedRecipient,
    );
  }

  @override
  List<Object?> get props => [
        allAdvances,
        filteredAdvances,
        searchQuery,
        selectedType,
        selectedStatus,
        selectedRecipient,
      ];
}

class CashAdvanceError extends CashAdvanceState {
  final String message;
  const CashAdvanceError(this.message);

  @override
  List<Object?> get props => [message];
}
