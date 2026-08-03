import 'package:equatable/equatable.dart';

enum CashAdvanceType {
  pettyCash,
  temporaryAdvance,
  projectAdvance,
  emergencyAdvance,
}

extension CashAdvanceTypeExtension on CashAdvanceType {
  String get keyName {
    switch (this) {
      case CashAdvanceType.pettyCash:
        return 'pettyCash';
      case CashAdvanceType.temporaryAdvance:
        return 'temporaryAdvance';
      case CashAdvanceType.projectAdvance:
        return 'projectAdvance';
      case CashAdvanceType.emergencyAdvance:
        return 'emergencyAdvance';
    }
  }

  String getLocalizedName(bool isArabic) {
    switch (this) {
      case CashAdvanceType.pettyCash:
        return isArabic ? 'عهدة مستديمة / نثرية' : 'Petty Cash Advance';
      case CashAdvanceType.temporaryAdvance:
        return isArabic ? 'عهدة مؤقتة' : 'Temporary Advance';
      case CashAdvanceType.projectAdvance:
        return isArabic ? 'عهدة مشروع مخصص' : 'Project Specific Advance';
      case CashAdvanceType.emergencyAdvance:
        return isArabic ? 'عهدة طارئة / شخصية' : 'Emergency & Misc Advance';
    }
  }
}

enum CashAdvanceStatus {
  active,
  fullySettled,
  overspent,
  closed,
}

extension CashAdvanceStatusExtension on CashAdvanceStatus {
  String getLocalizedName(bool isArabic) {
    switch (this) {
      case CashAdvanceStatus.active:
        return isArabic ? 'جارية / مفتوحة' : 'Active / In Use';
      case CashAdvanceStatus.fullySettled:
        return isArabic ? 'تم التسوية بالكامل' : 'Fully Settled';
      case CashAdvanceStatus.overspent:
        return isArabic ? 'تجاوزت المبلغ' : 'Overspent';
      case CashAdvanceStatus.closed:
        return isArabic ? 'مغلقة' : 'Closed';
    }
  }
}

class CashAdvanceExpenseModel extends Equatable {
  final String id;
  final DateTime date;
  final String description;
  final String category;
  final double amount;
  final String invoiceNumber;
  final String vendor;

  const CashAdvanceExpenseModel({
    required this.id,
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
    this.invoiceNumber = '',
    this.vendor = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'description': description,
        'category': category,
        'amount': amount,
        'invoiceNumber': invoiceNumber,
        'vendor': vendor,
      };

  factory CashAdvanceExpenseModel.fromJson(Map<String, dynamic> json) => CashAdvanceExpenseModel(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        description: json['description'] as String,
        category: json['category'] as String,
        amount: (json['amount'] as num).toDouble(),
        invoiceNumber: json['invoiceNumber'] as String? ?? '',
        vendor: json['vendor'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, date, description, category, amount, invoiceNumber, vendor];
}

class CashAdvanceModel extends Equatable {
  final String id;
  final String recipientName;
  final String title;
  final CashAdvanceType advanceType;
  final String currency; // 'EGP', 'EUR', 'USD'
  final double initialAmount;
  final DateTime dateDisbursed;
  final String sourceAccount;
  final String projectTag;
  final CashAdvanceStatus status;
  final List<CashAdvanceExpenseModel> expenses;
  final String notes;

  const CashAdvanceModel({
    required this.id,
    required this.recipientName,
    required this.title,
    required this.advanceType,
    required this.currency,
    required this.initialAmount,
    required this.dateDisbursed,
    required this.sourceAccount,
    this.projectTag = 'General HQ / Internal Overhead',
    this.status = CashAdvanceStatus.active,
    this.expenses = const [],
    this.notes = '',
  });

  double get totalSpent {
    return expenses.fold(0.0, (sum, exp) => sum + exp.amount);
  }

  double get remainingBalance {
    return initialAmount - totalSpent;
  }

  double get settlementPercentage {
    if (initialAmount <= 0) return 0.0;
    return (totalSpent / initialAmount * 100).clamp(0.0, 999.0);
  }

  CashAdvanceModel copyWith({
    String? id,
    String? recipientName,
    String? title,
    CashAdvanceType? advanceType,
    String? currency,
    double? initialAmount,
    DateTime? dateDisbursed,
    String? sourceAccount,
    String? projectTag,
    CashAdvanceStatus? status,
    List<CashAdvanceExpenseModel>? expenses,
    String? notes,
  }) {
    return CashAdvanceModel(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      title: title ?? this.title,
      advanceType: advanceType ?? this.advanceType,
      currency: currency ?? this.currency,
      initialAmount: initialAmount ?? this.initialAmount,
      dateDisbursed: dateDisbursed ?? this.dateDisbursed,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      projectTag: projectTag ?? this.projectTag,
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipientName': recipientName,
        'title': title,
        'advanceType': advanceType.keyName,
        'currency': currency,
        'initialAmount': initialAmount,
        'dateDisbursed': dateDisbursed.toIso8601String(),
        'sourceAccount': sourceAccount,
        'projectTag': projectTag,
        'status': status.name,
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'notes': notes,
      };

  factory CashAdvanceModel.fromJson(Map<String, dynamic> json) {
    CashAdvanceType type = CashAdvanceType.pettyCash;
    final typeStr = json['advanceType'] as String?;
    if (typeStr != null) {
      type = CashAdvanceType.values.firstWhere(
        (e) => e.keyName == typeStr || e.name == typeStr,
        orElse: () => CashAdvanceType.pettyCash,
      );
    }

    CashAdvanceStatus status = CashAdvanceStatus.active;
    final statusStr = json['status'] as String?;
    if (statusStr != null) {
      status = CashAdvanceStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => CashAdvanceStatus.active,
      );
    }

    return CashAdvanceModel(
      id: json['id'] as String,
      recipientName: json['recipientName'] as String,
      title: json['title'] as String? ?? 'Cash Advance',
      advanceType: type,
      currency: json['currency'] as String? ?? 'EGP',
      initialAmount: (json['initialAmount'] as num).toDouble(),
      dateDisbursed: DateTime.parse(json['dateDisbursed'] as String),
      sourceAccount: json['sourceAccount'] as String? ?? 'CIB-EGP',
      projectTag: json['projectTag'] as String? ?? 'General HQ / Internal Overhead',
      status: status,
      expenses: (json['expenses'] as List<dynamic>?)
              ?.map((e) => CashAdvanceExpenseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notes: json['notes'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        recipientName,
        title,
        advanceType,
        currency,
        initialAmount,
        dateDisbursed,
        sourceAccount,
        projectTag,
        status,
        expenses,
        notes,
      ];
}
