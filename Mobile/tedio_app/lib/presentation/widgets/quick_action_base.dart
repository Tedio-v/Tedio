import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';

class QuickActionBase extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final ValueChanged<bool?>? onCompletedChanged;
  final String? tutorialUrl;
  final String? tutorialTitle;
  final List<ResourceItem> resources;
  final List<Widget> content;

  const QuickActionBase({
    super.key,
    required this.title,
    required this.isCompleted,
    this.onCompletedChanged,
    this.tutorialUrl,
    this.tutorialTitle,
    this.resources = const [],
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completion status card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.brand.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brand.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: isCompleted ? AppColors.success : AppColors.muted,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Mark as completed',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Switch(
                    value: isCompleted,
                    onChanged: onCompletedChanged,
                    activeColor: AppColors.success,
                  ),
                ],
              ),
            ),

            // Tutorial section
            if (tutorialUrl != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Tutorial',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _launchURL(context, tutorialUrl!),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.brand.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withOpacity(0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.link.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: AppColors.link,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tutorialTitle ?? 'Watch Tutorial',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Resources section
            if (resources.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Resources',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...resources.map((resource) => GestureDetector(
                onTap: () => _launchURL(context, resource.url),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.brand.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accentSlate.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.article_outlined,
                          color: AppColors.link,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          resource.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
              )),
            ],

            // Main content
            ...content,

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }
}

class ResourceItem {
  final String title;
  final String url;

  const ResourceItem({
    required this.title,
    required this.url,
  });
}

class ContentCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ContentCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brand.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
