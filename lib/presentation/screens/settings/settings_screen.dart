import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import 'profile_screen.dart';

/// Settings Screen
/// Comprehensive settings page with sections for profile, appearance, 
/// notifications, security, and about
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _transactionAlerts = true;
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.space16),

            // Profile Section
            _buildProfileCard(context, l10n, isDark),

            const SizedBox(height: AppTheme.space24),

            // Language Section
            _buildSectionHeader(l10n.language, isDark),
            _buildSettingsCard(
              isDark: isDark,
              children: [
                _buildLanguageTile(
                  context: context,
                  localeProvider: localeProvider,
                  isDark: isDark,
                  l10n: l10n,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.space24),

            // Notifications Section
            _buildSectionHeader(l10n.notifications, isDark),
            _buildSettingsCard(
              isDark: isDark,
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active_rounded,
                  iconColor: AppColors.primaryBlue,
                  title: l10n.pushNotifications,
                  value: _pushNotifications,
                  onChanged: (value) => setState(() => _pushNotifications = value),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  icon: Icons.email_rounded,
                  iconColor: AppColors.secondaryPurple,
                  title: l10n.emailNotifications,
                  value: _emailNotifications,
                  onChanged: (value) => setState(() => _emailNotifications = value),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  icon: Icons.payment_rounded,
                  iconColor: AppColors.success,
                  title: l10n.transactionAlerts,
                  value: _transactionAlerts,
                  onChanged: (value) => setState(() => _transactionAlerts = value),
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.space24),

            // Security Section
            _buildSectionHeader(l10n.security, isDark),
            _buildSettingsCard(
              isDark: isDark,
              children: [
                _buildNavigationTile(
                  icon: Icons.pin_rounded,
                  iconColor: AppColors.warning,
                  title: l10n.changePin,
                  onTap: () => _showComingSoonSnackbar(context),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  icon: Icons.fingerprint_rounded,
                  iconColor: AppColors.primaryTeal,
                  title: l10n.biometricAuth,
                  value: _biometricAuth,
                  onChanged: (value) => setState(() => _biometricAuth = value),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  icon: Icons.security_rounded,
                  iconColor: AppColors.info,
                  title: l10n.twoFactorAuth,
                  value: _twoFactorAuth,
                  onChanged: (value) => setState(() => _twoFactorAuth = value),
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.space24),

            // Help & Support Section
            _buildSectionHeader(l10n.helpSupport, isDark),
            _buildSettingsCard(
              isDark: isDark,
              children: [
                _buildNavigationTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.primaryBlue,
                  title: l10n.faq,
                  onTap: () => _showComingSoonSnackbar(context),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildNavigationTile(
                  icon: Icons.headset_mic_rounded,
                  iconColor: AppColors.success,
                  title: l10n.contactUs,
                  onTap: () => _showComingSoonSnackbar(context),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildNavigationTile(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.warning,
                  title: l10n.rateApp,
                  onTap: () => _showComingSoonSnackbar(context),
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.space24),

            // About Section
            _buildSectionHeader(l10n.about, isDark),
            _buildSettingsCard(
              isDark: isDark,
              children: [
                _buildNavigationTile(
                  icon: Icons.description_rounded,
                  iconColor: AppColors.grey500,
                  title: l10n.privacyPolicy,
                  onTap: () => _showComingSoonSnackbar(context),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildNavigationTile(
                  icon: Icons.gavel_rounded,
                  iconColor: AppColors.grey500,
                  title: l10n.termsOfService,
                  onTap: () => _showComingSoonSnackbar(context),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildInfoTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.grey500,
                  title: l10n.appVersion,
                  value: '1.0.0',
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.space24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, l10n),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.logout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.space16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.space16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.elevatedShadow(color: AppColors.primaryBlue),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppTheme.space16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profile,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.editProfile,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.white.withOpacity(0.8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space8,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow(),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required LocaleProvider localeProvider,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.space8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: const Icon(
          Icons.language_rounded,
          color: AppColors.primaryBlue,
          size: 24,
        ),
      ),
      title: Text(
        l10n.language,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      trailing: DropdownButton<Locale>(
        value: localeProvider.locale,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down_rounded),
        items: [
          DropdownMenuItem(
            value: const Locale('en'),
            child: Text(l10n.english),
          ),
          DropdownMenuItem(
            value: const Locale('ar'),
            child: Text(l10n.arabic),
          ),
        ],
        onChanged: (Locale? locale) {
          if (locale != null) {
            localeProvider.setLocale(locale);
          }
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.space8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryTeal,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.space8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.space8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      trailing: Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: AppTheme.space16 + 40 + AppTheme.space16,
      color: isDark ? AppColors.grey700.withOpacity(0.5) : AppColors.grey200,
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

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
