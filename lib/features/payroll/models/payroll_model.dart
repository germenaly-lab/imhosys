import 'package:equatable/equatable.dart';

enum PayrollStatus {
  pending,
  approved,
  paid,
}

extension PayrollStatusExtension on PayrollStatus {
  String getLocalizedName(bool isArabic) {
    switch (this) {
      case PayrollStatus.pending:
        return isArabic ? 'قيد المراجعة' : 'Pending Review';
      case PayrollStatus.approved:
        return isArabic ? 'معتمد للصرف' : 'Approved';
      case PayrollStatus.paid:
        return isArabic ? 'تم الصرف بالكامل' : 'Paid & Disbursed';
    }
  }
}

class PayrollModel extends Equatable {
  final String id;
  final String employeeName;
  final String jobTitle;
  final String department;
  final String payPeriod; // e.g. 'August 2026'
  final DateTime payDate;
  final String currency; // 'EGP', 'EUR', 'USD'
  final double baseSalary;
  final double siteAllowance;
  final double bonus;
  final double taxDeduction;
  final double insuranceDeduction;
  final double advanceDeduction;
  final double otherDeductions;
  final String paymentAccount;
  final PayrollStatus status;
  final String notes;

  const PayrollModel({
    required this.id,
    required this.employeeName,
    required this.jobTitle,
    required this.department,
    required this.payPeriod,
    required this.payDate,
    required this.currency,
    required this.baseSalary,
    this.siteAllowance = 0.0,
    this.bonus = 0.0,
    this.taxDeduction = 0.0,
    this.insuranceDeduction = 0.0,
    this.advanceDeduction = 0.0,
    this.otherDeductions = 0.0,
    required this.paymentAccount,
    this.status = PayrollStatus.paid,
    this.notes = '',
  });

  double get totalAllowances => siteAllowance + bonus;

  double get totalDeductions => taxDeduction + insuranceDeduction + advanceDeduction + otherDeductions;

  double get netSalary => baseSalary + totalAllowances - totalDeductions;

  PayrollModel copyWith({
    String? id,
    String? employeeName,
    String? jobTitle,
    String? department,
    String? payPeriod,
    DateTime? payDate,
    String? currency,
    double? baseSalary,
    double? siteAllowance,
    double? bonus,
    double? taxDeduction,
    double? insuranceDeduction,
    double? advanceDeduction,
    double? otherDeductions,
    String? paymentAccount,
    PayrollStatus? status,
    String? notes,
  }) {
    return PayrollModel(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      payPeriod: payPeriod ?? this.payPeriod,
      payDate: payDate ?? this.payDate,
      currency: currency ?? this.currency,
      baseSalary: baseSalary ?? this.baseSalary,
      siteAllowance: siteAllowance ?? this.siteAllowance,
      bonus: bonus ?? this.bonus,
      taxDeduction: taxDeduction ?? this.taxDeduction,
      insuranceDeduction: insuranceDeduction ?? this.insuranceDeduction,
      advanceDeduction: advanceDeduction ?? this.advanceDeduction,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      paymentAccount: paymentAccount ?? this.paymentAccount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeName': employeeName,
        'jobTitle': jobTitle,
        'department': department,
        'payPeriod': payPeriod,
        'payDate': payDate.toIso8601String(),
        'currency': currency,
        'baseSalary': baseSalary,
        'siteAllowance': siteAllowance,
        'bonus': bonus,
        'taxDeduction': taxDeduction,
        'insuranceDeduction': insuranceDeduction,
        'advanceDeduction': advanceDeduction,
        'otherDeductions': otherDeductions,
        'paymentAccount': paymentAccount,
        'status': status.name,
        'notes': notes,
      };

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    PayrollStatus status = PayrollStatus.paid;
    final statusStr = json['status'] as String?;
    if (statusStr != null) {
      status = PayrollStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => PayrollStatus.paid,
      );
    }

    return PayrollModel(
      id: json['id'] as String,
      employeeName: json['employeeName'] as String,
      jobTitle: json['jobTitle'] as String? ?? 'Engineer',
      department: json['department'] as String? ?? 'Engineering',
      payPeriod: json['payPeriod'] as String? ?? 'August 2026',
      payDate: DateTime.parse(json['payDate'] as String),
      currency: json['currency'] as String? ?? 'EGP',
      baseSalary: (json['baseSalary'] as num).toDouble(),
      siteAllowance: (json['siteAllowance'] as num?)?.toDouble() ?? 0.0,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0.0,
      taxDeduction: (json['taxDeduction'] as num?)?.toDouble() ?? 0.0,
      insuranceDeduction: (json['insuranceDeduction'] as num?)?.toDouble() ?? 0.0,
      advanceDeduction: (json['advanceDeduction'] as num?)?.toDouble() ?? 0.0,
      otherDeductions: (json['otherDeductions'] as num?)?.toDouble() ?? 0.0,
      paymentAccount: json['paymentAccount'] as String? ?? 'CIB-EGP',
      status: status,
      notes: json['notes'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeName,
        jobTitle,
        department,
        payPeriod,
        payDate,
        currency,
        baseSalary,
        siteAllowance,
        bonus,
        taxDeduction,
        insuranceDeduction,
        advanceDeduction,
        otherDeductions,
        paymentAccount,
        status,
        notes,
      ];
}
