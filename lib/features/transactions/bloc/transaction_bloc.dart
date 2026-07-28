import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';
import '../../models/transaction_model.dart';
import '../../seed/mock_data_generator.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<SearchTransactions>(_onSearchTransactions);
    on<FilterTransactions>(_onFilterTransactions);
    on<ImportTransactions>(_onImportTransactions);
  }

  void _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) {
    emit(TransactionLoading());
    try {
      final initialData = MockDataGenerator.getInitialTransactions();
      emit(TransactionLoaded(
        allTransactions: initialData,
        filteredTransactions: initialData,
      ));
    } catch (e) {
      emit(TransactionFailure('Failed to load transaction data: $e'));
    }
  }

  void _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      final updatedAll = List<TransactionModel>.from(currentState.allTransactions)..insert(0, event.transaction);
      final updatedFiltered = _applyFilters(
        all: updatedAll,
        query: currentState.searchQuery,
        project: currentState.selectedProject,
        category: currentState.selectedCategory,
        account: currentState.selectedAccount,
        person: currentState.selectedPerson,
      );
      emit(currentState.copyWith(
        allTransactions: updatedAll,
        filteredTransactions: updatedFiltered,
      ));
    }
  }

  void _onUpdateTransaction(UpdateTransaction event, Emitter<TransactionState> emit) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      final updatedAll = currentState.allTransactions.map((item) {
        return item.id == event.transaction.id ? event.transaction : item;
      }).toList();
      final updatedFiltered = _applyFilters(
        all: updatedAll,
        query: currentState.searchQuery,
        project: currentState.selectedProject,
        category: currentState.selectedCategory,
        account: currentState.selectedAccount,
        person: currentState.selectedPerson,
      );
      emit(currentState.copyWith(
        allTransactions: updatedAll,
        filteredTransactions: updatedFiltered,
      ));
    }
  }

  void _onDeleteTransaction(DeleteTransaction event, Emitter<TransactionState> emit) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      final updatedAll = currentState.allTransactions.where((item) => item.id != event.id).toList();
      final updatedFiltered = _applyFilters(
        all: updatedAll,
        query: currentState.searchQuery,
        project: currentState.selectedProject,
        category: currentState.selectedCategory,
        account: currentState.selectedAccount,
        person: currentState.selectedPerson,
      );
      emit(currentState.copyWith(
        allTransactions: updatedAll,
        filteredTransactions: updatedFiltered,
      ));
    }
  }

  void _onSearchTransactions(SearchTransactions event, Emitter<TransactionState> emit) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      final filtered = _applyFilters(
        all: currentState.allTransactions,
        query: event.query,
        project: currentState.selectedProject,
        category: currentState.selectedCategory,
        account: currentState.selectedAccount,
        person: currentState.selectedPerson,
      );
      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredTransactions: filtered,
      ));
    }
  }

  void _onFilterTransactions(FilterTransactions event, Emitter<TransactionState> emit) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      final filtered = _applyFilters(
        all: currentState.allTransactions,
        query: currentState.searchQuery,
        project: event.project,
        category: event.category,
        account: event.account,
        person: event.responsiblePerson,
      );
      emit(currentState.copyWith(
        selectedProject: event.project,
        selectedCategory: event.category,
        selectedAccount: event.account,
        selectedPerson: event.responsiblePerson,
        filteredTransactions: filtered,
      ));
    }
  }

  void _onImportTransactions(ImportTransactions event, Emitter<TransactionState> emit) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      final updatedAll = List<TransactionModel>.from(event.imported)..addAll(currentState.allTransactions);
      final updatedFiltered = _applyFilters(
        all: updatedAll,
        query: currentState.searchQuery,
        project: currentState.selectedProject,
        category: currentState.selectedCategory,
        account: currentState.selectedAccount,
        person: currentState.selectedPerson,
      );
      emit(currentState.copyWith(
        allTransactions: updatedAll,
        filteredTransactions: updatedFiltered,
      ));
    }
  }

  List<TransactionModel> _applyFilters({
    required List<TransactionModel> all,
    required String query,
    String? project,
    String? category,
    String? account,
    String? person,
  }) {
    return all.where((item) {
      final matchesQuery = query.isEmpty ||
          item.description.toLowerCase().contains(query.toLowerCase()) ||
          item.invoiceNumber.toLowerCase().contains(query.toLowerCase()) ||
          item.responsiblePerson.toLowerCase().contains(query.toLowerCase()) ||
          item.id.toLowerCase().contains(query.toLowerCase());

      final matchesProject = project == null || project.isEmpty || project == 'All Projects' || item.projectTag == project;
      final matchesCategory = category == null || category.isEmpty || category == 'All Categories' || item.category == category;
      final matchesAccount = account == null || account.isEmpty || account == 'All Accounts' || item.sourceAccount == account;
      final matchesPerson = person == null || person.isEmpty || person == 'All Persons' || item.responsiblePerson == person;

      return matchesQuery && matchesProject && matchesCategory && matchesAccount && matchesPerson;
    }).toList();
  }
}
