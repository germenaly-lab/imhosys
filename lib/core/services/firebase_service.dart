import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';
import '../../features/models/transaction_model.dart';
import '../../features/models/user_model.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Initialize Firebase app with DefaultFirebaseOptions
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      debugPrint('🔥 Firebase successfully linked and initialized for IMHOSYS Web.');
    } catch (e) {
      debugPrint('⚠️ Firebase initialization warning: $e. Operating in local resilient mode.');
    }
  }

  /// Sync transactions stream from Firestore 'transactions' collection
  Stream<List<TransactionModel>> getTransactionsStream() {
    if (!_isInitialized) {
      return const Stream.empty();
    }

    return firestore
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final dateStr = data['date'] as String?;
        final parsedDate = dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now();

        return TransactionModel(
          id: doc.id,
          date: parsedDate,
          category: (data['category'] as String?) ?? 'General',
          description: (data['description'] as String?) ?? '',
          amountEgp: (data['amountEgp'] as num?)?.toDouble() ?? 0.0,
          amountEur: (data['amountEur'] as num?)?.toDouble() ?? 0.0,
          amountUsd: (data['amountUsd'] as num?)?.toDouble() ?? 0.0,
          invoiceNumber: (data['invoiceNumber'] as String?) ?? '',
          responsiblePerson: (data['responsiblePerson'] as String?) ?? 'Eng. Emad',
          projectTag: (data['projectTag'] as String?) ?? 'General',
          sourceAccount: (data['sourceAccount'] as String?) ?? 'ACC-EGP-MAIN',
        );
      }).toList();
    });
  }

  /// Save or Update Transaction in Firestore
  Future<void> saveTransaction(TransactionModel txn) async {
    if (!_isInitialized) return;

    try {
      await firestore.collection('transactions').doc(txn.id).set({
        'id': txn.id,
        'date': txn.date.toIso8601String(),
        'category': txn.category,
        'description': txn.description,
        'amountEgp': txn.amountEgp,
        'amountEur': txn.amountEur,
        'amountUsd': txn.amountUsd,
        'invoiceNumber': txn.invoiceNumber,
        'responsiblePerson': txn.responsiblePerson,
        'projectTag': txn.projectTag,
        'sourceAccount': txn.sourceAccount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('🔥 Transaction ${txn.id} synced to Firebase Firestore.');
    } catch (e) {
      debugPrint('⚠️ Firebase saveTransaction error: $e');
    }
  }

  /// Delete Transaction from Firestore
  Future<void> deleteTransaction(String id) async {
    if (!_isInitialized) return;

    try {
      await firestore.collection('transactions').doc(id).delete();
      debugPrint('🔥 Transaction $id removed from Firebase Firestore.');
    } catch (e) {
      debugPrint('⚠️ Firebase deleteTransaction error: $e');
    }
  }

  /// Save or Update User in Firestore
  Future<void> saveUser(UserModel user) async {
    if (!_isInitialized) return;

    try {
      await firestore.collection('users').doc(user.id).set({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'password': user.password,
        'entityCode': user.entityCode,
        'permissions': {
          'canViewLedger': user.permissions.canViewLedger,
          'canAddTransaction': user.permissions.canAddTransaction,
          'canEditTransaction': user.permissions.canEditTransaction,
          'canDeleteTransaction': user.permissions.canDeleteTransaction,
          'canImportExportExcel': user.permissions.canImportExportExcel,
          'canExecuteTransfer': user.permissions.canExecuteTransfer,
          'canManageUsers': user.permissions.canManageUsers,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('🔥 User ${user.name} synced to Firebase Firestore.');
    } catch (e) {
      debugPrint('⚠️ Firebase saveUser error: $e');
    }
  }

  /// Sync users stream from Firestore 'users' collection
  Stream<List<UserModel>> getUsersStream() {
    if (!_isInitialized) {
      return const Stream.empty();
    }

    return firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final permissionsMap = Map<String, dynamic>.from((data['permissions'] as Map?) ?? {});

        return UserModel(
          id: doc.id,
          name: (data['name'] as String?) ?? 'User',
          email: (data['email'] as String?) ?? '',
          password: (data['password'] as String?) ?? '',
          entityCode: (data['entityCode'] as String?) ?? 'US',
          permissions: UserPermission(
            canViewLedger: (permissionsMap['canViewLedger'] as bool?) ?? true,
            canAddTransaction: (permissionsMap['canAddTransaction'] as bool?) ?? true,
            canEditTransaction: (permissionsMap['canEditTransaction'] as bool?) ?? false,
            canDeleteTransaction: (permissionsMap['canDeleteTransaction'] as bool?) ?? false,
            canImportExportExcel: (permissionsMap['canImportExportExcel'] as bool?) ?? false,
            canExecuteTransfer: (permissionsMap['canExecuteTransfer'] as bool?) ?? false,
            canManageUsers: (permissionsMap['canManageUsers'] as bool?) ?? false,
          ),
        );
      }).toList();
    });
  }
}
