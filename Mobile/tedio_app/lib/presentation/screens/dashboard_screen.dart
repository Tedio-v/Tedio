import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/insights_provider.dart';
import '../widgets/insight_card.dart';
import '../widgets/app_drawer.dart';
import 'insight_detail_screen.dart';
import '../../data/models/insight_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final authProvider = context.read<AuthProvider>();
    final insightsProvider = context.read<InsightsProvider>();
    
    if (authProvider.token != null) {
      await insightsProvider.loadInsights(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final insightsProvider = context.watch<InsightsProvider>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text('${authProvider.currentUser?.childName ?? 'Child'}\'s YouTube Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsights,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInsights,
        child: insightsProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : insightsProvider.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
                        const SizedBox(height: 16),
                        Text(
                          insightsProvider.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadInsights,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _buildInsightsList(insightsProvider),
      ),
    );
  }


  Widget _buildInsightsList(InsightsProvider provider) {
    final hasData = provider.insights.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Show upload banner if no data
        if (!hasData) ...[
          _buildUploadBanner(),
          const SizedBox(height: 16),
        ],

        if (hasData) ...[
          _buildSummaryCard(provider),
          const SizedBox(height: 16),
        ],

        // Always show 4 clue cards
        if (hasData) ...[
          if (provider.highSeverityInsights.isNotEmpty) ...[
            _buildSeveritySection('High Priority', AppColors.danger, provider.highSeverityInsights),
            const SizedBox(height: 16),
          ],

          if (provider.moderateSeverityInsights.isNotEmpty) ...[
            _buildSeveritySection('Moderate', AppColors.warning, provider.moderateSeverityInsights),
            const SizedBox(height: 16),
          ],

          if (provider.lowSeverityInsights.isNotEmpty) ...[
            _buildSeveritySection('Low', AppColors.success, provider.lowSeverityInsights),
          ],
        ] else ...[
          // Show placeholder cards when no data
          _buildPlaceholderCards(),
        ],
      ],
    );
  }

  String _generateSummaryLine(List<InsightModel> insights) {
    final user = context.read<AuthProvider>().currentUser;
    final name = user?.childName ?? 'your child';
    
    if (insights.isEmpty) {
      return 'Analyzing $name\'s viewing patterns...';
    }
    
    InsightModel? rsi;
    InsightModel? ladder;
    
    try {
      rsi = insights.firstWhere(
        (i) => i.name.toLowerCase().contains('rapid swipe'),
      );
    } catch (e) {
      rsi = null;
    }
    
    try {
      ladder = insights.firstWhere(
        (i) => i.name.toLowerCase().contains('short-ladder') || i.name.toLowerCase().contains('shorts'),
      );
    } catch (e) {
      ladder = null;
    }

    // Extract insights data for summary
    final rapidSwipeScore = rsi?.matchScore.round() ?? 0;
    final hasLadderPattern = ladder != null;
    
    if (rapidSwipeScore >= 60 && hasLadderPattern) {
      return '$name tends to rapidly browse content and gets caught in short-form video cycles.';
    } else if (rapidSwipeScore >= 40) {
      return '$name shows some rapid browsing behavior that may benefit from structured viewing.';
    } else {
      return '$name demonstrates healthy viewing habits with deliberate content selection.';
    }
  }

  Widget _buildSummaryCard(InsightsProvider provider) {
    final insights = provider.insights;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What we noticed from your child\'s watch history',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentSlate.withOpacity(0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.link.withOpacity(0.25)),
              ),
              child: Text(
                _generateSummaryLine(insights),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Insight distribution',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  label: '🔴 High',
                  value: provider.highSeverityInsights.length.toString(),
                  color: AppColors.danger,
                ),
                _buildStatItem(
                  context,
                  label: '🟡 Moderate',
                  value: provider.moderateSeverityInsights.length.toString(),
                  color: AppColors.warning,
                ),
                _buildStatItem(
                  context,
                  label: '🟢 Low',
                  value: provider.lowSeverityInsights.length.toString(),
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildSeveritySection(String title, Color color, List<dynamic> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
        const SizedBox(height: 8),
        ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InsightCard(
                insight: insight,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InsightDetailScreen(insightId: insight.id),
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }


  Widget _buildUploadBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brand.withOpacity(0.1),
            AppColors.accentMint.withOpacity(0.15),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brand.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brand.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.upload_file,
              color: AppColors.brand,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload YouTube History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.brand,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get personalized insights about viewing patterns',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.brand),
            onPressed: () => Navigator.pushNamed(context, '/onboarding'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCards() {
    final placeholders = [
      {
        'icon': '🔄',
        'title': 'Rapid Swipe',
        'subtitle': 'Quick browsing patterns',
        'color': AppColors.danger,
        'id': 'rapid-swipe',
      },
      {
        'icon': '📊',
        'title': 'Short-Ladder',
        'subtitle': 'Short-form video cycles',
        'color': AppColors.warning,
        'id': 'short-ladder',
      },
      {
        'icon': '⚠️',
        'title': 'Distraction',
        'subtitle': 'Attention span patterns',
        'color': AppColors.warning,
        'id': 'distraction',
      },
      {
        'icon': '⏱️',
        'title': 'Time Spent',
        'subtitle': 'Usage duration analysis',
        'color': AppColors.link,
        'id': 'time-spent',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: placeholders.length,
      itemBuilder: (context, index) {
        final item = placeholders[index];
        return _buildPlaceholderCard(
          icon: item['icon'] as String,
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          color: item['color'] as Color,
          id: item['id'] as String,
        );
      },
    );
  }

  Widget _buildPlaceholderCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required String id,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to detail screen even without data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsightDetailScreen(insightId: id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.muted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.brand,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
