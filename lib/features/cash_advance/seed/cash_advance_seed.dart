import '../models/cash_advance_model.dart';

class CashAdvanceSeed {
  static List<CashAdvanceModel> getInitialAdvances() {
    final now = DateTime.now();

    return [
      CashAdvanceModel(
        id: 'ADV-2026-001',
        recipientName: 'Eng. Emad',
        title: 'Main Office Petty Cash Custody 2026',
        advanceType: CashAdvanceType.pettyCash,
        currency: 'EGP',
        initialAmount: 75000.0,
        dateDisbursed: now.subtract(const Duration(days: 15)),
        sourceAccount: 'CIB-EGP',
        projectTag: 'General HQ / Internal Overhead',
        status: CashAdvanceStatus.active,
        expenses: [
          CashAdvanceExpenseModel(
            id: 'EXP-101',
            date: now.subtract(const Duration(days: 10)),
            description: 'Emergency Electrical Supplies & Cables',
            category: 'Workshop Expenses',
            amount: 14500.0,
            invoiceNumber: 'INV-EGY-901',
            vendor: 'El-Sewedy Electric',
          ),
          CashAdvanceExpenseModel(
            id: 'EXP-102',
            date: now.subtract(const Duration(days: 5)),
            description: 'Office Catering & Client Meeting Hospitality',
            category: 'Office Expenses',
            amount: 3200.0,
            invoiceNumber: 'INV-HOSP-22',
            vendor: 'Metro Supermarket',
          ),
        ],
        notes: 'Monthly revolving petty cash custody for HQ operational expenses',
      ),
      CashAdvanceModel(
        id: 'ADV-2026-002',
        recipientName: 'Eng. Mostafa',
        title: 'Jubail PCS Upgrade Site Travel & Logistics Advance',
        advanceType: CashAdvanceType.projectAdvance,
        currency: 'USD',
        initialAmount: 12000.0,
        dateDisbursed: now.subtract(const Duration(days: 8)),
        sourceAccount: 'CIB-USD',
        projectTag: 'Jubail PCS Upgrade',
        status: CashAdvanceStatus.active,
        expenses: [
          CashAdvanceExpenseModel(
            id: 'EXP-201',
            date: now.subtract(const Duration(days: 6)),
            description: 'Site Accommodation & SUV Car Rental in Jubail',
            category: 'Travel & Lodging',
            amount: 3400.0,
            invoiceNumber: 'INV-KSA-441',
            vendor: 'Avis Car Rental KSA',
          ),
          CashAdvanceExpenseModel(
            id: 'EXP-202',
            date: now.subtract(const Duration(days: 3)),
            description: 'Local Testing Tools & Safety Equipment',
            category: 'Equipment Rental',
            amount: 1850.0,
            invoiceNumber: 'INV-JUB-091',
            vendor: 'KSA Industrial Supplies',
          ),
        ],
        notes: 'Site advance for Saudi Arabia trip commissioning team',
      ),
      CashAdvanceModel(
        id: 'ADV-2026-003',
        recipientName: 'Eng. Badawy',
        title: 'Senegal Cement Commissioning Advance',
        advanceType: CashAdvanceType.temporaryAdvance,
        currency: 'EUR',
        initialAmount: 8500.0,
        dateDisbursed: now.subtract(const Duration(days: 12)),
        sourceAccount: 'CIB-EUR',
        projectTag: 'FCB Senegal Cement Plant',
        status: CashAdvanceStatus.active,
        expenses: [
          CashAdvanceExpenseModel(
            id: 'EXP-301',
            date: now.subtract(const Duration(days: 7)),
            description: 'Site Transport & Local Subcontractor Daily Allowance',
            category: 'Site Expenses',
            amount: 2900.0,
            invoiceNumber: 'INV-SN-881',
            vendor: 'Dakar Transit Services',
          ),
        ],
        notes: 'Temporary site advance for West Africa commissioning stage',
      ),
      CashAdvanceModel(
        id: 'ADV-2026-004',
        recipientName: 'Hanafy',
        title: 'Workshop Maintenance & Spare Motors Emergency Cash',
        advanceType: CashAdvanceType.emergencyAdvance,
        currency: 'EGP',
        initialAmount: 30000.0,
        dateDisbursed: now.subtract(const Duration(days: 4)),
        sourceAccount: 'CIB-EGP',
        projectTag: 'SCC - ABB Contactor Upgrade',
        status: CashAdvanceStatus.active,
        expenses: [
          CashAdvanceExpenseModel(
            id: 'EXP-401',
            date: now.subtract(const Duration(days: 2)),
            description: 'Fast-track Motor Rewinding & Bearings Replacement',
            category: 'Spare Parts & Maintenance',
            amount: 12800.0,
            invoiceNumber: 'INV-MAINT-102',
            vendor: 'Cairo Motor Workshop',
          ),
        ],
        notes: 'Emergency advance for urgent motor maintenance',
      ),
    ];
  }
}
