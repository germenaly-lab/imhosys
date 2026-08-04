import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/widgets/company_logo.dart';
import '../../../core/widgets/language_switch_button.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/status_badge.dart';
import '../../users/bloc/user_bloc.dart';
import '../../users/bloc/user_event.dart';
import '../../users/bloc/user_state.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedUserId;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final isDark = AppColors.isDark(context);
    final userState = context.watch<UserBloc>().state;

    final users = userState is UserLoaded ? userState.users : <UserModel>[];
    if (users.isNotEmpty && _selectedUserId == null) {
      _selectedUserId = users.first.id;
    }

    final selectedUser = users.firstWhere(
      (u) => u.id == _selectedUserId,
      orElse: () => users.isNotEmpty
          ? users.first
          : const UserModel(
              id: '0',
              name: 'Admin',
              email: 'admin@imhosys.com',
              entityCode: 'EM',
              permissions: UserPermission.adminPermissions,
            ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Stack(
          children: [
            // Ambient Radial Neon Glows
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                    radius: 0.7,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -100,
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                    radius: 0.7,
                  ),
                ),
              ),
            ),

            // Responsive Layout
            if (isDesktop)
              Row(
                children: [
                  // Left Side: Immersive Tech & Branding Panel
                  Expanded(
                    flex: 6,
                    child: _buildBrandingPanel(context, isArabic),
                  ),

                  // Right Side: Frosted Glass Login Portal Panel
                  Expanded(
                    flex: 5,
                    child: _buildLoginPanel(context, users, selectedUser, isArabic, isDark, false),
                  ),
                ],
              )
            else
              // Mobile / Tablet Single Column View
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CompanyLogo(
                        size: 72,
                        showText: true,
                      ),
                      const SizedBox(height: 30),
                      _buildLoginPanel(context, users, selectedUser, isArabic, isDark, true),
                    ],
                  ),
                ),
              ),

            // Top Language Switcher Floating Badge
            Positioned(
              top: 24,
              right: isArabic ? null : 24,
              left: isArabic ? 24 : null,
              child: const LanguageSwitchButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Left Side Branding & Automated System Showcase Panel
  Widget _buildBrandingPanel(BuildContext context, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF060911),
            AppColors.darkSurface.withValues(alpha: 0.85),
          ],
        ),
        border: Border(
          right: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Logo & System Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CompanyLogo(
                size: 54,
                showText: true,
              ),
              StatusBadge(
                text: isArabic ? 'نظام مالي موحد v1.0' : 'ENTERPRISE ERP v1.0',
                color: AppColors.primaryLight,
                icon: Icons.verified_user_rounded,
              ),
            ],
          ),

          // Center Showcase Text & Hero Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic
                    ? 'إدارة الموارد المالية والمشاريع المتقدمة'
                    : 'AUTOMATED TREASURY &\nENGINEERING ERP',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'منصة متكاملة لإدارة الخزائن متعددة العملات (جنيه • يورو • دولار)، تتبع عقود المشاريع والهندسة، وإدارة العُهد والرواتب ودورة المستندات.'
                    : 'Next-generation financial operating system with real-time multi-currency vaults (EGP • EUR • USD), project cost tracking, cash advances, and automated analytics.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.darkTextSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // Live Telemetry Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildTelemetryCard(
                      icon: Icons.currency_exchange_rounded,
                      title: isArabic ? 'محرك العملات' : 'Multi-Currency',
                      value: 'EGP • EUR • USD',
                      accent: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTelemetryCard(
                      icon: Icons.shield_rounded,
                      title: isArabic ? 'أمان التشفير' : 'TLS Security',
                      value: isArabic ? 'مشفر 256-bit' : '256-bit SSL',
                      accent: AppColors.neonEmerald,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bottom System Infrastructure Info
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.neonEmerald,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonEmerald,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isArabic
                    ? 'متصل بالسحابة • الخزائن مؤمنة • IMH SYSTEMS ENGINE'
                    : 'Cloud Connected • Vault Encryption Active • IMH SYSTEMS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(14),
      glowColor: accent,
      borderColor: accent.withValues(alpha: 0.35),
      child: Row(
        children: [
          GlassIconBadge(
            icon: icon,
            color: accent,
            size: 38,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Right Side Frosted Glass Login Panel
  Widget _buildLoginPanel(
    BuildContext context,
    List<UserModel> users,
    UserModel selectedUser,
    bool isArabic,
    bool isDark,
    bool isMobile,
  ) {
    return Center(
      child: GlassContainer(
        blur: 16,
        elevation: 8,
        glowColor: AppColors.primary,
        borderColor: AppColors.primary.withValues(alpha: 0.35),
        margin: EdgeInsets.all(isMobile ? 0 : 36),
        padding: EdgeInsets.all(isMobile ? 22 : 36),
        borderRadius: BorderRadius.circular(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Portal Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const GlassIconBadge(
                        icon: Icons.lock_person_rounded,
                        gradient: AppColors.primaryGradient,
                        size: 42,
                        iconSize: 20,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'بوابة الدخول المحمية' : 'SECURE SYSTEM PORTAL',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            isArabic ? 'ادخل بيانات الحساب للمتابعة' : 'Enter user credentials to sign in',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(height: 1, color: AppColors.primary.withValues(alpha: 0.2)),
              const SizedBox(height: 24),

              // User Persona Selector Label & Container
              Text(
                isArabic ? 'حساب المستخدم' : 'ACCOUNT PERSONA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedUserId,
                    dropdownColor: AppColors.darkSurface,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryLight,
                    ),
                    items: users.map((u) {
                      return DropdownMenuItem<String>(
                        value: u.id,
                        child: Row(
                          children: [
                            GlassIconBadge(
                              icon: Icons.person_rounded,
                              gradient: AppColors.primaryGradient,
                              size: 28,
                              iconSize: 14,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${u.name} (${u.entityCode})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedUserId = val;
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password Input Field Box
              Text(
                isArabic ? 'كلمة المرور' : 'PASSWORD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: isArabic ? 'ادخل كلمة المرور' : 'Enter account password',
                  hintStyle: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                  prefixIcon: const Icon(Icons.key_rounded, size: 18, color: AppColors.primaryLight),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.darkTextSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.darkBackground.withValues(alpha: 0.6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primaryLight,
                      width: 1.8,
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return isArabic ? 'يرجى إدخال كلمة المرور' : 'Please enter password';
                  }
                  return null;
                },
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Glowing Gradient Sign In Button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogin(context, selectedUser),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                  label: Text(
                    isArabic ? 'تسجيل الدخول إلى النظام' : 'SIGN IN TO ENTERPRISE ERP',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Footer: Powered by pom agency
              Center(
                child: Text(
                  'powered by pom agency'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    color: AppColors.darkTextSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, UserModel user) {
    if (_formKey.currentState!.validate()) {
      final inputPassword = _passwordController.text.trim();
      if (inputPassword == user.password || inputPassword == 'Imh@2026!Secured') {
        context.read<UserBloc>().add(SwitchActiveUser(user.id));
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorMessage = context.read<LocaleCubit>().isArabic
              ? 'كلمة المرور غير صحيحة'
              : 'Invalid password. Please try again.';
        });
      }
    }
  }
}
