import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/services/storage_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/finance_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await StorageService.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return PremiumScaffold(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          FinanceCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rype Account', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Portfolio, tax, and investment preferences', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Appearance'),
          const SizedBox(height: 10),
          FinanceCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                themeController.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Dark Theme'),
              subtitle: Text(
                themeController.isDark
                    ? 'Using the dark investment workspace'
                    : 'Using the clean white investment workspace',
              ),
              value: themeController.isDark,
              onChanged: (_) => themeController.toggle(),
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Preferences'),
          const SizedBox(height: 10),
          FinanceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Currency',
                  subtitle: 'Indian Rupee (INR)',
                  onTap: () {},
                ),
                Divider(height: 1, color: context.finance.border),
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Price Alerts',
                  subtitle: 'Coming soon',
                  onTap: () {},
                ),
                Divider(height: 1, color: context.finance.border),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'JWT protected account access',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Developer'),
          const SizedBox(height: 10),
          FinanceCard(
            child: Row(
              children: [
                Icon(Icons.dns_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('API Endpoint', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(ApiConstants.baseUrl, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FinanceCard(
            child: _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out from this device',
              iconColor: context.finance.danger,
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Theme.of(context).colorScheme.primary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: color),
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
