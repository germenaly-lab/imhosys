import 'package:equatable/equatable.dart';

enum TransactionType { expense, revenue, transfer }

extension TransactionTypeExtension on TransactionType {
  String get name {
    switch (this) {
      case TransactionType.expense:
        return 'expense';
      case TransactionType.revenue:
        return 'revenue';
      case TransactionType.transfer:
        return 'transfer';
    }
  }
}


class TransactionModel extends Equatable {
  final String id;
  final DateTime date;
  final String category;
  final String description;
  final double amountEgp;
  final double amountEur;
  final double amountUsd;
  final String invoiceNumber;
  final String responsiblePerson;
  final String projectTag;
  final String sourceAccount;
  final TransactionType type;

  const TransactionModel({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amountEgp,
    required this.amountEur,
    required this.amountUsd,
    required this.invoiceNumber,
    required this.responsiblePerson,
    required this.projectTag,
    required this.sourceAccount,
    this.type = TransactionType.expense,
  });

  // Calculate equivalent total in a primary currency for dashboard total calculations
  // Assuming estimated reference exchange rates if multi-currency conversion is needed for unified total
  double totalInEgp({double eurToEgp = 52.5, double usdToEgp = 48.2}) {
    return amountEgp + (amountEur * eurToEgp) + (amountUsd * usdToEgp);
  }

  TransactionModel copyWith({
    String? id,
    DateTime? date,
    String? category,
    String? description,
    double? amountEgp,
    double? amountEur,
    double? amountUsd,
    String? invoiceNumber,
    String? responsiblePerson,
    String? projectTag,
    String? sourceAccount,
    TransactionType? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      amountEgp: amountEgp ?? this.amountEgp,
      amountEur: amountEur ?? this.amountEur,
      amountUsd: amountUsd ?? this.amountUsd,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      projectTag: projectTag ?? this.projectTag,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
      'amountEgp': amountEgp,
      'amountEur': amountEur,
      'amountUsd': amountUsd,
      'invoiceNumber': invoiceNumber,
      'responsiblePerson': responsiblePerson,
      'projectTag': projectTag,
      'sourceAccount': sourceAccount,
      'type': type.name,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      description: json['description'] as String,
      amountEgp: (json['amountEgp'] as num).toDouble(),
      amountEur: (json['amountEur'] as num).toDouble(),
      amountUsd: (json['amountUsd'] as num).toDouble(),
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      responsiblePerson: json['responsiblePerson'] as String,
      projectTag: json['projectTag'] as String,
      sourceAccount: json['sourceAccount'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        category,
        description,
        amountEgp,
        amountEur,
        amountUsd,
        invoiceNumber,
        responsiblePerson,
        projectTag,
        sourceAccount,
        type,
      ];
}
