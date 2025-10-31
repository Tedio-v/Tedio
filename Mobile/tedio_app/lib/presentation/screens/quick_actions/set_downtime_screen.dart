import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/quick_action_base.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/quick_action_service.dart';

class SetDowntimeScreen extends StatefulWidget {
  const SetDowntimeScreen({super.key});

  @override
  State<SetDowntimeScreen> createState() => _SetDowntimeScreenState();
}

class _SetDowntimeScreenState extends State<SetDowntimeScreen> {
  final QuickActionService _quickActionService = QuickActionService();
  bool _isCompleted = false;
  bool _isLoading = false;
  final String actionId = 'set-downtime';

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
      title: 'Set Screen Time Downtime',
      isCompleted: _isCompleted,
      onCompletedChanged: _toggleCompletion,
      tutorialUrl: 'https://www.youtube.com/watch?v=kNgdb2ozVkc',
      tutorialTitle: 'How to set downtime tutorial',
      resources: const [
        ResourceItem(
          title: 'Be a Role Model: Balance Screen Time',
          url: 'https://www.commonsensemedia.org/articles/be-a-role-model-4-ways-to-balance-screen-time-around-children',
        ),
        ResourceItem(
          title: 'Are Some Types of Screen Time Better?',
          url: 'https://www.commonsensemedia.org/articles/are-some-types-of-screen-time-better-than-others',
        ),
        ResourceItem(
          title: 'Conversations with Older Kids About Screen Time',
          url: 'https://www.commonsensemedia.org/articles/4-conversations-to-have-with-older-kids-and-teens-about-their-screen-time-habits',
        ),
      ],
      content: [
        ContentCard(
          title: 'How to do it',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep('1', 'Talk with your partner or caregiver to get on the same page'),
              _buildStep('2', 'Set a daily screen time limit for each child—split it between weekdays and weekends'),
              _buildStep('3', 'Create a separate Google or Apple account for your child to turn on parental controls'),
              _buildStep('4', 'Keep bedrooms screen-free. You can also make places like the dinner table or car screen-free'),
              _buildStep('5', 'Stay consistent—and connect with other parents doing the same. You\'ve got this'),
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
                      'Time to complete: ~15 minutes',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Source: Guidebook – Sage Parents',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
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
                'Setting screen time rules and using built-in parental control tools in your devices and apps makes it easier to stay on track. Technology can support you in maintaining healthy boundaries.',
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
                        'Consistent boundaries help children develop self-regulation skills and understand that screen time has limits, just like other activities.',
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
          title: 'Setting Up iOS Screen Time',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.settings,
                'Go to Settings > Screen Time > Turn On Screen Time',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.person_add,
                'Choose "This is My Child\'s iPhone" if setting up for a child',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.schedule,
                'Set Downtime hours (e.g., 8 PM to 7 AM)',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.apps,
                'Configure App Limits for categories like Social or Games',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.block,
                'Set Communication & Safety restrictions as needed',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Setting Up Android Digital Wellbeing',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.settings,
                'Go to Settings > Digital Wellbeing & Parental Controls',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.bedtime,
                'Set up Bedtime mode with your preferred schedule',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.timer,
                'Use App Timers to limit daily usage of specific apps',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.family_restroom,
                'Consider Google Family Link for additional parental controls',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.notifications_off,
                'Enable Focus mode to pause distracting apps',
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
                Icons.family_restroom,
                'Apply screen time rules to the whole family to model good behavior',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.chat_bubble,
                'Explain the "why" behind screen time limits to help children understand',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.schedule,
                'Start with longer limits and gradually reduce to avoid resistance',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.weekend,
                'Consider different rules for weekdays vs. weekends',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.content_paste,
                'See "Build a Watch List" for help with content selection',
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