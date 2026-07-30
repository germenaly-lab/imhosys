import 'package:equatable/equatable.dart';

class UserPermission extends Equatable {
  final bool canViewLedger;
  final bool canAddTransaction;
  final bool canEditTransaction;
  final bool canDeleteTransaction;
  final bool canImportExportExcel;
  final bool canExecuteTransfer;
  final bool canManageUsers;
  final bool canViewVaultBalances;
  final bool canViewProjectRevenues;

  const UserPermission({
    this.canViewLedger = true,
    this.canAddTransaction = true,
    this.canEditTransaction = false,
    this.canDeleteTransaction = false,
    this.canImportExportExcel = false,
    this.canExecuteTransfer = false,
    this.canManageUsers = false,
    this.canViewVaultBalances = false,
    this.canViewProjectRevenues = false,
  });

  static const UserPermission adminPermissions = UserPermission(
    canViewLedger: true,
    canAddTransaction: true,
    canEditTransaction: true,
    canDeleteTransaction: true,
    canImportExportExcel: true,
    canExecuteTransfer: true,
    canManageUsers: true,
    canViewVaultBalances: true,
    canViewProjectRevenues: true,
  );

  static const UserPermission standardUserPermissions = UserPermission(
    canViewLedger: true,
    canAddTransaction: true,
    canEditTransaction: false,
    canDeleteTransaction: false,
    canImportExportExcel: false,
    canExecuteTransfer: false,
    canManageUsers: false,
    canViewVaultBalances: false,
    canViewProjectRevenues: false,
  );

  UserPermission copyWith({
    bool? canViewLedger,
    bool? canAddTransaction,
    bool? canEditTransaction,
    bool? canDeleteTransaction,
    bool? canImportExportExcel,
    bool? canExecuteTransfer,
    bool? canManageUsers,
    bool? canViewVaultBalances,
    bool? canViewProjectRevenues,
  }) {
    return UserPermission(
      canViewLedger: canViewLedger ?? this.canViewLedger,
      canAddTransaction: canAddTransaction ?? this.canAddTransaction,
      canEditTransaction: canEditTransaction ?? this.canEditTransaction,
      canDeleteTransaction: canDeleteTransaction ?? this.canDeleteTransaction,
      canImportExportExcel: canImportExportExcel ?? this.canImportExportExcel,
      canExecuteTransfer: canExecuteTransfer ?? this.canExecuteTransfer,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canViewVaultBalances: canViewVaultBalances ?? this.canViewVaultBalances,
      canViewProjectRevenues: canViewProjectRevenues ?? this.canViewProjectRevenues,
    );
  }

  Map<String, dynamic> toJson() => {
        'canViewLedger': canViewLedger,
        'canAddTransaction': canAddTransaction,
        'canEditTransaction': canEditTransaction,
        'canDeleteTransaction': canDeleteTransaction,
        'canImportExportExcel': canImportExportExcel,
        'canExecuteTransfer': canExecuteTransfer,
        'canManageUsers': canManageUsers,
        'canViewVaultBalances': canViewVaultBalances,
        'canViewProjectRevenues': canViewProjectRevenues,
      };

  factory UserPermission.fromJson(Map<String, dynamic> json) => UserPermission(
        canViewLedger: json['canViewLedger'] as bool? ?? true,
        canAddTransaction: json['canAddTransaction'] as bool? ?? true,
        canEditTransaction: json['canEditTransaction'] as bool? ?? false,
        canDeleteTransaction: json['canDeleteTransaction'] as bool? ?? false,
        canImportExportExcel: json['canImportExportExcel'] as bool? ?? false,
        canExecuteTransfer: json['canExecuteTransfer'] as bool? ?? false,
        canManageUsers: json['canManageUsers'] as bool? ?? false,
        canViewVaultBalances: json['canViewVaultBalances'] as bool? ?? false,
        canViewProjectRevenues: json['canViewProjectRevenues'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        canViewLedger,
        canAddTransaction,
        canEditTransaction,
        canDeleteTransaction,
        canImportExportExcel,
        canExecuteTransfer,
        canManageUsers,
        canViewVaultBalances,
        canViewProjectRevenues,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'entityCode': entityCode,
        'permissions': permissions.toJson(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String? ?? 'Imh@2026!Secured',
        entityCode: json['entityCode'] as String,
        permissions: UserPermission.fromJson(Map<String, dynamic>.from(json['permissions'] as Map)),
      );

  @override
  List<Object?> get props => [id, name, email, password, entityCode, permissions];
}

