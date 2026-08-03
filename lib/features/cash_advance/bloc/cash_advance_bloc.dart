import 'package:flutter_bloc/flutter_bloc.dart';
import 'cash_advance_event.dart';
import 'cash_advance_state.dart';
import '../models/cash_advance_model.dart';
import '../seed/cash_advance_seed.dart';
import '../../../core/services/local_persistence_service.dart';

class CashAdvanceBloc extends Bloc<CashAdvanceEvent, CashAdvanceState> {
  CashAdvanceBloc() : super(CashAdvanceInitial()) {
    on<LoadCashAdvances>(_onLoadCashAdvances);
    on<CreateCashAdvance>(_onCreateCashAdvance);
    on<AddExpenseToAdvance>(_onAddExpenseToAdvance);
    on<DeleteExpenseFromAdvance>(_onDeleteExpenseFromAdvance);
    on<SettleCashAdvance>(_onSettleCashAdvance);
    on<DeleteCashAdvance>(_onDeleteCashAdvance);
    on<FilterCashAdvances>(_onFilterCashAdvances);
  }

  Future<void> _onLoadCashAdvances(
    LoadCashAdvances event,
    Emitter<CashAdvanceState> emit,
  ) async {
    emit(CashAdvanceLoading());
    try {
      List<CashAdvanceModel>? loaded = await LocalPersistenceService.loadCashAdvances();
      if (loaded == null || loaded.isEmpty) {
        loaded = CashAdvanceSeed.getInitialAdvances();
        await LocalPersistenceService.saveCashAdvances(loaded);
      }

      emit(CashAdvanceLoaded(
        allAdvances: loaded,
        filteredAdvances: loaded,
      ));
    } catch (e) {
      emit(CashAdvanceError('Failed to load cash advances: $e'));
    }
  }

  Future<void> _onCreateCashAdvance(
    CreateCashAdvance event,
    Emitter<CashAdvanceState> emit,
  ) async {
    if (state is CashAdvanceLoaded) {
      final currentState = state as CashAdvanceLoaded;
      final updatedList = List<CashAdvanceModel>.from(currentState.allAdvances)..insert(0, event.advance);

      _updateStateAndPersist(emit, currentState, updatedList);
    }
  }

  Future<void> _onAddExpenseToAdvance(
    AddExpenseToAdvance event,
    Emitter<CashAdvanceState> emit,
  ) async {
    if (state is CashAdvanceLoaded) {
      final currentState = state as CashAdvanceLoaded;
      final updatedList = currentState.allAdvances.map((adv) {
        if (adv.id == event.advanceId) {
          final newExpenses = List<CashAdvanceExpenseModel>.from(adv.expenses)..insert(0, event.expense);
          final newTotalSpent = newExpenses.fold(0.0, (s, e) => s + e.amount);
          CashAdvanceStatus newStatus = adv.status;
          if (newTotalSpent > adv.initialAmount) {
            newStatus = CashAdvanceStatus.overspent;
          } else if (newTotalSpent == adv.initialAmount) {
            newStatus = CashAdvanceStatus.fullySettled;
          }

          return adv.copyWith(
            expenses: newExpenses,
            status: newStatus,
          );
        }
        return adv;
      }).toList();

      _updateStateAndPersist(emit, currentState, updatedList);
    }
  }

  Future<void> _onDeleteExpenseFromAdvance(
    DeleteExpenseFromAdvance event,
    Emitter<CashAdvanceState> emit,
  ) async {
    if (state is CashAdvanceLoaded) {
      final currentState = state as CashAdvanceLoaded;
      final updatedList = currentState.allAdvances.map((adv) {
        if (adv.id == event.advanceId) {
          final newExpenses = adv.expenses.where((e) => e.id != event.expenseId).toList();
          final newTotalSpent = newExpenses.fold(0.0, (s, e) => s + e.amount);
          CashAdvanceStatus newStatus = adv.status;
          if (newTotalSpent < adv.initialAmount && adv.status == CashAdvanceStatus.overspent) {
            newStatus = CashAdvanceStatus.active;
          }

          return adv.copyWith(
            expenses: newExpenses,
            status: newStatus,
          );
        }
        return adv;
      }).toList();

      _updateStateAndPersist(emit, currentState, updatedList);
    }
  }

  Future<void> _onSettleCashAdvance(
    SettleCashAdvance event,
    Emitter<CashAdvanceState> emit,
  ) async {
    if (state is CashAdvanceLoaded) {
      final currentState = state as CashAdvanceLoaded;
      final updatedList = currentState.allAdvances.map((adv) {
        if (adv.id == event.advanceId) {
          return adv.copyWith(status: CashAdvanceStatus.fullySettled);
        }
        return adv;
      }).toList();

      _updateStateAndPersist(emit, currentState, updatedList);
    }
  }

  Future<void> _onDeleteCashAdvance(
    DeleteCashAdvance event,
    Emitter<CashAdvanceState> emit,
  ) async {
    if (state is CashAdvanceLoaded) {
      final currentState = state as CashAdvanceLoaded;
      final updatedList = currentState.allAdvances.where((adv) => adv.id != event.advanceId).toList();

      _updateStateAndPersist(emit, currentState, updatedList);
    }
  }

  void _onFilterCashAdvances(
    FilterCashAdvances event,
    Emitter<CashAdvanceState> emit,
  ) {
    if (state is CashAdvanceLoaded) {
      final currentState = state as CashAdvanceLoaded;
      final filtered = _applyFilters(
        all: currentState.allAdvances,
        query: event.searchQuery,
        type: event.typeFilter,
        status: event.statusFilter,
        recipient: event.recipientFilter,
      );

      emit(currentState.copyWith(
        filteredAdvances: filtered,
        searchQuery: event.searchQuery,
        selectedType: event.typeFilter,
        selectedStatus: event.statusFilter,
        selectedRecipient: event.recipientFilter,
      ));
    }
  }

  void _updateStateAndPersist(
    Emitter<CashAdvanceState> emit,
    CashAdvanceLoaded currentState,
    List<CashAdvanceModel> updatedList,
  ) {
    final filtered = _applyFilters(
      all: updatedList,
      query: currentState.searchQuery,
      type: currentState.selectedType,
      status: currentState.selectedStatus,
      recipient: currentState.selectedRecipient,
    );

    emit(currentState.copyWith(
      allAdvances: updatedList,
      filteredAdvances: filtered,
    ));

    LocalPersistenceService.saveCashAdvances(updatedList);
  }

  List<CashAdvanceModel> _applyFilters({
    required List<CashAdvanceModel> all,
    required String query,
    CashAdvanceType? type,
    CashAdvanceStatus? status,
    String? recipient,
  }) {
    return all.where((adv) {
      final matchesQuery = query.isEmpty ||
          adv.recipientName.toLowerCase().contains(query.toLowerCase()) ||
          adv.title.toLowerCase().contains(query.toLowerCase()) ||
          adv.id.toLowerCase().contains(query.toLowerCase()) ||
          adv.projectTag.toLowerCase().contains(query.toLowerCase());

      final matchesType = type == null || adv.advanceType == type;
      final matchesStatus = status == null || adv.status == status;
      final matchesRecipient = recipient == null || recipient.isEmpty || adv.recipientName == recipient;

      return matchesQuery && matchesType && matchesStatus && matchesRecipient;
    }).toList();
  }
}
