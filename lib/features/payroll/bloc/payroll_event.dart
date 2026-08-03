import 'package:equatable/equatable.dart';
import '../models/payroll_model.dart';

abstract class PayrollEvent extends Equatable {
  const PayrollEvent();

  @override
  List<Object?> get props => [];
}

class LoadPayroll extends PayrollEvent {}

class CreatePayrollEntry extends PayrollEvent {
  final PayrollModel entry;
  const CreatePayrollEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

class UpdatePayrollEntry extends PayrollEvent {
  final PayrollModel entry;
  const UpdatePayrollEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DeletePayrollEntry extends PayrollEvent {
  final String id;
  const DeletePayrollEntry(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterPayroll extends PayrollEvent {
  final String searchQuery;
  final String? periodFilter;
  final String? departmentFilter;
  final PayrollStatus? statusFilter;

  const FilterPayroll({
    this.searchQuery = '',
    this.periodFilter,
    this.departmentFilter,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [searchQuery, periodFilter, departmentFilter, statusFilter];
}
