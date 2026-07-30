import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/utils/password_generator.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../../models/user_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLoaded) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final users = state.users;
        final activeUser = state.activeUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'إدارة حسابات المستخدمين وصلاحيات الأدوار' : 'USER ACCOUNTS & PERMISSION MANAGEMENT',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'إمكانية إنشاء حسابات المستخدمين، تعيين كلمات المرور، وتفعيل أو تعطيل التوليد التلقائي'
                            : 'Create accounts, manage custom passwords, and enable/disable password generation',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (activeUser.permissions.canManageUsers)
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openPasswordGeneratorDialog(context),
                          icon: const Icon(Icons.key_rounded, size: 18, color: AppColors.secondary),
                          label: Text(
                            isArabic ? 'مولد كلمات المرور' : 'Password Generator',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.secondary),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openCreateUserDialog(context),
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: Colors.white),
                          label: Text(
                            isArabic ? 'إنشاء حساب جديد' : 'Create New Account',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Active Logged-in Profile Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isArabic ? 'الحساب النشط حالياً:' : 'CURRENTLY ACTIVE PROFILE:',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.primaryLight),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(
                                text: activeUser.permissions.canManageUsers ? 'FULL ACCESS' : 'STANDARD ACCESS',
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${activeUser.name} • (${activeUser.email})',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      isArabic ? 'اختر حساباً للتبديل أدناه ⬇️' : 'Switch profile below to test permissions ⬇️',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Users Cards & Permission Matrix
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isActive = user.id == activeUser.id;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive ? AppColors.primary : AppColors.divider,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info Header Row
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: const Icon(
                                Icons.person_outline,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(width: 10),
                                      const StatusBadge(
                                        text: 'USER',
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      StatusBadge(text: 'Entity: ${user.entityCode}', color: AppColors.textSecondary),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (!isActive)
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.read<UserBloc>().add(SwitchActiveUser(user.id));
                                },
                                icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.secondary),
                                label: Text(
                                  isArabic ? 'تبديل إلى هذا الحساب' : 'Switch to this Account',
                                  style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.secondary),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              )
                            else
                              const StatusBadge(text: 'ACTIVE PERSONA', color: AppColors.success, icon: Icons.check_circle),

                            if (activeUser.permissions.canManageUsers && users.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: isArabic ? 'مسح / حذف حساب المستخدم' : 'Delete / Clear User Account',
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                onPressed: () => _confirmDeleteUser(context, user, isArabic),
                              ),
                            ],
                          ],
                        ),

                        const Divider(color: AppColors.divider, height: 24),

                        // Action Bar: Configure Password & Permissions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isArabic ? 'مصفوفة الصلاحيات الممنوحة:' : 'ASSIGNED PERMISSIONS MATRIX:',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary),
                            ),
                            if (activeUser.permissions.canManageUsers)
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _openChangePasswordDialog(context, user),
                                    icon: const Icon(Icons.password_rounded, size: 14, color: AppColors.secondary),
                                    label: Text(
                                      isArabic ? 'كلمة المرور' : 'Create/Edit Password',
                                      style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _openEditPermissionsDialog(context, user),
                                    icon: const Icon(Icons.tune_rounded, size: 14, color: AppColors.primaryLight),
                                    label: Text(
                                      isArabic ? 'تعديل الصلاحيات' : 'Configure Permissions',
                                      style: const TextStyle(fontSize: 11, color: AppColors.primaryLight),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Permission Chips Grid
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildPermissionChip(isArabic ? 'عرض السجل' : 'View Ledger', user.permissions.canViewLedger),
                            _buildPermissionChip(isArabic ? 'إضافة معاملة' : 'Add Entry', user.permissions.canAddTransaction),
                            _buildPermissionChip(isArabic ? 'تعديل المعاملات' : 'Edit Entries', user.permissions.canEditTransaction),
                            _buildPermissionChip(isArabic ? 'حذف المعاملات' : 'Delete Entries', user.permissions.canDeleteTransaction),
                            _buildPermissionChip(isArabic ? 'استيراد/تصدير إكسيل' : 'Excel Import/Export', user.permissions.canImportExportExcel),
                            _buildPermissionChip(isArabic ? 'تحويلات الخزينة' : 'Execute Transfers', user.permissions.canExecuteTransfer),
                            _buildPermissionChip(isArabic ? 'إدارة المستخدمين' : 'Manage Users', user.permissions.canManageUsers),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionChip(String label, bool isGranted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isGranted ? AppColors.success.withValues(alpha: 0.12) : AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGranted ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGranted ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: isGranted ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isGranted ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => const _CreateUserModal(),
    );
  }

  void _openPasswordGeneratorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => const _PasswordGeneratorModal(),
    );
  }

  void _openChangePasswordDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (dialogCtx) => _ChangePasswordModal(user: user),
    );
  }

  void _openEditPermissionsDialog(BuildContext context, UserModel targetUser) {
    showDialog(
      context: context,
      builder: (dialogCtx) => _EditPermissionsModal(user: targetUser),
    );
  }

  void _confirmDeleteUser(BuildContext context, UserModel user, bool isArabic) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'مسح / حذف حساب المستخدم' : 'Delete User Account',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'هل أنت تأكد من رغبتك في حذف حساب "${user.name}"؟'
              : 'Are you sure you want to delete/clear the user account for "${user.name}"?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.read<UserBloc>().add(DeleteUser(user.id));
              Navigator.of(dialogCtx).pop();
            },
            icon: const Icon(Icons.delete_forever, size: 16, color: Colors.white),
            label: Text(isArabic ? 'حذف الحساب' : 'Delete Account', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _PasswordGeneratorModal extends StatefulWidget {
  const _PasswordGeneratorModal();

  @override
  State<_PasswordGeneratorModal> createState() => _PasswordGeneratorModalState();
}

class _PasswordGeneratorModalState extends State<_PasswordGeneratorModal> {
  int _length = 16;
  bool _includeUpper = true;
  bool _includeLower = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _isDisabled = false;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  void _regenerate() {
    if (_isDisabled) return;
    setState(() {
      _generatedPassword = PasswordGenerator.generate(
        length: _length,
        includeUppercase: _includeUpper,
        includeLowercase: _includeLower,
        includeNumbers: _includeNumbers,
        includeSymbols: _includeSymbols,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return Dialog(
      backgroundColor: AppColors.surface,
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.key_rounded, color: AppColors.secondary, size: 24),
                const SizedBox(width: 10),
                Text(
                  isArabic ? 'مولد كلمات المرور (Password Generator)' : 'Secure Password Generator',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: AppColors.divider, height: 28),

            // Toggle Disable Password Generation Option
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                isArabic ? 'تعطيل مولد كلمات المرور' : 'Disable Password Generator',
                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _isDisabled
                    ? (isArabic ? 'مولد كلمات المرور معطل - أدخل كلمة المرور يدويًا' : 'Generator is DISABLED - create passwords manually')
                    : (isArabic ? 'مولد كلمات المرور مفعل' : 'Generator is ENABLED'),
                style: TextStyle(fontSize: 11, color: _isDisabled ? AppColors.warning : AppColors.success),
              ),
              value: _isDisabled,
              activeThumbColor: AppColors.warning,
              onChanged: (val) {
                setState(() {
                  _isDisabled = val;
                  if (!_isDisabled) _regenerate();
                });
              },
            ),

            const SizedBox(height: 16),

            if (!_isDisabled) ...[
              // Generated Password Display Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _generatedPassword,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.primaryLight,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: isArabic ? 'إعادة توليد' : 'Regenerate',
                      icon: const Icon(Icons.autorenew_rounded, color: AppColors.secondary),
                      onPressed: _regenerate,
                    ),
                    IconButton(
                      tooltip: isArabic ? 'نسخ الحافظة' : 'Copy to Clipboard',
                      icon: const Icon(Icons.copy_rounded, color: AppColors.success),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedPassword));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isArabic ? 'تم نسخ كلمة المرور إلى الحافظة! 🔑' : 'Password copied to clipboard! 🔑'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Length Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isArabic ? 'طول كلمة المرور: $_length حرف' : 'Password Length: $_length chars',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  StatusBadge(
                    text: _length >= 16 ? 'ULTRA SECURE' : (_length >= 12 ? 'STRONG' : 'WEAK'),
                    color: _length >= 16 ? AppColors.success : (_length >= 12 ? AppColors.secondary : AppColors.warning),
                  ),
                ],
              ),
              Slider(
                value: _length.toDouble(),
                min: 8,
                max: 32,
                divisions: 24,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.divider,
                onChanged: (val) {
                  setState(() => _length = val.toInt());
                  _regenerate();
                },
              ),

              const SizedBox(height: 12),

              // Character Set Checkboxes
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(isArabic ? 'حروف كبيرة (A-Z)' : 'Uppercase (A-Z)'),
                    selected: _includeUpper,
                    onSelected: (val) {
                      setState(() => _includeUpper = val);
                      _regenerate();
                    },
                  ),
                  FilterChip(
                    label: Text(isArabic ? 'حروف صغيرة (a-z)' : 'Lowercase (a-z)'),
                    selected: _includeLower,
                    onSelected: (val) {
                      setState(() => _includeLower = val);
                      _regenerate();
                    },
                  ),
                  FilterChip(
                    label: Text(isArabic ? 'أرقام (0-9)' : 'Numbers (0-9)'),
                    selected: _includeNumbers,
                    onSelected: (val) {
                      setState(() => _includeNumbers = val);
                      _regenerate();
                    },
                  ),
                  FilterChip(
                    label: Text(isArabic ? 'رموز خـاصة (!@#\$)' : 'Symbols (!@#\$)'),
                    selected: _includeSymbols,
                    onSelected: (val) {
                      setState(() => _includeSymbols = val);
                      _regenerate();
                    },
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'تم تعطيل توليد كلمات المرور. يمكنك كتابة وإنشاء كلمات المرور يدويًا في نماذج الحسابات.'
                            : 'Password generation is disabled. You can type and create custom passwords manually in account forms.',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isArabic ? 'إغلاق' : 'Close', style: const TextStyle(color: AppColors.textSecondary)),
                ),
                if (!_isDisabled) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _generatedPassword));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic ? 'تم نسخ كلمة المرور إلى الحافظة! 🔑' : 'Password copied to clipboard! 🔑'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                    label: Text(isArabic ? 'نسخ وإغلاق' : 'Copy & Close', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateUserModal extends StatefulWidget {
  const _CreateUserModal();

  @override
  State<_CreateUserModal> createState() => _CreateUserModalState();
}

class _CreateUserModalState extends State<_CreateUserModal> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _entityCtrl = TextEditingController(text: 'ES');
  bool _obscurePassword = true;
  bool _disableGenerator = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Dialog(
      backgroundColor: AppColors.surface,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_add_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 10),
                Text(
                  isArabic ? 'إنشاء حساب جديد' : 'Create New Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
            const Divider(color: AppColors.divider, height: 28),
            TextField(
              controller: _nameCtrl,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(labelText: isArabic ? 'الاسم الكامل *' : 'Full Name *'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailCtrl,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(labelText: isArabic ? 'البريد الإلكتروني *' : 'Email Address *'),
            ),
            const SizedBox(height: 14),

            // Permission Level Selection Dropdown
            DropdownButtonFormField<bool>(
              initialValue: _isAdmin,
              dropdownColor: AppColors.surface,
              style: TextStyle(color: textColor, fontSize: 13),
              decoration: InputDecoration(
                labelText: isArabic ? 'نوع حساب التخويل والصلاحيات *' : 'Permission Level & Role *',
                prefixIcon: Icon(_isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_outline_rounded, color: _isAdmin ? AppColors.primary : AppColors.secondary, size: 20),
              ),
              items: [
                DropdownMenuItem(
                  value: false,
                  child: Text(isArabic ? 'مستخدم عادي (إضافة وعرض فقط)' : 'Standard User (View & Add Entry Only)'),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text(isArabic ? 'مسؤول نظام (صلاحيات كاملة - Admin)' : 'Administrator (Full Access & Management)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _isAdmin = val;
                  });
                }
              },
            ),
            const SizedBox(height: 14),

            // Toggle Disable Password Generation
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                isArabic ? 'تعطيل التوليد التلقائي (إنشاء يدوي)' : 'Disable Auto Generation (Create Manually)',
                style: TextStyle(fontSize: 12, color: textColor),
              ),
              value: _disableGenerator,
              activeThumbColor: AppColors.warning,
              onChanged: (val) {
                setState(() {
                  _disableGenerator = val;
                  if (_disableGenerator) {
                    _passwordCtrl.clear();
                  }
                });
              },
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'كلمة المرور (إنشاء يدوي) *' : 'Create Password (Manual Entry) *',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: _disableGenerator
                      ? (isArabic ? 'توليد كلمات المرور معطل' : 'Generator Disabled')
                      : (isArabic ? 'توليد كلمة مرور قوية' : 'Generate Strong Password'),
                  icon: Icon(Icons.key, color: _disableGenerator ? AppColors.textSecondary : AppColors.secondary),
                  onPressed: _disableGenerator
                      ? null
                      : () {
                          final pass = PasswordGenerator.generate(length: 16);
                          setState(() {
                            _passwordCtrl.text = pass;
                            _obscurePassword = false;
                          });
                          Clipboard.setData(ClipboardData(text: pass));
                        },
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _entityCtrl,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(labelText: isArabic ? 'كود الجهة/الشخص المسؤول (مثال: BS, MR, ES)' : 'Entity Code (e.g. BS, MR, ES)'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_nameCtrl.text.trim().isNotEmpty) {
                      String finalPassword;
                      final manualPassword = _passwordCtrl.text.trim();

                      if (manualPassword.isNotEmpty) {
                        finalPassword = manualPassword;
                      } else if (!_disableGenerator) {
                        finalPassword = PasswordGenerator.generate(length: 16);
                      } else {
                        finalPassword = 'Imh@2026!Secured';
                      }

                      final newUser = UserModel(
                        id: 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                        name: _nameCtrl.text.trim(),
                        email: _emailCtrl.text.trim(),
                        password: finalPassword,
                        entityCode: _entityCtrl.text.trim().toUpperCase(),
                        permissions: _isAdmin ? UserPermission.adminPermissions : UserPermission.standardUserPermissions,
                      );
                      context.read<UserBloc>().add(AddUser(newUser));
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(isArabic ? 'إنشاء الحساب' : 'Create Account', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordModal extends StatefulWidget {
  final UserModel user;
  const _ChangePasswordModal({required this.user});

  @override
  State<_ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<_ChangePasswordModal> {
  late TextEditingController _passwordCtrl;
  bool _obscurePassword = true;
  bool _disableGenerator = false;

  @override
  void initState() {
    super.initState();
    _passwordCtrl = TextEditingController(text: widget.user.password);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return Dialog(
      backgroundColor: AppColors.surface,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.password_rounded, color: AppColors.primaryLight, size: 24),
                const SizedBox(width: 10),
                Text(
                  '${isArabic ? "إنشاء/تعديل كلمة المرور:" : "Create/Edit Password:"} ${widget.user.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: AppColors.divider, height: 28),

            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                isArabic ? 'تعطيل التوليد التلقائي (إنشاء يدوي)' : 'Disable Password Generation (Create Manually)',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              subtitle: Text(
                _disableGenerator
                    ? (isArabic ? 'التوليد التلقائي معطل - أدخل كلمة المرور يدويًا' : 'Generator disabled - type custom password manually')
                    : (isArabic ? 'التوليد التلقائي مفعل' : 'Auto-generator enabled'),
                style: TextStyle(fontSize: 10, color: _disableGenerator ? AppColors.warning : AppColors.success),
              ),
              value: _disableGenerator,
              activeThumbColor: AppColors.warning,
              onChanged: (val) {
                setState(() {
                  _disableGenerator = val;
                  if (val) {
                    _passwordCtrl.clear();
                  }
                });
              },
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'كلمة المرور الجديدة *' : 'New Password *',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: _disableGenerator
                      ? (isArabic ? 'توليد كلمات المرور معطل' : 'Password Generator Disabled')
                      : (isArabic ? 'توليد كلمة مرور' : 'Generate Password'),
                  icon: Icon(Icons.key, color: _disableGenerator ? AppColors.textSecondary : AppColors.secondary),
                  onPressed: _disableGenerator
                      ? null
                      : () {
                          final pass = PasswordGenerator.generate(length: 16);
                          setState(() {
                            _passwordCtrl.text = pass;
                            _obscurePassword = false;
                          });
                          Clipboard.setData(ClipboardData(text: pass));
                        },
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final manualPassword = _passwordCtrl.text.trim();
                    String finalPassword;

                    if (manualPassword.isNotEmpty) {
                      finalPassword = manualPassword;
                    } else if (!_disableGenerator) {
                      finalPassword = PasswordGenerator.generate(length: 16);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic ? 'يرجى إدخال كلمة المرور يدويًا!' : 'Please type a password manually!'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final updated = widget.user.copyWith(password: finalPassword);
                    context.read<UserBloc>().add(AddUser(updated));
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isArabic ? 'تم حفظ كلمة المرور بنجاح! 🔑' : 'Password saved successfully! 🔑'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(isArabic ? 'حفظ كلمة المرور' : 'Save Password', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditPermissionsModal extends StatefulWidget {
  final UserModel user;
  const _EditPermissionsModal({required this.user});

  @override
  State<_EditPermissionsModal> createState() => _EditPermissionsModalState();
}

class _EditPermissionsModalState extends State<_EditPermissionsModal> {
  late UserPermission _perm;

  @override
  void initState() {
    super.initState();
    _perm = widget.user.permissions;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return Dialog(
      backgroundColor: AppColors.surface,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.primaryLight, size: 24),
                const SizedBox(width: 10),
                Text(
                  '${isArabic ? "تعديل صلاحيات:" : "Configure Permissions:"} ${widget.user.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: AppColors.divider, height: 24),

            // Toggles
            _buildSwitch(isArabic ? 'عرض السجل المالي' : 'Can View Ledger', _perm.canViewLedger, (v) => setState(() => _perm = _perm.copyWith(canViewLedger: v))),
            _buildSwitch(isArabic ? 'إضافة معاملة جديدة' : 'Can Add Transactions', _perm.canAddTransaction, (v) => setState(() => _perm = _perm.copyWith(canAddTransaction: v))),
            _buildSwitch(isArabic ? 'تعديل المعاملات' : 'Can Edit Transactions', _perm.canEditTransaction, (v) => setState(() => _perm = _perm.copyWith(canEditTransaction: v))),
            _buildSwitch(isArabic ? 'حذف المعاملات' : 'Can Delete Transactions', _perm.canDeleteTransaction, (v) => setState(() => _perm = _perm.copyWith(canDeleteTransaction: v))),
            _buildSwitch(isArabic ? 'استيراد/تصدير ملفات إكسيل' : 'Can Import/Export Excel', _perm.canImportExportExcel, (v) => setState(() => _perm = _perm.copyWith(canImportExportExcel: v))),
            _buildSwitch(isArabic ? 'إجراء التحويلات بين الخزائن' : 'Can Execute Vault Transfers', _perm.canExecuteTransfer, (v) => setState(() => _perm = _perm.copyWith(canExecuteTransfer: v))),
            _buildSwitch(isArabic ? 'إدارة المستخدمين' : 'Can Manage Users & Permissions', _perm.canManageUsers, (v) => setState(() => _perm = _perm.copyWith(canManageUsers: v))),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserBloc>().add(UpdateUserPermissions(
                          userId: widget.user.id,
                          permissions: _perm,
                        ));
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(isArabic ? 'حفظ التعديلات' : 'Save Permissions', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.white)),
      value: value,
      activeThumbColor: AppColors.primaryLight,
      onChanged: onChanged,
    );
  }
}
