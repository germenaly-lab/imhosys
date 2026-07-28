import 'package:equatable/equatable.dart';

class UserPermission extends Equatable {
  final bool canViewLedger;
  final bool canAddTransaction;
  final bool canEditTransaction;
  final bool canDeleteTransaction;
  final bool canImportExportExcel;
  final bool canExecuteTransfer;
  final bool canManageUsers;

  const UserPermission({
    this.canViewLedger = true,
    this.canAddTransaction = true,
    this.canEditTransaction = false,
    this.canDeleteTransaction = false,
    this.canImportExportExcel = false,
    this.canExecuteTransfer = false,
    this.canManageUsers = false,
  });

  static const UserPermission adminPermissions = UserPermission(
    canViewLedger: true,
    canAddTransaction: true,
    canEditTransaction: true,
    canDeleteTransaction: true,
    canImportExportExcel: true,
    canExecuteTransfer: true,
    canManageUsers: true,
  );

  static const UserPermission standardUserPermissions = UserPermission(
    canViewLedger: true,
    canAddTransaction: true,
    canEditTransaction: false,
    canDeleteTransaction: false,
    canImportExportExcel: false,
    canExecuteTransfer: false,
    canManageUsers: false,
  );

  UserPermission copyWith({
    bool? canViewLedger,
    bool? canAddTransaction,
    bool? canEditTransaction,
    bool? canDeleteTransaction,
    bool? canImportExportExcel,
    bool? canExecuteTransfer,
    bool? canManageUsers,
  }) {
    return UserPermission(
      canViewLedger: canViewLedger ?? this.canViewLedger,
      canAddTransaction: canAddTransaction ?? this.canAddTransaction,
      canEditTransaction: canEditTransaction ?? this.canEditTransaction,
      canDeleteTransaction: canDeleteTransaction ?? this.canDeleteTransaction,
      canImportExportExcel: canImportExportExcel ?? this.canImportExportExcel,
      canExecuteTransfer: canExecuteTransfer ?? this.canExecuteTransfer,
      canManageUsers: canManageUsers ?? this.canManageUsers,
    );
  }

  @override
  List<Object?> get props => [
        canViewLedger,
        canAddTransaction,
        canEditTransaction,
        canDeleteTransaction,
        canImportExportExcel,
        canExecuteTransfer,
        canManageUsers,
      ];
}

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String password;
  final String entityCode; // e.g. BS, MR, ES, MF
  final UserPermission permissions;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password = 'Imh@2026!Secured',
    required this.entityCode,
    required this.permissions,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? entityCode,
    UserPermission? permissions,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      entityCode: entityCode ?? this.entityCode,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [id, name, email, password, entityCode, permissions];
}

