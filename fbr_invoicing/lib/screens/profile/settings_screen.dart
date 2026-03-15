import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final String _currency = 'PKR';

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSectionHeader('Application Preferences'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts for new FBR regulations'),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use darker colors for night viewing'),
            value: themeService.isDarkMode,
            onChanged: (val) => themeService.toggleTheme(val),
            activeThumbColor: AppColors.primary,
          ),
          ListTile(
            title: const Text('Default Currency'),
            subtitle: Text(_currency),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show currency picker
            },
          ),

          const Divider(),
          _buildSectionHeader('FBR API Configuration'),
          ListTile(
            leading: const Icon(Icons.api),
            title: const Text('API Base URL'),
            subtitle: const Text(
              'https://esp.fbr.gov.pk:8244/DigitalInvoicing',
            ),
            trailing: const Icon(Icons.edit, size: 20),
          ),
          ListTile(
            leading: const Icon(Icons.pin),
            title: const Text('POS ID'),
            subtitle: const Text('12345678 (Outlet Code)'),
            trailing: const Icon(Icons.edit, size: 20),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Integration Key / Token'),
            subtitle: const Text('••••••••••••••••'),
            trailing: const Icon(Icons.edit, size: 20),
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Business NTN'),
            subtitle: const Text('7654321-0'),
            trailing: const Icon(Icons.edit, size: 20),
          ),

          const Divider(),
          _buildSectionHeader('About'),
          const ListTile(
            title: Text('Version'),
            trailing: Text('1.0.0 (Stable)'),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new, size: 20),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 20),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
