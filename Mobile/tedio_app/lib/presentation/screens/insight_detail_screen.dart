import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/insights_provider.dart';
import '../../data/models/insight_model.dart';

class InsightDetailScreen extends StatefulWidget {
  final String insightId;

  const InsightDetailScreen({
    super.key,
    required this.insightId,
  });

  @override
  State<InsightDetailScreen> createState() => _InsightDetailScreenState();
}

class _InsightDetailScreenState extends State<InsightDetailScreen> {
  int? _userRating;

  void _rateInsight(int rating) async {
    setState(() {
      _userRating = rating;
    });

    final authProvider = context.read<AuthProvider>();
    final insightsProvider = context.read<InsightsProvider>();
    
    if (authProvider.token != null) {
      await insightsProvider.rateInsight(
        authProvider.token!,
        widget.insightId,
        rating,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final insightsProvider = context.watch<InsightsProvider>();
    final insight = insightsProvider.getInsightById(widget.insightId);

    if (insight == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Insight')),
        body: _buildNoDataState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(insight.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSeverityHeader(insight),
            const SizedBox(height: 24),
            _buildScoreSection(insight),
            const SizedBox(height: 24),
            _buildMessageSection(insight),
            const SizedBox(height: 24),
            if (insight.intervention != null) ...[
              _buildInterventionSection(insight.intervention!),
              const SizedBox(height: 24),
            ],
            _buildRatingSection(insight),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityHeader(InsightModel insight) {
    final color = insight.severity.toLowerCase() == 'high'
        ? Colors.red
        : insight.severity.toLowerCase() == 'moderate'
            ? Colors.orange
            : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            insight.severityEmoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.severityLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Text(
                  'Severity Level',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(InsightModel insight) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: insight.scorePct / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                insight.scorePct >= 70
                    ? Colors.red
                    : insight.scorePct >= 40
                        ? Colors.orange
                        : Colors.green,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${insight.scorePct.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageSection(InsightModel insight) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What We Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              insight.message,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionSection(InsightIntervention intervention) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Why This Matters',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  intervention.whyItMatters,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'What You Can Do',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...intervention.whatYouCanDo.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            action,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.child_care, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Developmental Context',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  intervention.developmentalContext,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(InsightModel insight) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How relevant is this insight?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return IconButton(
                  onPressed: () => _rateInsight(rating),
                  icon: Icon(
                    Icons.star,
                    size: 32,
                    color: _userRating != null && rating <= _userRating!
                        ? Colors.amber
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            if (insight.averageRating != null) ...[
              const SizedBox(height: 12),
              Text(
                'Community rating: ${insight.averageRating!.toStringAsFixed(1)} ⭐ (${insight.totalRatings} ratings)',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your YouTube watch history to unlock this insight and get personalized recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/onboarding');
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload History'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}