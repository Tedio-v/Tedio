import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/quick_action_base.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/quick_action_service.dart';

class RemoveShortsScreen extends StatefulWidget {
  const RemoveShortsScreen({super.key});

  @override
  State<RemoveShortsScreen> createState() => _RemoveShortsScreenState();
}

class _RemoveShortsScreenState extends State<RemoveShortsScreen> {
  final QuickActionService _quickActionService = QuickActionService();
  bool _isCompleted = false;
  bool _isLoading = false;
  final String actionId = 'remove-shorts';

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
      title: 'Remove Shorts from Home',
      isCompleted: _isCompleted,
      onCompletedChanged: _toggleCompletion,
      tutorialUrl: 'https://www.youtube.com/watch?v=LLrb7N_0HSs',
      tutorialTitle: 'How to remove YouTube Shorts',
      resources: const [
        ResourceItem(
          title: 'Cellphones and devices',
          url: 'https://www.commonsensemedia.org/articles/cellphones-and-devices-a-guide-for-parents-and-caregivers',
        ),
        ResourceItem(
          title: 'Who collects kids data',
          url: 'https://www.commonsensemedia.org/articles/who-is-collecting-my-kids-data-and-what-are-they-doing-with-it',
        ),
      ],
      content: [
        ContentCard(
          title: 'How to do it',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep('1', 'On YouTube, navigate to your Home screen.'),
              _buildStep('2', 'Find the Shorts section.'),
              _buildStep('3', 'Click the three vertical dots.'),
              _buildStep('4', 'Click "Not Interested".'),
              _buildStep('5', 'Repeat for all Shorts on your home screen.'),
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
                      'Time to complete: ~1 minute',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Why it helps',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shorts are designed for rapid consumption with an endless scroll that makes it hard to stop. Removing them from your home feed reduces the temptation to start scrolling.',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.lightbulb, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This helps train the YouTube algorithm to show fewer short-form videos in your recommendations.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Tips for Success',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.refresh,
                'The "Not Interested" option may reappear after some time - you might need to repeat this process occasionally.',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.child_care,
                'Consider using YouTube Kids for younger children as it doesn\'t include Shorts.',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.touch_app,
                'You can also long-press on individual Shorts and select "Not Interested" to train the algorithm.',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Talk with Your Child',
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '"There are so many fun things in the world!"',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Imagine the last time you found something interesting on the street, at school, or anywhere else. YouTube is fun, but do you want it to take away your curious and playful mind?',
                  style: TextStyle(height: 1.5),
                ),
                SizedBox(height: 12),
                Text(
                  'Let\'s remind ourselves how precious our curious mind is and the little fun things that are hiding around us that we can only find when we see the world with curiosity.',
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
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