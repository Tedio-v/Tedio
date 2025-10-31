import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/insight_model.dart';

class InsightCard extends StatelessWidget {
  final InsightModel insight;
  final VoidCallback onTap;

  const InsightCard({
    super.key,
    required this.insight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                insight.severityEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildScoreChip(context, insight.scorePct),
                        const SizedBox(width: 8),
                        if (insight.averageRating != null)
                          _buildRatingChip(context, insight.averageRating!),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreChip(BuildContext context, double score) {
    final color = score >= 70
        ? AppColors.danger
        : score >= 40
            ? AppColors.warning
            : AppColors.success;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '${score.toStringAsFixed(0)}%',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRatingChip(BuildContext context, double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.link.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.link.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: AppColors.link),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 12,
                  color: AppColors.link,
                ),
          ),
        ],
      ),
    );
  }
}
