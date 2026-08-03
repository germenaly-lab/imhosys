import 'package:flutter_bloc/flutter_bloc.dart';
import 'payroll_event.dart';
import 'payroll_state.dart';
import '../models/payroll_model.dart';
import '../seed/payroll_seed.dart';
import '../../../core/services/local_persistence_service.dart';

class PayrollBloc extends Bloc<PayrollEvent, PayrollState> {
  PayrollBloc() : super(PayrollInitial()) {
    on<LoadPayroll>(_onLoadPayroll);
    on<CreatePayrollEntry>(_onCreatePayrollEntry);
    on<UpdatePayrollEntry>(_onUpdatePayrollEntry);
    on<DeletePayrollEntry>(_onDeletePayrollEntry);
    on<FilterPayroll>(_onFilterPayroll);
  }

  Future<void> _onLoadPayroll(
    LoadPayroll event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    try {
      List<PayrollModel>? loaded = await LocalPersistenceService.loadPayroll();
      if (loaded == null || loaded.isEmpty) {
        loaded = PayrollSeed.getInitialPayroll();
        await LocalPersistenceService.savePayroll(loaded);
      }

      emit(PayrollLoaded(
        allEntries: loaded,
        filteredEntries: loaded,
      ));
    } catch (e) {
      emit(PayrollError('Failed to load payroll data: $e'));
    }
  }

  Future<void> _onCreatePayrollEntry(
    CreatePayrollEntry event,
    Emitter<PayrollState> emit,
  ) async {
    if (state is PayrollLoaded) {
      final currentState = state as PayrollLoaded;
      final updatedList = List<PayrollModel>.from(currentState.allEntries)..insert(0, event.entry);

      _updateStateAndPersist(emit, currentState, updatedList);
    }
  }

  Future<void> _onUpdatePayrollEntry(
    UpdatePayrollEntry event,
    Emitter<PayrollState> emit,
  ) async {
    if (state is PayrollLoaded) {
      final currentState = state as PayrollLoaded;
      final updatedList = currentState.allEntries.map((item) {
        return item.id == event.entry.id ? event.entry : item;
      }).toList();

      _updateStateAndPersist(emit, currentState, updatedList);
    }
  }

  Future<void> _onDeletePayrollEntry(
    DeletePayrollEntry event,
    Emitter<PayrollState> emit,
  ) async {
    if (state is PayrollLoaded) {
      final currentState = state as PayrollLoaded;
      final updatedList = currentState.allEntries.where((item) => item.id != event.id).toList();

      _updateStateAndPersist(emit, currentState, updatedList);
    }
  }

  void _onFilterPayroll(
    FilterPayroll event,
    Emitter<PayrollState> emit,
  ) {
    if (state is PayrollLoaded) {
      final currentState = state as PayrollLoaded;
      final filtered = _applyFilters(
        all: currentState.allEntries,
        query: event.searchQuery,
        period: event.periodFilter,
        department: event.departmentFilter,
        status: event.statusFilter,
      );

      emit(currentState.copyWith(
        filteredEntries: filtered,
        searchQuery: event.searchQuery,
        selectedPeriod: event.periodFilter,
        selectedDepartment: event.departmentFilter,
        selectedStatus: event.statusFilter,
      ));
    }
  }

  void _updateStateAndPersist(
    Emitter<PayrollState> emit,
    PayrollLoaded currentState,
    List<PayrollModel> updatedList,
  ) {
    final filtered = _applyFilters(
      all: updatedList,
      query: currentState.searchQuery,
      period: currentState.selectedPeriod,
      department: currentState.selectedDepartment,
      status: currentState.selectedStatus,
    );

    emit(currentState.copyWith(
      allEntries: updatedList,
      filteredEntries: filtered,
    ));

    LocalPersistenceService.savePayroll(updatedList);
  }

  List<PayrollModel> _applyFilters({
    required List<PayrollModel> all,
    required String query,
    String? period,
    String? department,
    PayrollStatus? status,
  }) {
    return all.where((item) {
      final matchesQuery = query.isEmpty ||
          item.employeeName.toLowerCase().contains(query.toLowerCase()) ||
          item.jobTitle.toLowerCase().contains(query.toLowerCase()) ||
          item.id.toLowerCase().contains(query.toLowerCase()) ||
          item.department.toLowerCase().contains(query.toLowerCase());

      final matchesPeriod = period == null || period.isEmpty || item.payPeriod == period;
      final matchesDept = department == null || department.isEmpty || item.department == department;
      final matchesStatus = status == null || item.status == status;

      return matchesQuery && matchesPeriod && matchesDept && matchesStatus;
    }).toList();
  }
}
