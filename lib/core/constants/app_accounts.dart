import 'package:flutter/material.dart';

class AppAccount {
  final String code;
  final String name;
  final String type; // 'Bank', 'Treasury', 'Sub-Account'
  final String responsiblePerson;
  final IconData icon;

  const AppAccount({
    required this.code,
    required this.name,
    required this.type,
    required this.responsiblePerson,
    required this.icon,
  });
}

class AppAccounts {
  static const List<AppAccount> accounts = [
    AppAccount(code: 'CIB-EGP', name: 'CIB Main Bank Account (EGP)', type: 'Bank', responsiblePerson: 'Finance Dept', icon: Icons.account_balance),
    AppAccount(code: 'CIB-EUR', name: 'CIB Foreign Account (EUR)', type: 'Bank', responsiblePerson: 'Finance Dept', icon: Icons.euro),
    AppAccount(code: 'CIB-USD', name: 'CIB Foreign Account (USD)', type: 'Bank', responsiblePerson: 'Finance Dept', icon: Icons.attach_money),
    AppAccount(code: 'QNB-EGP', name: 'QNB Corporate Account (EGP)', type: 'Bank', responsiblePerson: 'Treasury Manager', icon: Icons.account_balance),
    AppAccount(code: 'CASH-VAULT', name: 'Main Office Petty Cash Vault', type: 'Treasury', responsiblePerson: 'Office Admin', icon: Icons.payments),
    AppAccount(code: 'BS', name: 'Responsible Entity: BS Account', type: 'Sub-Account', responsiblePerson: 'BS (Bishoy S.)', icon: Icons.person),
    AppAccount(code: 'MR', name: 'Responsible Entity: MR Account', type: 'Sub-Account', responsiblePerson: 'MR (Mena R.)', icon: Icons.person),
    AppAccount(code: 'ES', name: 'Responsible Entity: ES Account', type: 'Sub-Account', responsiblePerson: 'ES (Eng. Sameh)', icon: Icons.person_outline),
    AppAccount(code: 'MF', name: 'Responsible Entity: MF Account', type: 'Sub-Account', responsiblePerson: 'MF (Eng. Mostafa)', icon: Icons.engineering),
    AppAccount(code: 'AH', name: 'Responsible Entity: AH Account', type: 'Sub-Account', responsiblePerson: 'AH (Ahmed H.)', icon: Icons.person),
  ];

  static List<String> getAccountCodes() {
    return accounts.map((e) => e.code).toList();
  }
}
