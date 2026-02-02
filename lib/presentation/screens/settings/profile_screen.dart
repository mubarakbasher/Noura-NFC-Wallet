import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';

/// Profile Screen
/// Allows users to view and edit their profile information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    
    // Load user data from auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _fullNameController.text = authState.fullName;
      _emailController.text = authState.email;
      // Phone would come from a user profile API in a real app
      _phoneController.text = '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: l10n.editProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                setState(() => _isEditing = false);
                _loadUserData(); // Reset to original values
              },
              tooltip: l10n.cancel,
            ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppTheme.space24),

                // Profile Avatar Section
                _buildAvatarSection(l10n, isDark),

                const SizedBox(height: AppTheme.space32),

                // Profile Form
                _buildProfileForm(context, l10n, isDark, state),

                const SizedBox(height: AppTheme.space24),

                // Account Info Card
                _buildAccountInfoCard(l10n, isDark, state),

                const SizedBox(height: AppTheme.space24),

                // Delete Account Button
                _buildDeleteAccountButton(l10n, isDark),

                const SizedBox(height: AppTheme.space32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSection(AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        // Avatar with edit overlay
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.elevatedShadow(color: AppColors.primaryBlue),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.white,
                size: 64,
              ),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showChangePhotoOptions(context, l10n),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.space8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        if (_isEditing) ...[
          const SizedBox(height: AppTheme.space12),
          TextButton(
            onPressed: () => _showChangePhotoOptions(context, l10n),
            child: Text(
              l10n.changePhoto,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileForm(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    Authenticated state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.personalInfo,
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.space16),

            // Form Card
            Container(
              padding: const EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.cardShadow(),
              ),
              child: Column(
                children: [
                  // Full Name Field
                  _buildFormField(
                    controller: _fullNameController,
                    label: l10n.fullName,
                    icon: Icons.person_outline_rounded,
                    enabled: _isEditing,
                    isDark: isDark,
                    validator: (value) => Validators.validateRequired(value, l10n.fullName),
                  ),

                  const SizedBox(height: AppTheme.space16),

                  // Email Field (read-only)
                  _buildFormField(
                    controller: _emailController,
                    label: l10n.email,
                    icon: Icons.email_outlined,
                    enabled: false, // Email should not be editable
                    isDark: isDark,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: AppTheme.space16),

                  // Phone Field
                  _buildFormField(
                    controller: _phoneController,
                    label: l10n.phoneNumber,
                    icon: Icons.phone_outlined,
                    enabled: _isEditing,
                    isDark: isDark,
                    keyboardType: TextInputType.phone,
                    hint: '+249 XX XXX XXXX',
                  ),
                ],
              ),
            ),

            // Save Button
            if (_isEditing) ...[
              const SizedBox(height: AppTheme.space24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.space16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          l10n.saveChanges,
                          style: AppTextStyles.button.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    required bool isDark,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyLarge.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: enabled
              ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
              : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
        ),
        filled: true,
        fillColor: enabled
            ? (isDark ? AppColors.grey800 : AppColors.grey50)
            : (isDark ? AppColors.grey800.withOpacity(0.5) : AppColors.grey100),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard(AppLocalizations l10n, bool isDark, Authenticated state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.cardShadow(),
        ),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.badge_outlined,
              label: 'User ID',
              value: state.userId.substring(0, 8) + '...',
              isDark: isDark,
            ),
            const SizedBox(height: AppTheme.space12),
            Divider(
              color: isDark ? AppColors.grey700 : AppColors.grey200,
            ),
            const SizedBox(height: AppTheme.space12),
            _buildInfoRow(
              icon: Icons.verified_user_outlined,
              label: l10n.accountStatus,
              value: l10n.verified,
              valueColor: AppColors.success,
              isDark: isDark,
            ),
            const SizedBox(height: AppTheme.space12),
            Divider(
              color: isDark ? AppColors.grey700 : AppColors.grey200,
            ),
            const SizedBox(height: AppTheme.space12),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: l10n.memberSince,
              value: 'January 2026',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          size: 20,
        ),
        const SizedBox(width: AppTheme.space12),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteAccountButton(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      child: TextButton(
        onPressed: () => _showDeleteAccountDialog(context, l10n),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.error,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline_rounded, size: 20),
            const SizedBox(width: AppTheme.space8),
            Text(
              l10n.deleteAccount,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePhotoOptions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.space24),
              Text(
                l10n.changePhoto,
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: AppTheme.space24),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryBlue),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackbar(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.secondaryPurple),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackbar(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: AppColors.error),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackbar(context);
                },
              ),
              const SizedBox(height: AppTheme.space16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.error),
            const SizedBox(width: AppTheme.space8),
            Text(l10n.deleteAccount),
          ],
        ),
        content: Text(l10n.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonSnackbar(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });

      HapticFeedback.mediumImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    }
  }
}
