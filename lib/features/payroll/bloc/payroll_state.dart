import 'package:equatable/equatable.dart';
import '../models/payroll_model.dart';

abstract class PayrollState extends Equatable {
  const PayrollState();

  @override
  List<Object?> get props => [];
}

class PayrollInitial extends PayrollState {}

class PayrollLoading extends PayrollState {}

class PayrollLoaded extends PayrollState {
  final List<PayrollModel> allEntries;
  final List<PayrollModel> filteredEntries;
  final String searchQuery;
  final String? selectedPeriod;
  final String? selectedDepartment;
  final PayrollStatus? selectedStatus;

  const PayrollLoaded({
    required this.allEntries,
    required this.filteredEntries,
    this.searchQuery = '',
    this.selectedPeriod,
    this.selectedDepartment,
    this.selectedStatus,
  });

  PayrollLoaded copyWith({
    List<PayrollModel>? allEntries,
    List<PayrollModel>? filteredEntries,
    String? searchQuery,
    String? selectedPeriod,
    String? selectedDepartment,
    PayrollStatus? selectedStatus,
  }) {
    return PayrollLoaded(
      allEntries: allEntries ?? this.allEntries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }

  @override
  List<Object?> get props => [
        allEntries,
        filteredEntries,
        searchQuery,
        selectedPeriod,
        selectedDepartment,
        selectedStatus,
      ];
}

class PayrollError extends PayrollState {
  final String message;
  const PayrollError(this.message);

  @override
  List<Object?> get props => [message];
}
