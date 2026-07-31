import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:imh_erp/features/models/transaction_model.dart';
import 'package:imh_erp/features/transactions/bloc/transaction_bloc.dart';
import 'package:imh_erp/features/transactions/bloc/transaction_event.dart';
import 'package:imh_erp/features/transactions/bloc/transaction_state.dart';
import 'package:imh_erp/features/users/bloc/user_bloc.dart';
import 'package:imh_erp/features/users/bloc/user_event.dart';
import 'package:imh_erp/features/users/bloc/user_state.dart';
import 'package:imh_erp/core/localization/locale_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('LocaleCubit Tests', () {
    test('Initial locale is English (en)', () {
      final cubit = LocaleCubit();
      expect(cubit.state, equals(const Locale('en')));
      expect(cubit.isArabic, isFalse);
    });

    test('Toggling locale switches between English and Arabic', () {
      final cubit = LocaleCubit();
      cubit.toggleLocale();
      expect(cubit.state, equals(const Locale('ar')));
      expect(cubit.isArabic, isTrue);

      cubit.toggleLocale();
      expect(cubit.state, equals(const Locale('en')));
      expect(cubit.isArabic, isFalse);
    });
  });

  group('UserBloc RBAC Tests', () {
    late UserBloc userBloc;

    setUp(() {
      userBloc = UserBloc();
    });

    tearDown(() {
      userBloc.close();
    });

    test('Initial state loads pre-seeded Master Admin account', () async {
      userBloc.add(LoadUsers());
      await expectLater(
        userBloc.stream,
        emits(isA<UserLoaded>().having((s) => s.users.length, 'users length', 1)),
      );

      final state = userBloc.state as UserLoaded;
      expect(state.activeUser.permissions.canManageUsers, isTrue);
      expect(state.activeUser.name, contains('Emad'));
    });
  });

  group('TransactionBloc Ledger Tests', () {
    late TransactionBloc transactionBloc;

    setUp(() {
      transactionBloc = TransactionBloc();
    });

    tearDown(() {
      transactionBloc.close();
    });

    test('LoadTransactions loads initial mock transactions', () async {
      transactionBloc.add(LoadTransactions());
      await expectLater(
        transactionBloc.stream,
        emitsInOrder([
          isA<TransactionLoading>(),
          isA<TransactionLoaded>().having((s) => s.allTransactions.isNotEmpty, 'has transactions', isTrue),
        ]),
      );
    });

    test('AddTransaction inserts new transaction at beginning', () async {
      transactionBloc.add(LoadTransactions());
      await transactionBloc.stream.firstWhere((s) => s is TransactionLoaded);

      final newTxn = TransactionModel(
        id: 'TEST-001',
        date: DateTime.now(),
        category: 'Office Rent',
        description: 'Test Rent Entry',
        amountEgp: 1000.0,
        amountEur: 0.0,
        amountUsd: 0.0,
        invoiceNumber: 'INV-TEST',
        responsiblePerson: 'Finance Dept',
        projectTag: 'General HQ / Internal Overhead',
        sourceAccount: 'CIB-EGP',
      );

      transactionBloc.add(AddTransaction(newTxn));
      await expectLater(
        transactionBloc.stream,
        emits(isA<TransactionLoaded>().having((s) => s.allTransactions.first.id, 'first id', 'TEST-001')),
      );
    });

    test('FilterTransactions filters list by project tag', () async {
      transactionBloc.add(LoadTransactions());
      await transactionBloc.stream.firstWhere((s) => s is TransactionLoaded);

      transactionBloc.add(const FilterTransactions(project: 'Siemens UAE Automation'));
      await expectLater(
        transactionBloc.stream,
        emits(isA<TransactionLoaded>().having(
          (s) => s.filteredTransactions.every((t) => t.projectTag == 'Siemens UAE Automation'),
          'all match project',
          isTrue,
        )),
      );
    });
  });
}
