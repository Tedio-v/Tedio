import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.brand,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.surface,
                  child: Text(
                    user?.childName.isNotEmpty == true 
                        ? user!.childName[0].toUpperCase() 
                        : 'T',
                    style: AppTypography.brand(
                      fontSize: 28,
                      color: AppColors.brand,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.childName ?? 'Tedio User',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: '/dashboard',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.analytics,
            title: 'Relevancy',
            route: '/relevancy',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.flash_on,
            title: 'Quick Actions',
            route: '/quick-actions',
          ),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.speed, color: AppColors.brand),
            title: Text(
              'Rapid Swipe Actions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            collapsedIconColor: AppColors.muted,
            iconColor: AppColors.brand,
            textColor: AppColors.brand,
            children: [
              _buildSubItem(context, 'Remove Shorts', '/remove-shorts'),
              _buildSubItem(context, 'Waiting Time Kit', '/waiting-time-kit'),
              _buildSubItem(context, 'Pause & Predict', '/pause-predict'),
              _buildSubItem(context, 'Time Together', '/time-together'),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.view_list, color: AppColors.brand),
            title: Text(
              'Shorts Ladder Actions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            collapsedIconColor: AppColors.muted,
            iconColor: AppColors.brand,
            textColor: AppColors.brand,
            children: [
              _buildSubItem(context, 'Build Watchlist', '/build-watchlist'),
              _buildSubItem(context, 'Set Timer', '/set-timer'),
              _buildSubItem(context, 'Physical Timer', '/physical-timer'),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.nightlight, color: AppColors.brand),
            title: Text(
              'Late-Night Actions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            collapsedIconColor: AppColors.muted,
            iconColor: AppColors.brand,
            textColor: AppColors.brand,
            children: [
              _buildSubItem(context, 'Set Downtime', '/set-downtime'),
              _buildSubItem(context, 'Remove Devices', '/remove-devices'),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.casino, color: AppColors.brand),
            title: Text(
              'Thumbnail Roulette',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            collapsedIconColor: AppColors.muted,
            iconColor: AppColors.brand,
            textColor: AppColors.brand,
            children: [
              _buildSubItem(context, 'Block Channel', '/block-channel'),
            ],
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            route: '/settings',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == route;
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.secondary : AppColors.muted,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? colorScheme.secondary : AppColors.brand,
            ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.accentSlate.withOpacity(0.35),
      onTap: onTap ?? () {
        Navigator.pop(context); // Close drawer
        if (route != null && route != currentRoute) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Widget _buildSubItem(BuildContext context, String title, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == route;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: ListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colorScheme.secondary : AppColors.brand,
              ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.accentSlate.withOpacity(0.25),
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (route != currentRoute) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}
