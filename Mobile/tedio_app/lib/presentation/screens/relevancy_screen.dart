import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/insights_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';
import '../../data/models/insight_model.dart';

class RelevancyScreen extends StatefulWidget {
  const RelevancyScreen({super.key});

  @override
  State<RelevancyScreen> createState() => _RelevancyScreenState();
}

class _RelevancyScreenState extends State<RelevancyScreen> {
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
    final bool hasUploadedHistory = authProvider.currentUser?.firstLogin == false;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Insight Relevancy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsights,
          ),
        ],
      ),
      body: !hasUploadedHistory
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: AppColors.muted,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Upload History Required',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Relevancy analysis requires your child\'s YouTube watch history. Please upload it to access this feature.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/onboarding');
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload YouTube History'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadInsights,
              child: insightsProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : insightsProvider.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: ${insightsProvider.error}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.danger,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadInsights,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Understanding Insight Relevancy',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Each insight is scored based on how relevant it is to your child\'s viewing patterns.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                        ),
                        const SizedBox(height: 24),
                        ...insightsProvider.insights.map(
                          (insight) => _buildInsightRelevancyCard(insight),
                        ),
                        const SizedBox(height: 24),
                        _buildWeeklyPatternCard(insightsProvider.insights),
                      ],
                    ),
                  ),
            ),
    );
  }

  Widget _buildInsightRelevancyCard(InsightModel insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    insight.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _buildSeverityBadge(insight.severity),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              insight.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Relevancy Score',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: insight.matchScore / 100,
                        backgroundColor: AppColors.brand.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(insight.matchScore),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${insight.matchScore.round()}% relevancy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      'Weekly Pattern',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                    ),
                    const SizedBox(height: 4),
                    _buildSparkChart(insight.spark),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getInsightDescription(insight.name, insight.matchScore),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (insight.averageRating != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    'Community Rating: ${insight.averageRating!.toStringAsFixed(1)}/5',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    ' (${insight.totalRatings ?? 0} ratings)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color color;
    Color bgColor;
    
    switch (severity.toLowerCase()) {
      case 'high':
        color = AppColors.danger;
        bgColor = AppColors.danger.withOpacity(0.12);
        break;
      case 'moderate':
        color = AppColors.warning;
        bgColor = AppColors.warning.withOpacity(0.12);
        break;
      case 'low':
        color = AppColors.success;
        bgColor = AppColors.success.withOpacity(0.12);
        break;
      default:
        color = AppColors.brand;
        bgColor = AppColors.brand.withOpacity(0.06);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSparkChart(List<int> spark) {
    if (spark.isEmpty) return const SizedBox();
    
    final maxValue = spark.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return const SizedBox();
    
    return SizedBox(
      width: 60,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: spark.map((value) {
          final height = (value / maxValue) * 30;
          return Container(
            width: 6,
            height: height < 2 ? 2 : height,
            decoration: BoxDecoration(
              color: AppColors.link.withOpacity(0.6),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyPatternCard(List<InsightModel> insights) {
    // Find an insight with spark data for weekly pattern
    InsightModel? insightWithSpark;
    
    try {
      insightWithSpark = insights.firstWhere(
        (insight) => insight.spark.isNotEmpty,
      );
    } catch (e) {
      insightWithSpark = null;
    }

    if (insightWithSpark == null || insightWithSpark.spark.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Viewing Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyChart(context, insightWithSpark.spark),
            const SizedBox(height: 16),
            Text(
              'This chart shows the distribution of viewing activity across the week. Higher bars indicate more activity on those days.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List<int> spark) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final maxValue = spark.isNotEmpty ? spark.reduce((a, b) => a > b ? a : b) : 1;
    
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final value = index < spark.length ? spark[index] : 0;
          final height = maxValue > 0 ? (value / maxValue) * 80.0 : 0.0;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 20,
                height: height < 4 ? 4.0 : height,
                decoration: BoxDecoration(
                  color: AppColors.link.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${spark.fold(0, (a, b) => a + b) > 0 ? ((value / spark.fold(0, (a, b) => a + b)) * 100).round() : 0}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return AppColors.danger;
    if (score >= 40) return AppColors.warning;
    return AppColors.success;
  }

  String _getInsightDescription(String insightName, double matchScore) {
    final score = matchScore.round();
    
    if (insightName.contains('Rapid Swipe')) {
      if (score >= 70) return 'High rapid-swipe behavior detected - consider intervention strategies';
      if (score >= 40) return 'Moderate rapid-swipe patterns observed';
      return 'Minimal rapid-swipe behavior - healthy viewing pace';
    }
    
    if (insightName.contains('Short-Ladder') || insightName.contains('Shorts')) {
      if (score >= 70) return 'Heavy Shorts consumption pattern identified';
      if (score >= 40) return 'Notable Shorts viewing activity';
      return 'Limited Shorts engagement detected';
    }
    
    if (insightName.contains('Late-Night')) {
      if (score >= 70) return 'Significant late-night viewing concerns';
      if (score >= 40) return 'Some late-night viewing patterns';
      return 'Minimal late-night screen time';
    }
    
    if (insightName.contains('Single-Channel')) {
      if (score >= 70) return 'Very high channel concentration';
      if (score >= 40) return 'Moderate channel focus';
      return 'Diverse channel consumption';
    }
    
    if (insightName.contains('Thumbnail')) {
      if (score >= 70) return 'High thumbnail-driven viewing';
      if (score >= 40) return 'Some impulsive viewing patterns';
      return 'Deliberate content selection';
    }
    
    return 'Analysis based on viewing behavior patterns';
  }
}
