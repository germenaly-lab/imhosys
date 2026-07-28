import 'package:equatable/equatable.dart';

class AccountModel extends Equatable {
  final String code;
  final String name;
  final String type; // 'Bank', 'Treasury', 'Sub-Account'
  final String responsiblePerson;
  final double balanceEgp;
  final double balanceEur;
  final double balanceUsd;

  const AccountModel({
    required this.code,
    required this.name,
    required this.type,
    required this.responsiblePerson,
    this.balanceEgp = 0.0,
    this.balanceEur = 0.0,
    this.balanceUsd = 0.0,
  });

  @override
  List<Object?> get props => [
        code,
        name,
        type,
        responsiblePerson,
        balanceEgp,
        balanceEur,
        balanceUsd,
      ];
}
