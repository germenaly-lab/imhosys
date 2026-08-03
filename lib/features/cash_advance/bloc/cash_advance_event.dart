import 'package:equatable/equatable.dart';
import '../models/cash_advance_model.dart';

abstract class CashAdvanceEvent extends Equatable {
  const CashAdvanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadCashAdvances extends CashAdvanceEvent {}

class CreateCashAdvance extends CashAdvanceEvent {
  final CashAdvanceModel advance;
  const CreateCashAdvance(this.advance);

  @override
  List<Object?> get props => [advance];
}

class AddExpenseToAdvance extends CashAdvanceEvent {
  final String advanceId;
  final CashAdvanceExpenseModel expense;
  const AddExpenseToAdvance({required this.advanceId, required this.expense});

  @override
  List<Object?> get props => [advanceId, expense];
}

class DeleteExpenseFromAdvance extends CashAdvanceEvent {
  final String advanceId;
  final String expenseId;
  const DeleteExpenseFromAdvance({required this.advanceId, required this.expenseId});

  @override
  List<Object?> get props => [advanceId, expenseId];
}

class SettleCashAdvance extends CashAdvanceEvent {
  final String advanceId;
  const SettleCashAdvance(this.advanceId);

  @override
  List<Object?> get props => [advanceId];
}

class DeleteCashAdvance extends CashAdvanceEvent {
  final String advanceId;
  const DeleteCashAdvance(this.advanceId);

  @override
  List<Object?> get props => [advanceId];
}

class FilterCashAdvances extends CashAdvanceEvent {
  final String searchQuery;
  final CashAdvanceType? typeFilter;
  final CashAdvanceStatus? statusFilter;
  final String? recipientFilter;

  const FilterCashAdvances({
    this.searchQuery = '',
    this.typeFilter,
    this.statusFilter,
    this.recipientFilter,
  });

  @override
  List<Object?> get props => [searchQuery, typeFilter, statusFilter, recipientFilter];
}
