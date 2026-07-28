import 'package:equatable/equatable.dart';
import '../../models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;
  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransaction extends TransactionEvent {
  final TransactionModel transaction;
  const UpdateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String id;
  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchTransactions extends TransactionEvent {
  final String query;
  const SearchTransactions(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterTransactions extends TransactionEvent {
  final String? project;
  final String? category;
  final String? account;
  final String? responsiblePerson;

  const FilterTransactions({
    this.project,
    this.category,
    this.account,
    this.responsiblePerson,
  });

  @override
  List<Object?> get props => [project, category, account, responsiblePerson];
}

class ImportTransactions extends TransactionEvent {
  final List<TransactionModel> imported;
  const ImportTransactions(this.imported);

  @override
  List<Object?> get props => [imported];
}
