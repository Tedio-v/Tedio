import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_drawer.dart';

class QuickActionsScreen extends StatelessWidget {
  const QuickActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Quick Actions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionCategory(
              context,
              title: 'Rapid Swipe',
              icon: Icons.speed,
              color: AppColors.warning,
              actions: [
                ActionItem(
                  title: 'Remove Shorts from Home',
                  route: '/remove-shorts',
                  icon: Icons.block,
                ),
                ActionItem(
                  title: 'Make "waiting-time kits"',
                  route: '/waiting-time-kit',
                  icon: Icons.toys,
                ),
                ActionItem(
                  title: 'Pause & Predict "30-second rule"',
                  route: '/pause-predict',
                  icon: Icons.pause_circle,
                ),
                ActionItem(
                  title: 'Suggest to do something together',
                  route: '/time-together',
                  icon: Icons.people,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActionCategory(
              context,
              title: 'Endless Shorts Ladder',
              icon: Icons.view_list,
              color: AppColors.link,
              actions: [
                ActionItem(
                  title: 'Build a watch list',
                  route: '/build-watchlist',
                  icon: Icons.playlist_add,
                ),
                ActionItem(
                  title: 'Use a 20-minute kitchen timer',
                  route: '/set-timer',
                  icon: Icons.timer,
                ),
                ActionItem(
                  title: 'Set a "Take-a-break" timer',
                  route: '/physical-timer',
                  icon: Icons.alarm,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActionCategory(
              context,
              title: 'Late-Night Minutes',
              icon: Icons.nightlight,
              color: AppColors.brand,
              actions: [
                ActionItem(
                  title: 'Set Screen-Time "Downtime"',
                  route: '/set-downtime',
                  icon: Icons.bedtime,
                ),
                ActionItem(
                  title: 'Remove devices from bedroom',
                  route: '/remove-devices',
                  icon: Icons.phone_disabled,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActionCategory(
              context,
              title: 'Thumbnail Roulette',
              icon: Icons.casino,
              color: AppColors.danger,
              actions: [
                ActionItem(
                  title: 'Block a Channel',
                  route: '/block-channel',
                  icon: Icons.block,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCategory(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<ActionItem> actions,
  }) {
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                  ),
                ),
              ],
            ),
          ),
          ...actions.map((action) => _buildActionTile(context, action, color)),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, ActionItem action, Color accentColor) {
    return ListTile(
      leading: Icon(action.icon, color: accentColor),
      title: Text(
        action.title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.muted),
      onTap: () {
        Navigator.pushNamed(context, action.route);
      },
    );
  }
}

class ActionItem {
  final String title;
  final String route;
  final IconData icon;

  ActionItem({
    required this.title,
    required this.route,
    required this.icon,
  });
}
