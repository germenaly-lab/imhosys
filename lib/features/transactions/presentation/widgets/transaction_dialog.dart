import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/constants/app_accounts.dart';
import '../../../../core/constants/app_projects.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../models/transaction_model.dart';

class TransactionDialog extends StatefulWidget {
  final TransactionModel? transactionToEdit;
  final Function(TransactionModel) onSave;

  const TransactionDialog({
    super.key,
    this.transactionToEdit,
    required this.onSave,
  });

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedProject;
  late String _selectedAccount;
  late String _selectedPerson;
  late TransactionType _selectedType;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _egpController = TextEditingController(text: '0.00');
  final TextEditingController _eurController = TextEditingController(text: '0.00');
  final TextEditingController _usdController = TextEditingController(text: '0.00');

  final List<String> _responsiblePersons = [
    'Eng. Emad',
    'Eng. Mostafa',
    'Eng. Badawy',
    'Hanafy',
    'BS (Bishoy S.)',
    'MR (Mena R.)',
    'ES (Eng. Sameh)',
    'MF (Eng. Mostafa)',
    'AH (Ahmed H.)',
    'Finance Dept',
    'Office Admin',
    'Treasury Manager',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _selectedDate = t.date;
      _selectedCategory = t.category;
      _selectedProject = t.projectTag;
      _selectedAccount = t.sourceAccount;
      _selectedPerson = t.responsiblePerson;
      _selectedType = t.type;
      _descriptionController.text = t.description;
      _invoiceController.text = t.invoiceNumber;
      _egpController.text = t.amountEgp.toStringAsFixed(2);
      _eurController.text = t.amountEur.toStringAsFixed(2);
      _usdController.text = t.amountUsd.toStringAsFixed(2);
    } else {
      _selectedDate = DateTime.now();
      _selectedCategory = AppCategories.getAllSubcategories().first;
      _selectedProject = AppProjects.getProjectNames().first;
      _selectedAccount = AppAccounts.getAccountCodes().first;
      _selectedPerson = _responsiblePersons.first;
      _selectedType = TransactionType.expense;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _invoiceController.dispose();
    _egpController.dispose();
    _eurController.dispose();
    _usdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final isEditing = widget.transactionToEdit != null;

    return Dialog(
      backgroundColor: AppColors.getSurface(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 680,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isEditing ? Icons.edit_note : Icons.receipt_long,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEditing
                              ? AppTranslations.get('editTxnHeader', isArabic)
                              : AppTranslations.get('createTxnHeader', isArabic),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 32, color: AppColors.divider),

                // Transaction Type Selector
                Row(
                  children: [
                    _buildTypeChip(AppTranslations.get('expenseEntry', isArabic), TransactionType.expense, AppColors.error),
                    const SizedBox(width: 12),
                    _buildTypeChip(AppTranslations.get('revenueInflow', isArabic), TransactionType.revenue, AppColors.success),
                    const SizedBox(width: 12),
                    _buildTypeChip(AppTranslations.get('transferEntry', isArabic), TransactionType.transfer, AppColors.secondary),
                  ],
                ),

                const SizedBox(height: 20),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
                  decoration: InputDecoration(
                    labelText: AppTranslations.get('descLabel', isArabic),
                    hintText: AppTranslations.get('descHint', isArabic),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppTranslations.get('enterDescValidation', isArabic)
                      : null,
                ),

                const SizedBox(height: 16),

                // Date & Invoice Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: AppTranslations.get('dateLabel', isArabic),
                            suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                          ),
                          child: Text(
                            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _invoiceController,
                        style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
                        decoration: InputDecoration(
                          labelText: AppTranslations.get('invoiceLabel', isArabic),
                          hintText: AppTranslations.get('invoiceHint', isArabic),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Multi-Currency Inputs Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.getBackground(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.getDivider(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.get('multiCurrencyBox', isArabic),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _egpController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: AppTranslations.get('amountEgpLabel', isArabic),
                                prefixText: 'EGP ',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _eurController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: AppTranslations.get('amountEurLabel', isArabic),
                                prefixText: '€ ',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _usdController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: AppTranslations.get('amountUsdLabel', isArabic),
                                prefixText: '\$ ',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Dropdowns Grid
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13),
                        decoration: InputDecoration(labelText: AppTranslations.get('categoryLabel', isArabic)),
                        items: AppCategories.getAllSubcategories().map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(
                              AppCategories.getLocalizedName(c, isArabic),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedProject,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13),
                        decoration: InputDecoration(labelText: AppTranslations.get('projectTagLabel', isArabic)),
                        items: AppProjects.getProjectNames().map((p) {
                          return DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedProject = val);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedAccount,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13),
                        decoration: InputDecoration(labelText: AppTranslations.get('sourceAccountLabel', isArabic)),
                        items: AppAccounts.getAccountCodes().map((a) {
                          return DropdownMenuItem(value: a, child: Text(a));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedAccount = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPerson,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13),
                        decoration: InputDecoration(labelText: AppTranslations.get('responsiblePersonLabel', isArabic)),
                        items: _responsiblePersons.map((person) {
                          return DropdownMenuItem(value: person, child: Text(person));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPerson = val);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Save / Cancel Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        AppTranslations.get('cancelBtn', isArabic),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.check_circle, size: 18, color: Colors.white),
                      label: Text(
                        isEditing
                            ? AppTranslations.get('saveChangesBtn', isArabic)
                            : AppTranslations.get('addToLedgerBtn', isArabic),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, TransactionType type, Color color) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: AppColors.background,
      onSelected: (selected) {
        if (selected) setState(() => _selectedType = type);
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final double egp = double.tryParse(_egpController.text.trim()) ?? 0.0;
      final double eur = double.tryParse(_eurController.text.trim()) ?? 0.0;
      final double usd = double.tryParse(_usdController.text.trim()) ?? 0.0;

      final transaction = TransactionModel(
        id: widget.transactionToEdit?.id ?? 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        date: _selectedDate,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        amountEgp: egp,
        amountEur: eur,
        amountUsd: usd,
        invoiceNumber: _invoiceController.text.trim(),
        responsiblePerson: _selectedPerson,
        projectTag: _selectedProject,
        sourceAccount: _selectedAccount,
        type: _selectedType,
      );

      widget.onSave(transaction);
      Navigator.of(context).pop();
    }
  }
}
