import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/quick_action_base.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/quick_action_service.dart';

class BuildWatchlistScreen extends StatefulWidget {
  const BuildWatchlistScreen({super.key});

  @override
  State<BuildWatchlistScreen> createState() => _BuildWatchlistScreenState();
}

class _BuildWatchlistScreenState extends State<BuildWatchlistScreen> {
  final QuickActionService _quickActionService = QuickActionService();
  bool _isCompleted = false;
  bool _isLoading = false;
  final String actionId = 'build-watchlist';

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  Future<void> _checkCompletionStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;
      if (token != null) {
        final completedActions = await _quickActionService.getCompletedActions(token);
        if (mounted) {
          setState(() {
            _isCompleted = completedActions.contains(actionId);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleCompletion(bool? value) async {
    if (value == null) return;

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;
      if (token != null) {
        if (value) {
          await _quickActionService.completeQuickAction(token, actionId);
        } else {
          await _quickActionService.uncompleteQuickAction(token, actionId);
        }
        setState(() {
          _isCompleted = value;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return QuickActionBase(
      title: 'Build a Watchlist',
      isCompleted: _isCompleted,
      onCompletedChanged: _toggleCompletion,
      tutorialUrl: 'https://www.youtube.com/watch?v=8SjNRHrFtCg',
      tutorialTitle: 'How to create a YouTube playlist',
      resources: const [
        ResourceItem(
          title: 'Common Sense Media - Best YouTube Channels',
          url: 'https://www.commonsensemedia.org/lists/best-youtube-channels-for-kids',
        ),
      ],
      content: [
        ContentCard(
          title: 'How to do it',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep('1', 'Create a YouTube playlist for your child'),
              _buildStep('2', 'Add high-quality, age-appropriate channels'),
              _buildStep('3', 'Review content together with your child'),
              _buildStep('4', 'Update the playlist regularly based on interests'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.timer, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Time to complete: 15-20 minutes',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Recommended Channels by Age',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAgeSection('Ages 3-6', [
                'PBS Kids',
                'Sesame Street',
                'Super Simple Songs',
                'Cosmic Kids Yoga',
              ]),
              const SizedBox(height: 16),
              _buildAgeSection('Ages 7-10', [
                'SciShow Kids',
                'National Geographic Kids',
                'Art for Kids Hub',
                'Crash Course Kids',
              ]),
              const SizedBox(height: 16),
              _buildAgeSection('Ages 11+', [
                'TED-Ed',
                'Khan Academy',
                'Mark Rober',
                'Kurzgesagt',
              ]),
            ],
          ),
        ),
        ContentCard(
          title: 'Why it helps',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Creating a curated watchlist helps:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text('• Ensure content is age-appropriate and educational'),
              Text('• Reduce exposure to random recommendations'),
              Text('• Give children choice within safe boundaries'),
              Text('• Make screen time more intentional and valuable'),
            ],
          ),
        ),
        ContentCard(
          title: 'Pro Tips',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.people,
                'Watch together initially to understand what your child enjoys',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.update,
                'Review and update the playlist monthly based on changing interests',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.block,
                'Use Restricted Mode alongside the playlist for extra safety',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSection(String ageGroup, List<String> channels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ageGroup,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...channels.map((channel) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text(channel),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}