import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/models/user_model.dart';
import '../../features/models/transaction_model.dart';

class LocalPersistenceService {
  static const String _usersKey = 'imh_persisted_users_v1';
  static const String _activeUserKey = 'imh_active_user_id_v1';
  static const String _transactionsKey = 'imh_persisted_transactions_v1';
  static const String _themeModeKey = 'imh_persisted_theme_mode_v1';

  // USERS persistence
  static Future<void> saveUsers(List<UserModel> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
      await prefs.setString(_usersKey, encoded);
    } catch (e) {
      debugPrint('Error saving users to local storage: $e');
    }
  }

  static Future<List<UserModel>?> loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_usersKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        return decoded.map((item) => UserModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
      }
    } catch (e) {
      debugPrint('Error loading users from local storage: $e');
    }
    return null;
  }

  static Future<void> saveActiveUserId(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeUserKey, id);
    } catch (e) {
      debugPrint('Error saving active user id: $e');
    }
  }

  static Future<String?> loadActiveUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_activeUserKey);
    } catch (e) {
      return null;
    }
  }

  // TRANSACTIONS persistence
  static Future<void> saveTransactions(List<TransactionModel> txns) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(txns.map((t) => t.toJson()).toList());
      await prefs.setString(_transactionsKey, encoded);
    } catch (e) {
      debugPrint('Error saving transactions to local storage: $e');
    }
  }

  static Future<List<TransactionModel>?> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_transactionsKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        return decoded.map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
      }
    } catch (e) {
      debugPrint('Error loading transactions from local storage: $e');
    }
    return null;
  }

  // THEME MODE persistence
  static Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  static Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_themeModeKey);
      if (raw == 'dark') return ThemeMode.dark;
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
    return ThemeMode.light;
  }
}
